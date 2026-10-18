import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/guided_tour_provider.dart';
import '../../core/theme.dart';
import '../../l10n/context.dart';
import '../../l10n/generated/app_localizations.dart';

const _targets = <TourStep, List<String>>{
  TourStep.add: ['add'],
  TourStep.brand: ['brand'],
  TourStep.name: ['name'],
  TourStep.price: ['price', 'trial', 'paidFrom', 'amount', 'cycle'],
  TourStep.date: ['date'],
  TourStep.reminders: ['reminders'],
  TourStep.save: ['save'],
  TourStep.record: ['record'],
  TourStep.calendar: ['calendar'],
  TourStep.filter: ['filter'],
  TourStep.settings: ['settings'],
};

/// Registers real controls; the tour never duplicates the creation form or writes sample records.
class TourAnchor extends ConsumerWidget {
  const TourAnchor({super.key, required this.id, required this.child});
  final String id;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tour = ref.read(guidedTourProvider.notifier),
        state = ref.watch(guidedTourProvider);
    final key = tour.keyFor(id);
    if (_targets[state.step]?.contains(id) ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final target = key.currentContext;
        if (target == null || !target.mounted || state.paused) return;
        if (_targets[state.step]!.first == id &&
            Scrollable.maybeOf(target) != null) {
          await Scrollable.ensureVisible(
            target,
            alignment: 0.12,
            duration: MediaQuery.disableAnimationsOf(target)
                ? Duration.zero
                : const Duration(milliseconds: 300),
          );
        }
        tour.changedGeometry();
      });
    }
    if (!(_targets[state.step]?.contains(id) ?? false)) return child;
    return SizedBox(key: key, child: child);
  }
}

