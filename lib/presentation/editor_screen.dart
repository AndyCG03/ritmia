import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../core/catalog.dart';
import '../core/errors.dart';
import '../core/providers.dart';
import '../core/theme.dart';
import '../domain/repositories.dart';
import '../domain/subscription.dart';
import '../l10n/context.dart';
import 'sheets/currency_sheet.dart';
import 'sheets/sheet.dart';
import 'widgets/generic_icons.dart';
import 'widgets/service_avatar.dart';

/// Create or edit a subscription. Only the purchase date is asked; renewals are derived from it.
/// A free service can "become paid" on a given day with its own amount and currency.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.item, this.initialBrand});
  final Subscription? item;
  /// Catalog choice from the add sheet; pre-fills name and provider link.
  final ServiceBrand? initialBrand;
  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _amount, _notes, _url;
  late final String _id;
  late String _currency;
  late DateTime _purchase, _paidFrom;
  DateTime? _ends;
  late bool _free, _becomesPaid;
  bool _busy = false, _removeLogo = false;
  late int _color;
  String? _brand;
  late BillingCycle _cycle;
  late SubscriptionStatus _status;
  late Category _category;
  late Set<int> _reminders;
  Uint8List? _image;

  bool get _custom => _brand == null || isGeneric(_brand);

  @override
  void initState() {
    super.initState();
    final s = widget.item, b = widget.initialBrand, today = dateOnly(DateTime.now());
    _id = s?.id ?? newId();
    _name = TextEditingController(text: s?.name ?? b?.name ?? '');
    _currency = s?.currency ?? 'USD';
    final digits = currencyDigits(_currency);
    _amount = TextEditingController(text: s == null || s.amountMinor == 0 ? ''
      : (s.amountMinor / (digits == 0 ? 1 : 100)).toStringAsFixed(digits));
    _notes = TextEditingController(text: s?.notes ?? '');
    _url = TextEditingController(text: s?.cancelUrl ?? b?.cancelUrl ?? '');
    // A trial that converts is stored as: anchor = trialEndsOn = first paid day.
    final trialConverts = s != null && !s.free && s.trialEndsOn != null && s.trialEndsOn == s.anchorDate;
    _free = s == null ? false : (s.free || trialConverts);
    _becomesPaid = trialConverts;
    _purchase = s == null ? today : s.purchaseDate;
    _paidFrom = trialConverts ? DateTime.parse(s.anchorDate) : DateTime(today.year, today.month + 1, today.day);
    _ends = s?.endsOn == null ? null : DateTime.parse(s!.endsOn!);
    _brand = s?.brandId ?? b?.id;
    _color = s?.color ?? b?.color ?? BrandTheme.colors.first;
    _cycle = s?.cycle ?? BillingCycle.monthly;
    _status = s?.status ?? SubscriptionStatus.active;
    _category = s?.category ?? (b != null && b.ai ? Category.productivity : Category.other);
    _reminders = (s?.reminderDays ?? [3, 1]).toSet();
  }

  @override
  void dispose() { for (final c in [_name, _amount, _notes, _url]) { c.dispose(); } super.dispose(); }

  Future<DateTime?> _pick(DateTime initial) => showDatePicker(context: context, initialDate: initial,
    firstDate: DateTime(2000), lastDate: DateTime(2100, 12, 31));

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 256, maxHeight: 256, imageQuality: 85);
      if (file == null) return;
      if (await file.length() > 4 * 1024 * 1024) throw const AppFailure('image');
      final decoded = img.decodeImage(await file.readAsBytes());
      if (decoded == null || decoded.width * decoded.height > 16000000) throw const AppFailure('image');
      final small = img.copyResize(decoded, width: decoded.width >= decoded.height ? 256 : null, height: decoded.height > decoded.width ? 256 : null);
      final bytes = Uint8List.fromList(img.encodePng(small));
      if (bytes.length > 131072) throw const AppFailure('image');
      if (mounted) setState(() { _image = bytes; _removeLogo = false; });
    } catch (error) { if (mounted) showFailure(context, error); }
  }

  bool get _charges => !_free || _becomesPaid;
  DateTime get _anchor => _free && _becomesPaid ? _paidFrom : _purchase;

  Subscription _build() => Subscription(id: _id, name: _name.text.trim(),
    amountMinor: _charges ? (parseAmount(_amount.text, _currency) ?? 0) : 0,
    currency: _currency, free: !_charges, anchorDate: dateKey(_anchor), cycle: _cycle, color: _color, brandId: _brand,
    status: _status, category: _category, notes: _notes.text.trim(), cancelUrl: _url.text.trim(),
    endsOn: _ends == null ? null : dateKey(_ends!), trialEndsOn: _free && _becomesPaid ? dateKey(_paidFrom) : null,
    reminderDays: _reminders.toList()..sort(), revision: widget.item?.revision ?? 0, purchasedOn: dateKey(_purchase),
    logoPath: _removeLogo ? null : widget.item?.logoPath, localLogo: _removeLogo ? null : widget.item?.localLogo);

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_ends != null && !_ends!.isAfter(_anchor)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.dateOrder))); return;
    }
    setState(() => _busy = true);
    var saved = false;
    try {
      final repo = ref.read(repositoryProvider);
      if (repo == null) throw const AppFailure('storage');
      final record = await repo.save(_build()); saved = true;
      if (_image != null && _custom) await repo.setLogo(record, _image!);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        if (saved) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.logoPartialError))); Navigator.pop(context); }
        else { showFailure(context, error); }
      }
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n, t = context.tokens;
    final brand = findBrand(_brand);
    final preview = _build();
    final next = preview.nextRenewal(DateTime.now());
    final section = TextStyle(fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: t.textSecondary);
    Widget label(String text) => Padding(padding: const EdgeInsets.only(top: 28, bottom: 10), child: Text(text.toUpperCase(), style: section));

    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? s.add : s.edit, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: t.textPrimary))),
      body: Form(key: _form, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40), children: [
          // Identity
          Row(children: [
            if (_image != null && _custom) ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.memory(_image!, width: 56, height: 56, fit: BoxFit.cover))
            else if (widget.item != null) ServiceAvatar(item: preview, size: 56)
            else BrandMark(name: _name.text, brand: brand, icon: genericIconFor(_brand), size: 56),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _name, maxLength: 80, onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: t.textPrimary),
              decoration: InputDecoration(labelText: s.serviceName, counterText: ''),
              validator: (v) => v == null || v.trim().isEmpty || v.trim().length > 80 ? s.invalidName : null)),
          ]),

          // Price
          label(s.priceSection),
          SegmentedButton<bool>(showSelectedIcon: false, segments: [
            ButtonSegment(value: false, label: Text(s.paidOption)),
            ButtonSegment(value: true, label: Text(s.freeOption)),
          ], selected: {_free}, onSelectionChanged: _busy ? null : (v) => setState(() => _free = v.first)),
          if (_free) ...[
            const SizedBox(height: 8),
            SwitchListTile(contentPadding: EdgeInsets.zero, value: _becomesPaid,
              title: Text(s.becomesPaid, style: TextStyle(fontSize: 16, color: t.textPrimary)),
              subtitle: Text(s.becomesPaidHelp, style: TextStyle(color: t.textSecondary)),
              onChanged: _busy ? null : (v) => setState(() => _becomesPaid = v)),
            if (_becomesPaid) _DateRow(label: s.paidFrom, date: _paidFrom, enabled: !_busy,
              onPick: () async { final d = await _pick(_paidFrom); if (d != null) setState(() => _paidFrom = d); }),
          ],
          if (_charges) ...[
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: TextFormField(controller: _amount, onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.numberWithOptions(decimal: currencyDigits(_currency) > 0),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                style: const TextStyle(fontSize: 18, fontFeatures: BrandTheme.tabular),
                decoration: InputDecoration(labelText: _free ? s.amountAfter : s.amount),
                validator: (v) => (parseAmount(v ?? '', _currency) ?? 0) <= 0 ? s.invalidAmount : null)),
              const SizedBox(width: 12),
              SizedBox(height: 56, child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(96, 56), side: BorderSide(color: t.separator),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: _busy ? null : () async { final c = await showCurrencySheet(context, _currency); if (c != null) setState(() => _currency = c); },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_currency, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4), Icon(Icons.expand_more_rounded, size: 20, color: t.textSecondary),
                ]))),
            ]),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: BillingCycle.values.map((c) => ChoiceChip(
              label: Text(context.cycleLabel(c)), selected: _cycle == c, showCheckmark: false,
              onSelected: _busy ? null : (_) => setState(() => _cycle = c))).toList()),
          ],

          // Date: only the purchase date is needed
          ...[
            label(s.purchaseDate),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (text, date) in [(s.today, dateOnly(DateTime.now())), (s.yesterday, dateOnly(DateTime.now()).subtract(const Duration(days: 1)))])
                ChoiceChip(label: Text(text), selected: _purchase == date, showCheckmark: false,
                  onSelected: _busy ? null : (_) => setState(() => _purchase = date)),
              ActionChip(avatar: Icon(Icons.calendar_today_outlined, size: 18, color: t.textPrimary),
                label: Text(_purchase == dateOnly(DateTime.now()) || _purchase == dateOnly(DateTime.now()).subtract(const Duration(days: 1))
                  ? s.pickDate : context.dayMonthYear(_purchase)),
                onPressed: _busy ? null : () async { final d = await _pick(_purchase); if (d != null) setState(() => _purchase = d); }),
            ]),
            const SizedBox(height: 10),
            Text(s.purchaseHelp, style: TextStyle(fontSize: 14, height: 1.4, color: t.textSecondary)),
          ],
          if (_charges && next != null) ...[
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: t.tile, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(Icons.event_repeat_rounded, color: t.textAction),
                const SizedBox(width: 12),
                Expanded(child: Text(_free && _becomesPaid
                  ? s.freeUntilPreview(context.dayMonthYear(_paidFrom), '${_amount.text.isEmpty ? '—' : _amount.text} $_currency ${context.perCycle(_cycle)}')
                  : s.nextRenewalPreview(context.dayMonthYear(next)),
                  style: TextStyle(fontSize: 15, color: t.textPrimary))),
              ])),
          ],

          // Reminders
          label(s.reminders),
          Wrap(spacing: 8, runSpacing: 8, children: [(1, s.daysOne), (3, s.daysThree), (7, s.daysSeven), (14, s.daysFourteen)].map((e) => FilterChip(
            label: Text(e.$2), selected: _reminders.contains(e.$1),
            onSelected: _busy ? null : (v) => setState(() { v ? _reminders.add(e.$1) : _reminders.remove(e.$1); }))).toList()),

          // Color and logo only for custom services; catalog brands keep their own mark.
          if (_custom) ...[
            label(s.chooseIcon),
            Wrap(spacing: 10, runSpacing: 10, children: genericIcons.entries.map((e) {
              final id = '$genericPrefix${e.key}', on = _brand == id && _image == null;
              return Semantics(button: true, selected: on, label: e.key, child: InkWell(borderRadius: BorderRadius.circular(14),
                onTap: _busy ? null : () => setState(() { _brand = id; _image = null; _removeLogo = true; }),
                child: AnimatedContainer(duration: const Duration(milliseconds: 160), width: 52, height: 52,
                  decoration: BoxDecoration(color: on ? t.selectedDay : t.field, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: on ? t.selectedDay : t.separator.withValues(alpha: 0.6))),
                  child: Icon(e.value, size: 24, color: on ? t.onSelectedDay : t.textPrimary))));
            }).toList()),
            const SizedBox(height: 16),
            Row(children: [
              OutlinedButton.icon(onPressed: _busy ? null : _pickImage, icon: const Icon(Icons.add_photo_alternate_outlined), label: Text(s.uploadOwn)),
              if (_image != null || widget.item?.logoPath != null || widget.item?.localLogo != null) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: _busy ? null : () => setState(() { _image = null; _removeLogo = true; }), child: Text(s.removeLogo)),
              ],
            ]),
            const SizedBox(height: 6),
            Text(s.logoHelp, style: TextStyle(fontSize: 13, color: t.textSecondary)),
          ],

          // Less common fields
          const SizedBox(height: 20),
          Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(
            tilePadding: EdgeInsets.zero, childrenPadding: EdgeInsets.zero,
            title: Text(s.moreOptions, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: t.textPrimary)),
            children: [
              DropdownButtonFormField<Category>(initialValue: _category, decoration: InputDecoration(labelText: s.category),
                items: Category.values.map((c) => DropdownMenuItem(value: c, child: Text(context.categoryLabel(c)))).toList(),
                onChanged: _busy ? null : (v) => setState(() => _category = v!)),
              const SizedBox(height: 16),
              DropdownButtonFormField<SubscriptionStatus>(initialValue: _status, decoration: InputDecoration(labelText: s.status),
                items: SubscriptionStatus.values.map((c) => DropdownMenuItem(value: c, child: Text(context.statusLabel(c)))).toList(),
                onChanged: _busy ? null : (v) => setState(() => _status = v!)),
              const SizedBox(height: 8),
              _DateRow(label: s.endsOn, date: _ends, enabled: !_busy,
                onPick: () async { final d = await _pick(_ends ?? _anchor.add(const Duration(days: 365))); if (d != null) setState(() => _ends = d); },
                onClear: _ends == null ? null : () => setState(() => _ends = null)),
              const SizedBox(height: 8),
              TextFormField(controller: _url, maxLength: 500, decoration: InputDecoration(labelText: s.cancelUrl, helperText: s.manageHelp, helperMaxLines: 3),
                validator: (v) { if (v == null || v.trim().isEmpty) return null; final uri = Uri.tryParse(v.trim());
                  return uri != null && uri.scheme == 'https' && uri.host.contains('.') ? null : s.invalidUrl; }),
              const SizedBox(height: 8),
              TextFormField(controller: _notes, maxLength: 1000, maxLines: 3, decoration: InputDecoration(labelText: s.notes)),
            ])),
          const SizedBox(height: 24),
          FilledButton(onPressed: _busy ? null : _save, child: _busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(s.save)),
        ])))));
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.date, required this.onPick, required this.enabled, this.onClear});
  final String label;
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback? onClear;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(children: [
      InkWell(onTap: enabled ? onPick : null, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 56), child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 16, color: t.textSecondary))),
        Text(date == null ? '—' : context.dayMonthYear(date!), style: TextStyle(fontSize: 16, color: t.textPrimary, fontFeatures: BrandTheme.tabular)),
        if (onClear != null) IconButton(tooltip: context.l10n.clear, onPressed: onClear, icon: Icon(Icons.close_rounded, size: 20, color: t.textSecondary))
        else Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.calendar_today_outlined, size: 20, color: t.textPrimary)),
      ]))),
      const Hairline(),
    ]);
  }
}
