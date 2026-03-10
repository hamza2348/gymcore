import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import 'workout_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DS();
}

class _DS extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _ring, _cards;
  UserProfile? get user => AuthService().currentUser;

  @override
  void initState() {
    super.initState();
    _ring  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _cards = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future.delayed(const Duration(milliseconds: 150), () { if(mounted){ _ring.forward(); _cards.forward(); }});
  }
  @override void dispose() { _ring.dispose(); _cards.dispose(); super.dispose(); }

  int get _weeklyWorkouts {
    final u = user; if (u == null) return 0;
    final now = DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      if (u.workoutCalendar[AuthService.keyFor(d)] == true) count++;
    }
    return count;
  }

  int get _totalCalories {
    final u = user; if (u == null) return 0;
    return u.workoutCalories.values.fold(0, (a, b) => a + b);
  }

  int get _totalMins {
    final u = user; if (u == null) return 0;
    return u.workoutDuration.values.fold(0, (a, b) => a + b);
  }

  double get _progressPct {
    // progress = (weeklyWorkouts / 5) capped at 1
    return (_weeklyWorkouts / 5).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext ctx) {
    final u = user;
    final hour = DateTime.now().hour;
    final greet = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final genderEmoji = (u?.gender == 'female') ? '🌸' : '💪';

    return SafeArea(child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ─────────────────────────────────────────────────────────
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$greet $genderEmoji', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13)),
            Text(u?.firstName ?? 'Athlete', style: GoogleFonts.dmSans(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          ])),
          _IconBtn(Icons.notifications_outlined, onTap: () {}),
        ]),
        const SizedBox(height: 24),

        // ── Weekly Progress Ring ────────────────────────────────────────────
        AnimatedBuilder(animation: _ring, builder: (_, __) {
          final t = CurvedAnimation(parent: _ring, curve: Curves.easeOutCubic).value;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kGreen.withOpacity(0.12), kCard],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kGreen.withOpacity(0.2))),
            child: Row(children: [
              SizedBox(width: 110, height: 110,
                child: Stack(alignment: Alignment.center, children: [
                  CustomPaint(
                    painter: _ArcPainter(progress: t * _progressPct),
                    size: const Size(110, 110)),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${_weeklyWorkouts}', style: GoogleFonts.dmSans(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1)),
                    Text('/ 5', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12)),
                  ]),
                ])),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Weekly Goal', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${(_progressPct * 100).toInt()}% complete', style: GoogleFonts.dmSans(color: kGreen, fontSize: 13)),
                const SizedBox(height: 12),
                _MiniStat(Icons.local_fire_department_rounded, '$_totalCalories cal', 'Total burned'),
                const SizedBox(height: 6),
                _MiniStat(Icons.timer_rounded, '$_totalMins min', 'Total time'),
                const SizedBox(height: 6),
                _MiniStat(Icons.emoji_events_rounded, '${u?.completedWorkouts.length ?? 0}', 'Workouts done'),
              ])),
            ]));
        }),
        const SizedBox(height: 20),

        // ── User info strip ────────────────────────────────────────────────
        if (u != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _InfoChip('${u.weight.toStringAsFixed(0)} kg', 'Weight'),
            _Divider(),
            _InfoChip('${u.age}', 'Age'),
            _Divider(),
            _InfoChip(u.fitnessGoal.split(' ').first, 'Goal'),
            _Divider(),
            _InfoChip(u.gender == 'female' ? 'Female' : 'Male', 'Gender'),
          ])),
        const SizedBox(height: 24),

        // ── Quick start ─────────────────────────────────────────────────────
        Row(children: [
          Text('Quick Start', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(onTap: () {}, child: Text('See all', style: GoogleFonts.dmSans(color: kGreen, fontSize: 13))),
        ]),
        const SizedBox(height: 12),

        AnimatedBuilder(animation: _cards, builder: (_, __) {
          final v = CurvedAnimation(parent: _cards, curve: Curves.easeOut).value;
          return Opacity(opacity: v,
            child: Transform.translate(offset: Offset(0, (1-v)*20),
              child: SizedBox(height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: WorkoutLibrary.all.length,
                  itemBuilder: (_, i) {
                    final w = WorkoutLibrary.all[i];
                    return _WorkoutChip(workout: w,
                      onTap: () => Navigator.push(ctx, _fade(WorkoutDetailScreen(workout: w))));
                  }))));
        }),
        const SizedBox(height: 24),

        // ── Recommended ─────────────────────────────────────────────────────
        Text('Recommended For You', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        ...WorkoutLibrary.all.take(3).toList().asMap().entries.map((e) {
          final w = e.value;
          return AnimatedBuilder(
            animation: _cards,
            builder: (_, child) {
              final v = CurvedAnimation(parent: _cards, curve: Interval(0.1 * e.key, 1.0, curve: Curves.easeOut)).value;
              return Opacity(opacity: v,
                child: Transform.translate(offset: Offset(0, (1-v)*20), child: child));
            },
            child: _RecommendedCard(workout: w,
                onTap: () => Navigator.push(ctx, _fade(WorkoutDetailScreen(workout: w)))));
        }),
      ]));
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: page),
    transitionDuration: const Duration(milliseconds: 350));
}

