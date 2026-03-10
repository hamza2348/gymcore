import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutInfo workout;
  const ActiveWorkoutScreen({super.key, required this.workout});
  @override State<ActiveWorkoutScreen> createState() => _AWS();
}

class _AWS extends State<ActiveWorkoutScreen> with TickerProviderStateMixin {
  int _exIdx = 0, _setIdx = 0, _elapsed = 0, _restLeft = 0;
  bool _resting = false;
  Timer? _restTimer, _elapsedTimer;
  late AnimationController _progressCtrl, _pulseCtrl, _slideCtrl;
  late List<List<bool>> _done;

  ExerciseModel get _cur => widget.workout.exercises[_exIdx];
  List<ExerciseModel> get _exs => widget.workout.exercises;

  @override
  void initState() {
    super.initState();
    _done = _exs.map((e) => List<bool>.filled(e.sets, false)).toList();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _slideCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 380))..forward();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) { if(mounted) setState(() => _elapsed++); });
  }

  @override void dispose() {
    _restTimer?.cancel(); _elapsedTimer?.cancel();
    _progressCtrl.dispose(); _pulseCtrl.dispose(); _slideCtrl.dispose();
    super.dispose();
  }

  String _fmt(int s) => '${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';

  void _animProg() => _progressCtrl.animateTo((_exIdx+1)/_exs.length,
      duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);

  void _completeSet() {
    setState(() => _done[_exIdx][_setIdx] = true);
    final lastSet = _setIdx >= _cur.sets - 1;
    final lastEx  = _exIdx >= _exs.length - 1;
    if (lastSet && lastEx) {
      _elapsedTimer?.cancel();
      _animProg();
      Future.delayed(const Duration(milliseconds: 700), _showComplete);
      return;
    }
    final rest = _cur.restSeconds.clamp(1, 300);
    setState(() { _resting = true; _restLeft = rest; });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _restLeft--;
        if (_restLeft <= 0) {
          t.cancel(); _resting = false;
          if (lastSet) { _exIdx++; _setIdx = 0; _animProg(); _slideCtrl.reset(); _slideCtrl.forward(); }
          else { _setIdx++; }
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _resting = false;
      final lastSet = _setIdx >= _cur.sets - 1;
      if (lastSet) {
        if (_exIdx < _exs.length - 1) { _exIdx++; _setIdx = 0; _animProg(); _slideCtrl.reset(); _slideCtrl.forward(); }
      } else { _setIdx++; }
    });
  }

  void _showComplete() {
    // Save to user profile
    AuthService().markWorkoutComplete(
        widget.workout.name, _elapsed ~/ 60, widget.workout.calories);
    showDialog(context: context, barrierDismissible: false, builder: (_) =>
        _CompleteDialog(workout: widget.workout, elapsed: _fmt(_elapsed),
            onDone: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            onShare: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }));
  }

  void _confirmExit() => showDialog(context: context, builder: (_) => AlertDialog(
    backgroundColor: kCard,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text('End Workout?', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800)),
    content: Text('Progress will not be saved.', style: GoogleFonts.dmSans(color: Colors.white54)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Keep Going', style: GoogleFonts.dmSans(color: kGreen, fontWeight: FontWeight.w700))),
      TextButton(onPressed: () { _restTimer?.cancel(); _elapsedTimer?.cancel(); Navigator.pop(context); Navigator.pop(context); },
          child: Text('End', style: GoogleFonts.dmSans(color: Colors.redAccent, fontWeight: FontWeight.w700))),
    ]));

  @override
  Widget build(BuildContext ctx) => WillPopScope(
    onWillPop: () async { _confirmExit(); return false; },
    child: Scaffold(
      backgroundColor: kDark,
      body: SafeArea(child: Column(children: [
        // Top bar
        Padding(padding: const EdgeInsets.fromLTRB(16,12,16,0),
          child: Row(children: [
            GestureDetector(onTap: _confirmExit, child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.workout.name, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${_exIdx+1} / ${_exs.length} exercises', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
              child: Row(children: [
                Icon(Icons.timer_rounded, color: widget.workout.color, size: 13),
                const SizedBox(width: 4),
                Text(_fmt(_elapsed), style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ])),
          ])),
        const SizedBox(height: 10),
        // Progress bar
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(animation: _progressCtrl, builder: (_, __) =>
                LinearProgressIndicator(value: _progressCtrl.value,
                    backgroundColor: Colors.white10, color: widget.workout.color, minHeight: 5)))),
        const SizedBox(height: 12),
        Expanded(child: _resting
            ? _RestView(restLeft: _restLeft, total: _cur.restSeconds,
                accent: widget.workout.color, onSkip: _skipRest,
                nextName: _setIdx >= _cur.sets-1 && _exIdx+1 < _exs.length ? _exs[_exIdx+1].name : null)
            : AnimatedBuilder(
                animation: _slideCtrl,
                builder: (_, child) {
                  final t = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut).value;
                  return Opacity(opacity: t, child: Transform.translate(offset: Offset((1-t)*20,0), child: child));
                },
                child: _ExView(ex: _cur, setIdx: _setIdx, done: _done[_exIdx],
                    accent: widget.workout.color, pulse: _pulseCtrl,
                    onComplete: _completeSet))),
      ])));
}

