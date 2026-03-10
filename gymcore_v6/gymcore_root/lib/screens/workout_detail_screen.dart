import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/workout_model.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutInfo workout;
  const WorkoutDetailScreen({super.key, required this.workout});
  @override State<WorkoutDetailScreen> createState() => _WDS();
}

class _WDS extends State<WorkoutDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700))..forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  WorkoutInfo get w => widget.workout;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kDark,
    body: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero header ────────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: kDark,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.black45, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18)),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    w.color.withOpacity(0.25), kDark],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Stack(children: [
                // Background icon watermark
                Positioned(right: -30, top: 30,
                  child: Icon(w.icon, color: w.color.withOpacity(0.07), size: 220)),
                // Content
                SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + level pills
                      Row(children: [
                        _Pill(w.category, w.color, bg: w.color.withOpacity(0.2)),
                        const SizedBox(width: 8),
                        _Pill(w.level, Colors.white54,
                            bg: Colors.white.withOpacity(0.08)),
                      ]),
                      const SizedBox(height: 12),
                      Text(w.name, style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 28,
                          fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 10),
                      Text(w.description, style: GoogleFonts.inter(
                          color: Colors.white60, fontSize: 13, height: 1.5),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      // Stats row
                      Row(children: [
                        _StatBubble(Icons.timer_outlined,
                            '${w.durationMins} min', w.color),
                        const SizedBox(width: 12),
                        _StatBubble(Icons.local_fire_department_rounded,
                            '${w.calories} cal', Colors.white54),
                        const SizedBox(width: 12),
                        _StatBubble(Icons.fitness_center_rounded,
                            '${w.exercises.length} exercises', Colors.white54),
                      ]),
                    ]),
                )),
              ]),
            ),
          ),
        ),

        // ── Start button + exercises ───────────────────────────────────────
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: _PulsingStartButton(color: w.color, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                ActiveWorkoutScreen(workout: w)));
          }),
        )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          child: Row(children: [
            Text('Exercises', style: GoogleFonts.inter(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('${w.exercises.length} total', style: GoogleFonts.inter(
                color: Colors.white38, fontSize: 13)),
          ]),
        )),

        // ── Exercise cards ─────────────────────────────────────────────────
        SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) => _ExerciseCard(
              ex: w.exercises[i],
              index: i,
              accent: w.color,
              delay: i * 70),
          childCount: w.exercises.length,
        )),

        const SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
    ),
  );
}

// ── Pulsing START button ──────────────────────────────────────────────────────
class _PulsingStartButton extends StatefulWidget {
  final Color color; final VoidCallback onTap;
  const _PulsingStartButton({required this.color, required this.onTap});
  @override State<_PulsingStartButton> createState() => _PSBState();
}
class _PSBState extends State<_PulsingStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;
  bool _pressed = false;
  @override void initState() { super.initState();
    _glow = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1500))..repeat(reverse: true); }
  @override void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _glow,
    builder: (_, child) => GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
                color: widget.color.withOpacity(0.25 + _glow.value * 0.2),
                blurRadius: 24 + _glow.value * 16, offset: const Offset(0, 8))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 30),
            const SizedBox(width: 10),
            Text('START WORKOUT', style: GoogleFonts.inter(
                color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18,
                letterSpacing: 1)),
          ]),
        ),
      ),
    ),
  );
}