class GuidedTourOverlay extends ConsumerStatefulWidget {
  const GuidedTourOverlay({super.key});
  @override
  ConsumerState<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends ConsumerState<GuidedTourOverlay>
    with WidgetsBindingObserver {
  Rect? _rect;
  late GuidedTourController _tour;
  @override
  void initState() {
    super.initState();
    _tour = ref.read(guidedTourProvider.notifier);
    _tour.geometry.addListener(_scheduleMeasure);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tour.geometry.removeListener(_scheduleMeasure);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => _scheduleMeasure();
  bool _measuring = false;
  void _scheduleMeasure() {
    if (_measuring) return;
    _measuring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measuring = false;
      if (!mounted) return;
      final state = ref.read(guidedTourProvider);
      Rect? rect;
      var animating = false;
      for (final id in _targets[state.step] ?? const <String>[]) {
        final ctx = _tour.keys[id]?.currentContext;
        if (ctx == null || !ctx.mounted) continue;
        final route = ModalRoute.of(ctx);
        if ((route?.animation != null && !route!.animation!.isCompleted) ||
            (route?.secondaryAnimation != null && !route!.secondaryAnimation!.isDismissed)) {
          animating = true;
        }
        final box = ctx.findRenderObject();
        if (box is RenderBox && box.attached && box.hasSize) {
          final bounds = box.localToGlobal(Offset.zero) & box.size;
          rect = rect == null ? bounds : rect.expandToInclude(bounds);
        }
      }
      final changed = rect != _rect;
      if (changed) setState(() => _rect = rect);
      if (changed || animating) _scheduleMeasure();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guidedTourProvider),
        s = context.l10n,
        t = context.tokens;
    ref.listen(guidedTourProvider, (previous,next) {
      if (previous?.step == null && next.step != null) {
        ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
      }
      if(previous?.step!=next.step || previous?.paused!=next.paused) setState(()=>_rect=null);
      _scheduleMeasure();
    });
    final step = state.step, rect = _rect;
    if (step == null || state.paused || rect == null) {
      return const SizedBox.shrink();
    }
    final media = MediaQuery.of(context), size = media.size;
    final bottom = size.height - media.viewInsets.bottom - media.padding.bottom;
    final viewport = Rect.fromLTRB(
      6,
      media.padding.top + 4,
      size.width - 6,
      bottom - 4,
    );
    final target = rect.inflate(6).intersect(viewport);
    if (target.isEmpty || !target.overlaps(viewport)) {
      return const SizedBox.shrink();
    }
    final keyboard = media.viewInsets.bottom > 0;
    final maxWidth = math.min(size.width - 32, 400.0),
        left = (size.width - maxWidth) / 2;
    final aboveSpace=math.max(0.0,target.top-media.padding.top-20);
    final belowSpace=math.max(0.0,bottom-target.bottom-20);
    final below=belowSpace>=180 || belowSpace>aboveSpace;
    final floating=step==TourStep.brand;
    final maxHeight=floating ? (keyboard?96.0:math.min(280.0,bottom*.4)) : math.max(96.0,below?belowSpace:aboveSpace);
    final compact=keyboard || maxHeight<170;
    final cardTop=floating ? math.max(media.padding.top+8,bottom-(keyboard?84:maxHeight)-(keyboard?12:90)) : below ? target.bottom+12 : null;
    final cardBottom=!floating&&!below ? size.height-target.top+12 : null;
    final canNext = !{
      TourStep.add,
      TourStep.brand,
      TourStep.save,
    }.contains(step);
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _Spotlight(target, t.accent)),
            ),
          ),
          // These four barriers leave the highlighted control fully interactive.
          for (final r in [
            Rect.fromLTRB(0, 0, size.width, target.top),
            Rect.fromLTRB(0, target.bottom, size.width, size.height),
            Rect.fromLTRB(0, target.top, target.left, target.bottom),
            Rect.fromLTRB(target.right, target.top, size.width, target.bottom),
          ])
            if (!r.isEmpty)
              Positioned.fromRect(
                rect: r,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                ),
              ),
          Positioned(left:left,top:cardTop,bottom:cardBottom,width:maxWidth,
            child:ConstrainedBox(constraints:BoxConstraints(maxHeight:maxHeight),child:Material(
              color:t.sheet,elevation:12,borderRadius:BorderRadius.circular(20),
              child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,
                crossAxisAlignment:CrossAxisAlignment.start,children:[
                  if(!compact) ...[
                    Row(children:[
                      Icon(below?Icons.arrow_upward_rounded:Icons.arrow_downward_rounded,size:20,color:t.textAction),
                      const SizedBox(width:8),
                      Expanded(
                        child:Text(
                          s.tourProgress(step.index-_tour.firstStepIndex+1,TourStep.values.length-_tour.firstStepIndex),
                          maxLines:1,
                          overflow:TextOverflow.ellipsis,
                          style:TextStyle(color:t.textSecondary,fontSize:12),
                        ),
                      ),
                      TextButton(onPressed:()=>_tour.finish(),child:Text(s.tourSkip)),
                    ]),
                    Flexible(child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                      Semantics(header:true,child:Text(_title(step,s),style:TextStyle(fontSize:20,fontWeight:FontWeight.w600,color:t.textPrimary))),
                      const SizedBox(height:8),Text(_body(step,s),style:TextStyle(fontSize:14,height:1.4,color:t.textSecondary)),
                    ]))),
                    const SizedBox(height:12),
                  ],
                  if(canNext || compact) Row(children:[
                    if(editorTourSteps.contains(step)&&step!=TourStep.name)
                      TextButton(onPressed:(){FocusManager.instance.primaryFocus?.unfocus();_tour.back();},child:Text(s.tourBack)),
                    const Spacer(),
                    if(canNext) FilledButton(onPressed:state.stepReady?(){
                      FocusManager.instance.primaryFocus?.unfocus();
                      if(step==TourStep.settings){_tour.finish();}else{_tour.next();}
                    }:null,child:Text(step==TourStep.settings?s.tourFinish:s.tourNext))
                    else TextButton(onPressed:()=>_tour.finish(),child:Text(s.tourSkip)),
                  ]),
                ])),
            ))),
        ],
      ),
    );
  }
}

class _Spotlight extends CustomPainter {
  const _Spotlight(this.rect, this.accent);
  final Rect rect;
  final Color accent;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: .62));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_Spotlight old) =>
      old.rect != rect || old.accent != accent;
}

String _title(TourStep step, AppLocalizations s) => switch (step) {
  TourStep.add => s.tourAddTitle,
  TourStep.brand => s.tourBrandTitle,
  TourStep.name => s.tourNameTitle,
  TourStep.price => s.tourPriceTitle,
  TourStep.date => s.tourDateTitle,
  TourStep.reminders => s.tourRemindersTitle,
  TourStep.save => s.tourSaveTitle,
  TourStep.record => s.tourRecordTitle,
  TourStep.calendar => s.tourCalendarTitle,
  TourStep.filter => s.tourFilterTitle,
  TourStep.settings => s.tourSettingsTitle,
};
String _body(TourStep step, AppLocalizations s) => switch (step) {
  TourStep.add => s.tourAddBody,
  TourStep.brand => s.tourBrandBody,
  TourStep.name => s.tourNameBody,
  TourStep.price => s.tourPriceBody,
  TourStep.date => s.tourDateBody,
  TourStep.reminders => s.tourRemindersBody,
  TourStep.save => s.tourSaveBody,
  TourStep.record => s.tourRecordBody,
  TourStep.calendar => s.tourCalendarBody,
  TourStep.filter => s.tourFilterBody,
  TourStep.settings => s.tourSettingsBody,
};
