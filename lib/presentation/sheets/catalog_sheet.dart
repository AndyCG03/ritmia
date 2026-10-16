import 'package:flutter/material.dart';
import '../../core/catalog.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';
import '../editor_screen.dart';
import '../widgets/service_avatar.dart';
import 'sheet.dart';

/// Service chooser. Picking a row (or "custom") closes the sheet and opens the editor.
Future<void> showCatalogSheet(BuildContext context) async {
  final navigator = Navigator.of(context);
  final choice = await showRitmiaSheet<_Choice>(context, heightFactor: 0.86, maxFactor: 0.9, builder: (_) => const CatalogSheet());
  if (choice == null) return;
  navigator.push(MaterialPageRoute<void>(builder: (_) => EditorScreen(initialBrand: choice.brand)));
}

class _Choice { const _Choice(this.brand); final ServiceBrand? brand; }

class CatalogSheet extends StatefulWidget {
  const CatalogSheet({super.key});
  @override
  State<CatalogSheet> createState() => _CatalogSheetState();
}

class _CatalogSheetState extends State<CatalogSheet> {
  String _query = '';
  bool _ai = true;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens, s = context.l10n;
    final results = searchBrands(_query, aiOnly: _ai);
    Widget tab(String text, bool selected, VoidCallback onTap) => Expanded(child: Semantics(selected: selected, button: true,
      child: InkWell(onTap: onTap, child: SizedBox(height: 52, child: Stack(alignment: Alignment.center, children: [
        Text(text, style: TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          color: selected ? t.textPrimary : t.textSecondary)),
        if (selected) Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 2.5,
          decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(2)))),
      ])))));

    return Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Semantics(header: true, child: Text(s.add,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: t.textPrimary)))),
        const SheetCloseButton(),
      ]),
      const SizedBox(height: 16),
      TextField(onChanged: (v) => setState(() => _query = v), textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 17, color: t.textPrimary),
        decoration: InputDecoration(hintText: s.searchService, contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Padding(padding: const EdgeInsets.only(left: 14, right: 8), child: Icon(Icons.search_rounded, color: t.textPrimary, size: 26)))),
      const SizedBox(height: 12),
      Stack(alignment: Alignment.bottomCenter, children: [
        const Hairline(),
        Row(children: [tab(s.tabAll, !_ai, () => setState(() => _ai = false)), tab(s.tabAi, _ai, () => setState(() => _ai = true))]),
      ]),
      Expanded(child: results.isEmpty
        ? Center(child: Text(s.noResults, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: t.textSecondary)))
        : ListView.separated(padding: const EdgeInsets.only(top: 8, bottom: 8), itemCount: results.length,
            separatorBuilder: (_, _) => const Hairline(),
            itemBuilder: (context, i) {
              final b = results[i];
              return InkWell(onTap: () => Navigator.pop(context, _Choice(b)), child: SizedBox(height: 60, child: Row(children: [
                BrandMark(name: b.name, brand: b, size: 46),
                const SizedBox(width: 20),
                Expanded(child: Text(b.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: t.textPrimary))),
                Icon(Icons.add_rounded, color: t.textPrimary, size: 26, semanticLabel: s.add),
                const SizedBox(width: 6),
              ])));
            })),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () => Navigator.pop(context, const _Choice(null)),
        icon: const Icon(Icons.add_rounded, size: 26), label: Text(s.addCustom)),
    ]));
  }
}
