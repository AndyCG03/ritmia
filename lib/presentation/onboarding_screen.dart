import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../core/onboarding_provider.dart';
import '../core/theme.dart';
import '../l10n/context.dart';
import '../services/notification_service.dart';
import 'sheets/permission_sheet.dart';

/// Three short steps. Language follows the phone; the last step explains reminders
/// before the OS permission prompt ever appears.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  bool _busy = false;

  @override
  void dispose() { _pages.dispose(); super.dispose(); }

  Future<void> _finish({bool withReminders = false}) async {
    if (withReminders) {
      setState(() => _busy = true);
      await askForReminders(context, ref);
      if (mounted) setState(() => _busy = false);
    }
    await ref.read(onboardingProvider.notifier).complete();
  }

  Future<void> _next(bool reduce) async {
    if (reduce) { _pages.jumpToPage(_page + 1); return; }
    await _pages.nextPage(duration: const Duration(milliseconds: 480), curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n, t = context.tokens, reduce = MediaQuery.disableAnimationsOf(context);
    final slides = [
      ('rhythm', s.onboardTitleOne, s.onboardBodyOne, s.onboardEyebrowOne),
      ('calendar', s.onboardTitleTwo, s.onboardBodyTwo, s.onboardEyebrowTwo),
      ('bell', s.onboardTitleThree, s.onboardBodyThree, s.onboardEyebrowThree),
    ];
    final last = _page == slides.length - 1;
    final remindersAvailable = NotificationService.instance.supported;

    return Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Column(children: [
      // Header: brand mark + skip
      Padding(padding: const EdgeInsets.fromLTRB(24, 12, 12, 0), child: SizedBox(height: 56, child: Row(children: [
        SvgPicture.asset('assets/brand/mark.svg', width: 30, height: 30, semanticsLabel: 'Ritmia'),
        const SizedBox(width: 10),
        ExcludeSemantics(child: Text('ritmia', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.6, color: t.textPrimary))),
        const Spacer(),
        AnimatedOpacity(opacity: last ? 0 : 1, duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
          child: TextButton(onPressed: last ? null : () => _finish(),
            style: TextButton.styleFrom(foregroundColor: t.textSecondary), child: Text(s.skip))),
      ]))),
      // Segmented progress
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Semantics(label: '${_page + 1} / ${slides.length}',
        child: Row(children: List.generate(slides.length, (i) => Expanded(child: AnimatedContainer(
          duration: reduce ? Duration.zero : const Duration(milliseconds: 320), curve: Curves.easeOutCubic,
          height: 3, margin: EdgeInsets.only(right: i < slides.length - 1 ? 6 : 0),
          decoration: BoxDecoration(color: i <= _page ? t.textAction : t.separator, borderRadius: BorderRadius.circular(2)))))))),
      Expanded(child: PageView.builder(controller: _pages, itemCount: slides.length,
        onPageChanged: (v) => setState(() => _page = v),
        itemBuilder: (context, index) {
          final slide = slides[index];
          return LayoutBuilder(builder: (context, c) {
            final stage = (c.maxHeight * 0.48).clamp(180.0, 300.0);
            return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 28, 24, 12), child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                // Animation stage: flat aubergine panel, the Lottie carries the motion.
                Container(height: stage, width: double.infinity, alignment: Alignment.center,
                  decoration: BoxDecoration(color: BrandTheme.ink, borderRadius: BorderRadius.circular(28)),
                  child: SizedBox.square(dimension: stage * 0.92, child: Lottie.asset('assets/lottie/${slide.$1}.json',
                    animate: !reduce, repeat: !reduce, frameRate: FrameRate.max,
                    errorBuilder: (_, _, _) => const Icon(Icons.auto_awesome, color: BrandTheme.lavender, size: 72)))),
                const SizedBox(height: 32),
                Text(slide.$4.toUpperCase(), style: TextStyle(color: t.textAction, fontWeight: FontWeight.w600, fontSize: 12.5, letterSpacing: 1.6)),
                const SizedBox(height: 12),
                Semantics(header: true, child: Text(slide.$2, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700,
                  letterSpacing: -0.8, height: 1.15, color: t.textPrimary))),
                const SizedBox(height: 14),
                Text(slide.$3, style: TextStyle(fontSize: 16.5, height: 1.5, color: t.textSecondary)),
              ])));
          });
        })),
      Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), child: Column(children: [
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: _busy ? null : () => last ? _finish(withReminders: remindersAvailable) : _next(reduce),
          child: Text(last ? (remindersAvailable ? s.permAllow : s.getStarted) : s.next))),
        if (last && remindersAvailable) Padding(padding: const EdgeInsets.only(top: 4),
          child: TextButton(onPressed: _busy ? null : () => _finish(), child: Text(s.getStarted)))
        else const SizedBox(height: 52),
      ])),
    ])))));
  }
}