// ── Exercise card with expandable detail ──────────────────────────────────────
class _ExerciseCard extends StatefulWidget {
  final ExerciseModel ex; final int index, delay; final Color accent;
  const _ExerciseCard({required this.ex, required this.index,
      required this.accent, required this.delay});
  @override State<_ExerciseCard> createState() => _ExerciseCardState();
}
class _ExerciseCardState extends State<_ExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _enter;
  bool _expanded = false;

  @override void initState() {
    super.initState();
    _enter = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _enter.forward();
    });
  }
  @override void dispose() { _enter.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _enter,
    builder: (_, child) {
      final t = CurvedAnimation(parent: _enter, curve: Curves.easeOut).value;
      return Opacity(opacity: t,
          child: Transform.translate(offset: Offset(0, (1-t)*24), child: child));
    },
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _expanded
                  ? widget.accent.withOpacity(0.5)
                  : Colors.white.withOpacity(0.07),
              width: _expanded ? 1.5 : 1,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // Step number
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: widget.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('${widget.index + 1}',
                      style: GoogleFonts.inter(color: widget.accent,
                          fontWeight: FontWeight.w900, fontSize: 13)))),
                const SizedBox(width: 12),
                // Exercise icon circle
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: widget.ex.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: widget.ex.color.withOpacity(0.25))),
                  child: Icon(widget.ex.icon,
                      color: widget.ex.color, size: 24)),
                const SizedBox(width: 14),
                // Name + muscle
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.ex.name, style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w700,
                      fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(widget.ex.muscle, style: GoogleFonts.inter(
                      color: Colors.white38, fontSize: 11), maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ])),
                // Sets × Reps
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    '${widget.ex.sets}×${widget.ex.reps}${widget.ex.isTime ? 's' : ''}',
                    style: GoogleFonts.inter(
                        color: widget.accent,
                        fontWeight: FontWeight.w900, fontSize: 17)),
                  Text(widget.ex.isTime ? 'sets×sec' : 'sets×reps',
                      style: GoogleFonts.inter(
                          color: Colors.white28, fontSize: 9)),
                ]),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _expanded ? widget.accent : Colors.white38,
                      size: 22)),
              ]),
            ),

            // ── Expanded detail ───────────────────────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _ExerciseDetail(ex: widget.ex, accent: widget.accent),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 350),
              sizeCurve: Curves.easeInOut,
            ),
          ]),
        ),
      ),
    ),
  );
}

// ── Expanded exercise details ─────────────────────────────────────────────────
class _ExerciseDetail extends StatelessWidget {
  final ExerciseModel ex; final Color accent;
  const _ExerciseDetail({required this.ex, required this.accent});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(color: Colors.white12, height: 1),
      const SizedBox(height: 16),

      // Quick stats row
      Row(children: [
        _QuickStat(Icons.repeat_rounded, '${ex.sets} Sets', accent),
        const SizedBox(width: 10),
        _QuickStat(
            ex.isTime ? Icons.timer_rounded : Icons.numbers_rounded,
            ex.isTime ? '${ex.reps}s each' : '${ex.reps} reps', Colors.white54),
        const SizedBox(width: 10),
        _QuickStat(Icons.pause_circle_outline_rounded,
            '${ex.restSeconds}s rest', Colors.white54),
      ]),
      const SizedBox(height: 16),

      // Equipment badge
      Row(children: [
        const Icon(Icons.sports_gymnastics_rounded,
            color: Colors.white38, size: 15),
        const SizedBox(width: 6),
        Text('Equipment: ', style: GoogleFonts.inter(
            color: Colors.white38, fontSize: 13)),
        Flexible(child: Text(ex.equipment, style: GoogleFonts.inter(
            color: Colors.white70, fontSize: 13,
            fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 14),

      // How-to section
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.15))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.menu_book_rounded, color: accent, size: 14),
            const SizedBox(width: 6),
            Text('HOW TO DO IT', style: GoogleFonts.inter(
                color: accent, fontSize: 11,
                fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 10),
          Text(ex.instruction, style: GoogleFonts.inter(
              color: Colors.white70, fontSize: 13, height: 1.65)),
        ]),
      ),
      const SizedBox(height: 14),

      // Set breakdown chips
      Text('SETS BREAKDOWN', style: GoogleFonts.inter(
          color: Colors.white28, fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8,
        children: List.generate(ex.sets, (i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.25))),
          child: Text('Set ${i+1}  ·  ${ex.reps}${ex.isTime ? 's' : ' reps'}',
              style: GoogleFonts.inter(color: accent,
                  fontWeight: FontWeight.w700, fontSize: 12)),
        ))),
    ]),
  );
}

class _QuickStat extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _QuickStat(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.inter(
          color: color, fontSize: 11, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center),
    ]),
  ));
}

class _Pill extends StatelessWidget {
  final String label; final Color fg, bg;
  const _Pill(this.label, this.fg, {required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.inter(
        color: fg, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)));
}

class _StatBubble extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _StatBubble(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(
          color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
}
