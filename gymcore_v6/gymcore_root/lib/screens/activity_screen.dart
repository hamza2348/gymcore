import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override State<ActivityScreen> createState() => _AS();
}

class _AS extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  UserProfile? get user => AuthService().currentUser;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  // Build 4-week calendar data
  List<_DayData> get _calendarData {
    final now = DateTime.now();
    final u = user;
    return List.generate(28, (i) {
      final d = now.subtract(Duration(days: 27 - i));
      final key = AuthService.keyFor(d);
      final done = u?.workoutCalendar[key] == true;
      final cals = u?.workoutCalories[key] ?? 0;
      final mins = u?.workoutDuration[key] ?? 0;
      return _DayData(date: d, done: done, calories: cals, minutes: mins);
    });
  }

  // Week bar chart data (last 7 days)
  List<_BarData> get _weekBars {
    final now = DateTime.now();
    final u = user;
    const days = ['M','T','W','T','F','S','S'];
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final key = AuthService.keyFor(d);
      final mins = u?.workoutDuration[key] ?? 0;
      final done = u?.workoutCalendar[key] == true;
      return _BarData(label: days[d.weekday - 1], minutes: mins, done: done);
    });
  }

  int get _thisWeekWorkouts {
    final now = DateTime.now();
    final u = user;
    int c = 0;
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      if (u?.workoutCalendar[AuthService.keyFor(d)] == true) c++;
    }
    return c;
  }

  @override
  Widget build(BuildContext ctx) {
    final cal = _calendarData;
    final bars = _weekBars;
    final done = cal.where((d) => d.done).toList();
    final totalCals = done.fold(0, (s, d) => s + d.calories);
    final totalMins = done.fold(0, (s, d) => s + d.minutes);

    return SafeArea(child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Header
        Text('Activity', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('Your fitness journey', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 20),

        // This week summary cards
        AnimatedBuilder(animation: _ctrl, builder: (_, __) {
          final v = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut).value;
          return Opacity(opacity: v, child: Transform.translate(offset: Offset(0,(1-v)*20),
            child: Row(children: [
              Expanded(child: _SummaryTile('$_thisWeekWorkouts', 'Workouts\nthis week', Icons.fitness_center_rounded, kGreen)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile('$totalMins', 'Minutes\nthis month', Icons.timer_rounded, const Color(0xFF00E5FF))),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile('$totalCals', 'Calories\nthis month', Icons.local_fire_department_rounded, const Color(0xFFFF6B35))),
            ])));
        }),
        const SizedBox(height: 24),

        // Weekly bar chart
        Text('This Week', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        AnimatedBuilder(animation: _ctrl, builder: (_, __) {
          final v = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut).value;
          return Container(
            height: 160,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
            child: _BarChart(bars: bars, animT: v));
        }),
        const SizedBox(height: 24),

        // 4-week Calendar
        Row(children: [
          Text('Monthly Tracker', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('${done.length} days active', style: GoogleFonts.dmSans(color: kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
          child: Column(children: [
            // Day labels
            Row(children: ['M','T','W','T','F','S','S'].map((d) => Expanded(child: Center(
              child: Text(d, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600))
            ))).toList()),
            const SizedBox(height: 10),
            // 4 weeks
            ...List.generate(4, (week) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: List.generate(7, (day) {
                final idx = week * 7 + day;
                if (idx >= cal.length) return const Expanded(child: SizedBox());
                final dd = cal[idx];
                final isToday = AuthService.keyFor(dd.date) == AuthService.keyFor(DateTime.now());
                return Expanded(child: GestureDetector(
                  onTap: () => dd.done ? _showDayDetail(ctx, dd) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 32,
                    decoration: BoxDecoration(
                      color: dd.done ? kGreen : (isToday ? kGreen.withOpacity(0.15) : Colors.white.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: kGreen.withOpacity(0.6)) : null),
                    child: Center(child: dd.done
                        ? const Icon(Icons.check_rounded, color: Colors.black, size: 14)
                        : Text('${dd.date.day}', style: GoogleFonts.dmSans(
                            color: isToday ? kGreen : Colors.white30, fontSize: 10))))));
              })))),
          ])),
        const SizedBox(height: 20),

        // Recent workouts
        if (user?.completedWorkouts.isNotEmpty == true) ...[
          Text('Completed Workouts', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...user!.completedWorkouts.reversed.take(5).map((w) => _CompletedTile(name: w)),
        ],

        if (user?.completedWorkouts.isEmpty != false) _EmptyState(),
      ]));
  }

  void _showDayDetail(BuildContext ctx, _DayData d) {
    showModalBottomSheet(context: ctx, backgroundColor: kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Icon(Icons.check_circle_rounded, color: kGreen, size: 48),
          const SizedBox(height: 12),
          Text('${d.date.day}/${d.date.month}/${d.date.year}',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _StatCol(Icons.timer_rounded, '${d.minutes} min', 'Duration'),
            _StatCol(Icons.local_fire_department_rounded, '${d.calories} cal', 'Burned'),
          ]),
          const SizedBox(height: 20),
        ])));
  }
}

class _DayData {
  final DateTime date; final bool done; final int calories, minutes;
  const _DayData({required this.date, required this.done, required this.calories, required this.minutes});
}

class _BarData {
  final String label; final int minutes; final bool done;
  const _BarData({required this.label, required this.minutes, required this.done});
}

class _BarChart extends StatelessWidget {
  final List<_BarData> bars; final double animT;
  const _BarChart({required this.bars, required this.animT});
  @override
  Widget build(BuildContext ctx) {
    final maxMins = bars.isEmpty ? 1 : bars.map((b) => b.minutes).fold(0, max).clamp(1, 999);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bars.map((b) {
        final frac = (b.minutes / maxMins).clamp(0.0, 1.0) * animT;
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (b.done) Text('${b.minutes}', style: GoogleFonts.dmSans(
                color: kGreen, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: frac > 0 ? 80 * frac + 4 : 4,
              decoration: BoxDecoration(
                color: b.done ? kGreen : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 6),
            Text(b.label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11)),
          ])));
      }).toList());
  }
}

class _SummaryTile extends StatelessWidget {
  final String val, label; final IconData icon; final Color color;
  const _SummaryTile(this.val, this.label, this.icon, this.color);
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 8),
      Text(val, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 10), maxLines: 2),
    ]));
}

class _CompletedTile extends StatelessWidget {
  final String name;
  const _CompletedTile({required this.name});
  @override
  Widget build(BuildContext ctx) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
    child: Row(children: [
      Container(width: 10, height: 10, decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
      const SizedBox(width: 12),
      Text(name, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
      const Spacer(),
      const Icon(Icons.check_circle_rounded, color: kGreen, size: 18),
    ]));
}

class _StatCol extends StatelessWidget {
  final IconData icon; final String val, label;
  const _StatCol(this.icon, this.val, this.label);
  @override
  Widget build(BuildContext ctx) => Column(children: [
    Icon(icon, color: kGreen, size: 24),
    const SizedBox(height: 6),
    Text(val, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12)),
  ]);
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => Center(child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [
      const Icon(Icons.directions_run_rounded, color: Colors.white20, size: 60),
      const SizedBox(height: 16),
      Text('No workouts yet', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('Complete a workout to see your progress here',
          style: GoogleFonts.dmSans(color: Colors.white24, fontSize: 13), textAlign: TextAlign.center),
    ])));
}