class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width/2, size.height/2);
    final r = size.width/2 - 8;
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = 10);
    if (progress > 0)
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi/2, 2*pi*progress, false,
          Paint()..color = kGreen..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round);
    // dot tip
    if (progress > 0.02) {
      final ang = -pi/2 + 2*pi*progress;
      final dot = Offset(c.dx + r*cos(ang), c.dy + r*sin(ang));
      canvas.drawCircle(dot, 6, Paint()..color = Colors.white);
      canvas.drawCircle(dot, 4, Paint()..color = kGreen);
    }
  }
  @override bool shouldRepaint(_ArcPainter o) => o.progress != progress;
}

class _MiniStat extends StatelessWidget {
  final IconData icon; final String val, sub;
  const _MiniStat(this.icon, this.val, this.sub);
  @override
  Widget build(BuildContext ctx) => Row(children: [
    Icon(icon, color: kGreen, size: 14),
    const SizedBox(width: 6),
    Text(val, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
    const SizedBox(width: 4),
    Text(sub, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11)),
  ]);
}

class _InfoChip extends StatelessWidget {
  final String val, label;
  const _InfoChip(this.val, this.label);
  @override
  Widget build(BuildContext ctx) => Column(children: [
    Text(val, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
    const SizedBox(height: 2),
    Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 10)),
  ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Container(width: 1, height: 30, color: kBorder);
}

class _WorkoutChip extends StatefulWidget {
  final WorkoutInfo workout; final VoidCallback onTap;
  const _WorkoutChip({required this.workout, required this.onTap});
  @override State<_WorkoutChip> createState() => _WCState();
}
class _WCState extends State<_WorkoutChip> {
  bool _p = false;
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.only(right: 12),
      width: 130,
      transform: Matrix4.identity()..scale(_p ? 0.95 : 1.0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.workout.color.withOpacity(0.15), kCard],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.workout.color.withOpacity(0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(widget.workout.icon, color: widget.workout.color, size: 28),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.workout.name, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text('${widget.workout.durationMins} min', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 10)),
        ]),
      ])));
}

class _RecommendedCard extends StatefulWidget {
  final WorkoutInfo workout; final VoidCallback onTap;
  const _RecommendedCard({required this.workout, required this.onTap});
  @override State<_RecommendedCard> createState() => _RCState();
}
class _RCState extends State<_RecommendedCard> {
  bool _p = false;
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.only(bottom: 12),
      transform: Matrix4.identity()..scale(_p ? 0.97 : 1.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder)),
      child: Row(children: [
        Container(width: 56, height: 56,
          decoration: BoxDecoration(color: widget.workout.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16)),
          child: Icon(widget.workout.icon, color: widget.workout.color, size: 26)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.workout.name, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text('${widget.workout.exercises.length} exercises · ${widget.workout.durationMins} min · ${widget.workout.level}',
              style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(10)),
          child: Text('Start', style: GoogleFonts.dmSans(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12))),
      ])));
}

class _IconBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _IconBtn(this.icon, {required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Icon(icon, color: Colors.white54, size: 20)));
}