// ── Exercise animated view ────────────────────────────────────────────────────
class _ExView extends StatelessWidget {
  final ExerciseModel ex; final int setIdx; final List<bool> done;
  final Color accent; final AnimationController pulse; final VoidCallback onComplete;
  const _ExView({required this.ex, required this.setIdx, required this.done,
      required this.accent, required this.pulse, required this.onComplete});

  @override
  Widget build(BuildContext ctx) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(children: [
      // Animated exercise visual
      _ExerciseVisual(ex: ex, accent: accent, pulse: pulse),
      const SizedBox(height: 14),
      Text(ex.name, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
      Text(ex.muscle, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13)),
      const SizedBox(height: 20),

      // Set card
      Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(22), border: Border.all(color: kBorder)),
        child: Column(children: [
          Text('SET  ${setIdx+1}  OF  ${ex.sets}', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 4),
          RichText(textAlign: TextAlign.center, text: TextSpan(children: [
            TextSpan(text: '${ex.reps}', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 76, fontWeight: FontWeight.w900, height: 1)),
            TextSpan(text: ex.isTime ? '\nseconds' : '\nreps',
                style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 15, height: 1.8)),
          ])),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(ex.sets, (i) {
              final isDone = done[i]; final isCur = i == setIdx;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 38, height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? accent : isCur ? accent.withOpacity(0.18) : Colors.white.withOpacity(0.06),
                  border: Border.all(color: isCur && !isDone ? accent : Colors.transparent, width: 2)),
                child: Center(child: isDone
                    ? Icon(Icons.check_rounded, color: Colors.black, size: 18)
                    : Text('${i+1}', style: GoogleFonts.dmSans(color: isCur ? accent : Colors.white38, fontWeight: FontWeight.w700))));
            })),
        ])),
      const SizedBox(height: 14),

      // Instructions
      Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.menu_book_rounded, color: accent, size: 13),
            const SizedBox(width: 6),
            Text('HOW TO DO IT', style: GoogleFonts.dmSans(color: accent, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 8),
          Text(ex.instruction, style: GoogleFonts.dmSans(color: Colors.white65, fontSize: 13, height: 1.6)),
        ])),
      const SizedBox(height: 20),

      // Done button
      _DoneBtn(accent: accent, onTap: onComplete),
      const SizedBox(height: 28),
    ]));
}

// ── Animated exercise visual with icons and motion ────────────────────────────
class _ExerciseVisual extends StatefulWidget {
  final ExerciseModel ex; final Color accent; final AnimationController pulse;
  const _ExerciseVisual({required this.ex, required this.accent, required this.pulse});
  @override State<_ExerciseVisual> createState() => _EVState();
}
class _EVState extends State<_ExerciseVisual> with SingleTickerProviderStateMixin {
  late AnimationController _bounce;
  @override void initState() { super.initState();
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true); }
  @override void dispose() { _bounce.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => AnimatedBuilder(
    animation: Listenable.merge([widget.pulse, _bounce]),
    builder: (_, __) => Container(
      width: 160, height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          widget.accent.withOpacity(0.18 + _bounce.value * 0.1),
          kCard,
        ], radius: 0.8),
        border: Border.all(color: widget.accent.withOpacity(0.3 + widget.pulse.value * 0.4), width: 2.5),
        boxShadow: [BoxShadow(
            color: widget.accent.withOpacity(0.12 + widget.pulse.value * 0.18),
            blurRadius: 30 + widget.pulse.value * 20)]),
      child: Stack(alignment: Alignment.center, children: [
        // Orbiting dots
        ...List.generate(6, (i) {
          final ang = (i / 6) * 2 * pi + _bounce.value * pi * 0.3;
          final r = 60.0;
          final x = cos(ang) * r;
          final y = sin(ang) * r;
          return Positioned(
            left: 80 + x - 3, top: 80 + y - 3,
            child: Container(width: 6, height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: widget.accent.withOpacity(0.15 + (i.isEven ? 0.2 : 0)))));
        }),
        // Main icon
        Transform.translate(
          offset: Offset(0, sin(_bounce.value * pi) * 5),
          child: Icon(widget.ex.icon, color: widget.accent, size: 70)),
      ])));
}

