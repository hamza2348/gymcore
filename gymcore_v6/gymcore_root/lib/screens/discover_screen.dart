import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/workout_model.dart';
import 'workout_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override State<DiscoverScreen> createState() => _Disc();
}

class _Disc extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  String _search = '';
  int _tab = 0;
  final _tabs = ['All', 'Strength', 'Cardio', 'Core', 'Flex'];

  List<WorkoutInfo> get _filtered {
    var list = WorkoutLibrary.all;
    if (_tab == 1) list = list.where((w) => w.category == 'STRENGTH' || w.category == 'WORKOUT').toList();
    if (_tab == 2) list = list.where((w) => w.category == 'CARDIO').toList();
    if (_tab == 3) list = list.where((w) => w.category == 'CORE' || w.category == 'CHALLENGE').toList();
    if (_tab == 4) list = list.where((w) => w.category == 'FLEXIBILITY').toList();
    if (_search.isNotEmpty) list = list.where((w) => w.name.toLowerCase().contains(_search.toLowerCase())).toList();
    return list;
  }

  @override void initState() { super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => SafeArea(
    child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20,16,20,0), child: Row(children: [
        Expanded(child: Text('Discover', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
          child: const Icon(Icons.tune_rounded, color: Colors.white54, size: 18)),
      ])),
      const SizedBox(height: 12),

      // Search
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(height: 46, decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
          child: TextField(onChanged: (v) => setState(() => _search = v),
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(hintText: 'Search workouts...', hintStyle: GoogleFonts.dmSans(color: Colors.white28),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white28, size: 20),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 13))))),
      const SizedBox(height: 14),

      // Featured
      if (_search.isEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AnimatedBuilder(animation: _ctrl, builder: (_, child) =>
          Opacity(opacity: _ctrl.value, child: Transform.translate(offset: Offset(0,(1-_ctrl.value)*16), child: child)),
          child: _FeaturedCard(workout: WorkoutLibrary.all.first,
              onTap: () => _go(ctx, WorkoutLibrary.all.first)))),
      if (_search.isEmpty) const SizedBox(height: 16),

      // Tabs
      SizedBox(height: 38, child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20),
        itemCount: _tabs.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: _tab == i ? kGreen : kCard,
                borderRadius: BorderRadius.circular(20), border: Border.all(color: _tab == i ? kGreen : kBorder)),
            child: Text(_tabs[i], style: GoogleFonts.dmSans(color: _tab == i ? Colors.black : Colors.white54,
                fontWeight: FontWeight.w700, fontSize: 12)))))),
      const SizedBox(height: 12),

      Expanded(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _filtered.isEmpty
            ? Center(child: Text('No workouts found', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 15)))
            : ListView.builder(
                key: ValueKey('$_tab$_search'),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _WorkoutRow(
                    workout: _filtered[i], delay: i * 55,
                    onTap: () => _go(ctx, _filtered[i]))))),
    ]));

  void _go(BuildContext ctx, WorkoutInfo w) => Navigator.push(ctx, PageRouteBuilder(
    pageBuilder: (_, a, __) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeIn), child: WorkoutDetailScreen(workout: w)),
    transitionDuration: const Duration(milliseconds: 350)));
}

class _FeaturedCard extends StatefulWidget {
  final WorkoutInfo workout; final VoidCallback onTap;
  const _FeaturedCard({required this.workout, required this.onTap});
  @override State<_FeaturedCard> createState() => _FCState();
}
class _FCState extends State<_FeaturedCard> with SingleTickerProviderStateMixin {
  late AnimationController _g; bool _p = false;
  @override void initState() { super.initState(); _g = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true); }
  @override void dispose() { _g.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedBuilder(animation: _g, builder: (_, child) =>
      AnimatedScale(scale: _p ? 0.97 : 1.0, duration: const Duration(milliseconds: 120),
        child: Container(height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [widget.workout.color.withOpacity(0.2 + _g.value * 0.05), kCard],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: widget.workout.color.withOpacity(0.2))),
          child: Stack(children: [
            Positioned(right: -20, top: -10,
                child: Icon(widget.workout.icon, color: widget.workout.color.withOpacity(0.08), size: 160)),
            Padding(padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: widget.workout.color, borderRadius: BorderRadius.circular(6)),
                  child: Text('FEATURED', style: GoogleFonts.dmSans(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))),
                const SizedBox(height: 8),
                Text(widget.workout.name, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${widget.workout.durationMins} min · ${widget.workout.exercises.length} exercises',
                      style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 12)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: widget.workout.color, size: 16),
                ]),
              ])),
          ])))));
}

class _WorkoutRow extends StatefulWidget {
  final WorkoutInfo workout; final int delay; final VoidCallback onTap;
  const _WorkoutRow({required this.workout, required this.delay, required this.onTap});
  @override State<_WorkoutRow> createState() => _WRState();
}
class _WRState extends State<_WorkoutRow> with SingleTickerProviderStateMixin {
  late AnimationController _enter; bool _p = false;
  @override void initState() { super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    Future.delayed(Duration(milliseconds: widget.delay), () { if(mounted) _enter.forward(); }); }
  @override void dispose() { _enter.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => AnimatedBuilder(
    animation: _enter,
    builder: (_, child) {
      final t = CurvedAnimation(parent: _enter, curve: Curves.easeOut).value;
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0,(1-t)*18), child: child));
    },
    child: GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedContainer(duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 12),
        transform: Matrix4.identity()..scale(_p ? 0.97 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
        child: Row(children: [
          Container(width: 60, height: 60,
            decoration: BoxDecoration(color: widget.workout.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16), border: Border.all(color: widget.workout.color.withOpacity(0.2))),
            child: Icon(widget.workout.icon, color: widget.workout.color, size: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.workout.name, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Row(children: [
              _Tag(widget.workout.level, widget.workout.color),
              const SizedBox(width: 6),
              _Tag('${widget.workout.durationMins} min', Colors.white38),
            ]),
            const SizedBox(height: 4),
            Text('${widget.workout.exercises.length} exercises · ~${widget.workout.calories} cal',
                style: GoogleFonts.dmSans(color: Colors.white30, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        ]))));
}

class _Tag extends StatelessWidget {
  final String l; final Color c;
  const _Tag(this.l, this.c);
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withOpacity(0.25))),
    child: Text(l, style: GoogleFonts.dmSans(color: c, fontSize: 10, fontWeight: FontWeight.w700)));
}
