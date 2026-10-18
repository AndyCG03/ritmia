import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';
import '../../services/billing_service.dart';
import '../widgets/ritmia_logo.dart';
import 'sheet.dart';

Future<void> showProSheet(BuildContext context) => showRitmiaSheet<void>(
  context,
  builder: (_) => const _ProSheet(),
);

Future<void> showInterstitialAdSheet(BuildContext context) =>
    showRitmiaSheet<void>(
      context,
      builder: (_) => const _InterstitialAdSheet(),
    );

class _ProSheet extends ConsumerStatefulWidget {
  const _ProSheet();
  @override
  ConsumerState<_ProSheet> createState() => _ProSheetState();
}

class _ProSheetState extends ConsumerState<_ProSheet> {
  bool _busy = false;

  Future<void> _unlock() async {
    final s = context.l10n;
    final billing = ref.read(billingServiceProvider);
    if (!billing.enabled) {
      showInfo(context, s.proPending);
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(repositoryProvider);
      final ok = await billing.purchaseLifetime(repo);
      if (!mounted) return;
      if (ok) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final s = context.l10n;
    final billing = ref.read(billingServiceProvider);
    if (!billing.enabled) {
      showInfo(context, s.proPending);
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(repositoryProvider);
      final ok = await billing.restorePurchase(repo);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
      } else {
        showInfo(context, s.proRestoreEmpty);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n, t = context.tokens;
    final plan = ref.watch(entitlementProvider).asData?.value;
    final isPro = plan?.pro == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isPro ? s.proActiveBadge : s.proBadge,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: t.textAction,
                  ),
                ),
              ),
              const Spacer(),
              const SheetCloseButton(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const RitmiaLogo(size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.proPlan,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: t.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.proSubtitle,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: t.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _BenefitTile(
            icon: Icons.all_inclusive_rounded,
            title: s.proBenefitUnlimitedTitle,
            body: s.proBenefitUnlimitedBody,
          ),
          const SizedBox(height: 12),
          _BenefitTile(
            icon: Icons.block_rounded,
            title: s.proBenefitNoAdsTitle,
            body: s.proBenefitNoAdsBody,
          ),
          const SizedBox(height: 12),
          _BenefitTile(
            icon: Icons.verified_outlined,
            title: s.proBenefitOneTimeTitle,
            body: s.proBenefitOneTimeBody,
          ),
          const SizedBox(height: 24),
          if (!isPro) ...[
            FilledButton(
              onPressed: _busy ? null : _unlock,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.proUnlockCta),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _restore,
              child: Text(s.proRestoreCta),
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.separator.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: t.textAction),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterstitialAdSheet extends ConsumerWidget {
  const _InterstitialAdSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.l10n, t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandTheme.coral.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  s.adInterstitialLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: t.dotToday,
                  ),
                ),
              ),
              const Spacer(),
              const SheetCloseButton(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.field,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.separator.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const RitmiaLogo(size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.adInterstitialTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  s.adInterstitialBody,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              showProSheet(context);
            },
            child: Text(s.proUnlockCta),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.adContinueFree),
          ),
        ],
      ),
    );
  }
}