// ── Rest view ─────────────────────────────────────────────────────────────────
class _RestView extends StatelessWidget {
  final int restLeft, total; final Color accent; final VoidCallback onSkip; final String? nextName;
  const _RestView({required this.restLeft, required this.total, required this.accent,
      required this.onSkip, this.nextName});

  @override
  Widget build(BuildContext ctx) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('REST', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13, letterSpacing: 4, fontWeight: FontWeight.w700)),
    const SizedBox(height: 28),
    SizedBox(width: 190, height: 190, child: Stack(alignment: Alignment.center, children: [
      CustomPaint(painter: _Ring(progress: restLeft / total.clamp(1, 300), color: accent), size: const Size(190, 190)),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$restLeft', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 68, fontWeight: FontWeight.w900, height: 1)),
        Text('seconds', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 15)),
      ]),
    ])),
    const SizedBox(height: 24),
    if (nextName != null) ...[
      Text('UP NEXT', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
      const SizedBox(height: 6),
      Text(nextName!, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 24),
    ],
    GestureDetector(onTap: onSkip, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(30),
          border: Border.all(color: accent.withOpacity(0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.skip_next_rounded, color: accent, size: 18),
        const SizedBox(width: 6),
        Text('Skip Rest', style: GoogleFonts.dmSans(color: accent, fontWeight: FontWeight.w700)),
      ]))),
  ]);
}

class _Ring extends CustomPainter {
  final double progress; final Color color;
  const _Ring({required this.progress, required this.color});
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width/2, size.height/2); final r = size.width/2 - 13;
    canvas.drawCircle(c, r, Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 13);
    if (progress > 0)
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi/2, 2*pi*progress, false,
          Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 13..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(_Ring o) => o.progress != progress;
}

// ── Done button ───────────────────────────────────────────────────────────────
class _DoneBtn extends StatefulWidget {
  final Color accent; final VoidCallback onTap;
  const _DoneBtn({required this.accent, required this.onTap});
  @override State<_DoneBtn> createState() => _DBState();
}
class _DBState extends State<_DoneBtn> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100)); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTapDown: (_) => _c.forward(), onTapUp: (_) { _c.reverse(); widget.onTap(); }, onTapCancel: () => _c.reverse(),
    child: AnimatedBuilder(animation: _c, builder: (_, child) => Transform.scale(scale: 1-_c.value*0.04, child: child),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: widget.accent, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: widget.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0,8))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle_rounded, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Text('DONE! NEXT SET', style: GoogleFonts.dmSans(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 17)),
        ]))));
}

// ── Complete dialog ───────────────────────────────────────────────────────────
class _CompleteDialog extends StatelessWidget {
  final WorkoutInfo workout; final String elapsed;
  final VoidCallback onDone, onShare;
  const _CompleteDialog({required this.workout, required this.elapsed, required this.onDone, required this.onShare});

  @override
  Widget build(BuildContext ctx) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(28),
          border: Border.all(color: workout.color.withOpacity(0.3))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (_, v, __) => Transform.scale(scale: v,
            child: Container(width: 88, height: 88,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: workout.color.withOpacity(0.12),
                  border: Border.all(color: workout.color.withOpacity(0.4), width: 2)),
              child: Icon(Icons.emoji_events_rounded, color: workout.color, size: 46)))),
        const SizedBox(height: 18),
        Text('Workout Complete! 🎉', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(workout.name, style: GoogleFonts.dmSans(color: workout.color, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _StatCol2(Icons.timer_rounded, elapsed, 'Duration', workout.color)),
          Expanded(child: _StatCol2(Icons.fitness_center_rounded, '${workout.exercises.length}', 'Exercises', workout.color)),
          Expanded(child: _StatCol2(Icons.local_fire_department_rounded, '~${workout.calories}', 'Calories', workout.color)),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: onDone,
            style: OutlinedButton.styleFrom(side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text('Done', style: GoogleFonts.dmSans(color: Colors.white60, fontWeight: FontWeight.w700)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: onShare,
            style: ElevatedButton.styleFrom(backgroundColor: workout.color, foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text('Share 🎉', style: GoogleFonts.dmSans(fontWeight: FontWeight.w900)))),
        ]),
      ])));
}

class _StatCol2 extends StatelessWidget {
  final IconData icon; final String val, label; final Color color;
  const _StatCol2(this.icon, this.val, this.label, this.color);
  @override
  Widget build(BuildContext ctx) => Column(children: [
    Icon(icon, color: color, size: 20),
    const SizedBox(height: 5),
    Text(val, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
    Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11)),
  ]);
}
