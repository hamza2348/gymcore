import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String name, email, password;
  const OnboardingScreen({super.key,
      required this.name, required this.email, required this.password});
  @override State<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  String _gender    = '';
  double _weight    = 70;
  int    _age       = 25;
  String _goal      = '';

  final _goals = [
    'Lose Weight', 'Build Muscle', 'Get Fitter',
    'Improve Endurance', 'Stay Healthy'
  ];

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  void _next() {
    if (_page == 0 && _gender.isEmpty) { _hint('Please choose your gender'); return; }
    if (_page == 2 && _goal.isEmpty)   { _hint('Please select a fitness goal'); return; }
    if (_page < 3) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic);
    } else {
      _finish();
    }
  }

  void _hint(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.dmSans(color: Colors.black)),
      backgroundColor: kGreen, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2)));
  }

  void _finish() {
    final err = AuthService().signUp(
        widget.name, widget.email, widget.password,
        _gender, _weight, _goal, _age);
    if (err != null) { _hint(err); return; }
    Navigator.pushAndRemoveUntil(context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => FadeTransition(
              opacity: a, child: const MainScreen()),
          transitionDuration: const Duration(milliseconds: 600)),
        (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kDark,
    body: SafeArea(child: Column(children: [
      // Progress bar + skip
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          ...List.generate(4, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 6),
            width: _page == i ? 24 : 8, height: 8,
            decoration: BoxDecoration(
              color: _page == i
                  ? kGreen
                  : (_page > i ? kGreen.withOpacity(0.35) : Colors.white20),
              borderRadius: BorderRadius.circular(4)))),
          const Spacer(),
          TextButton(
            onPressed: () {
              if (_gender.isNotEmpty) _finish();
              else Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const MainScreen()));
            },
            child: Text('Skip',
                style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14))),
        ])),

      Expanded(child: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          _GenderPage(
            selected: _gender,
            onSelect: (g) => setState(() => _gender = g),
            onNext: _next),
          _WeightAgePage(
            weight: _weight, age: _age,
            onWeight: (v) => setState(() => _weight = v),
            onAge: (v) => setState(() => _age = v),
            onNext: _next),
          _GoalPage(
            selected: _goal, goals: _goals,
            onSelect: (g) => setState(() => _goal = g),
            onNext: _next),
          _SummaryPage(
            name: widget.name, gender: _gender,
            weight: _weight, age: _age, goal: _goal,
            onFinish: _finish),
        ])),
    ])));
}

// ── Page 1: Gender ────────────────────────────────────────────────────────────
class _GenderPage extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  final VoidCallback onNext;
  const _GenderPage({required this.selected, required this.onSelect,
      required this.onNext});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'What\'s your gender?',
    subtitle: 'Helps us personalise your fitness plan',
    child: Column(children: [
      const SizedBox(height: 36),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _GenderCard(label: 'Male',   emoji: '💪',
            selected: selected == 'male',
            onTap: () => onSelect('male')),
        const SizedBox(width: 20),
        _GenderCard(label: 'Female', emoji: '🌸',
            selected: selected == 'female',
            onTap: () => onSelect('female')),
      ]),
      const SizedBox(height: 48),
      _NextBtn(onTap: onNext, enabled: selected.isNotEmpty),
    ]));
}

class _GenderCard extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _GenderCard({required this.label, required this.emoji,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      width: 148, height: 172,
      decoration: BoxDecoration(
        color: selected ? kGreen.withOpacity(0.1) : kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: selected ? kGreen : kBorder,
            width: selected ? 2 : 1),
        boxShadow: selected
            ? [BoxShadow(color: kGreen.withOpacity(0.18), blurRadius: 20)]
            : []),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedScale(
          scale: selected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 260),
          child: Text(emoji, style: const TextStyle(fontSize: 50))),
        const SizedBox(height: 14),
        Text(label, style: GoogleFonts.dmSans(
            color: selected ? kGreen : Colors.white60,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 16)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          width: selected ? 28 : 0, height: 3,
          decoration: BoxDecoration(
              color: kGreen, borderRadius: BorderRadius.circular(2))),
      ])));
}

// ── Page 2: Weight & Age ──────────────────────────────────────────────────────
class _WeightAgePage extends StatelessWidget {
  final double weight;
  final int age;
  final void Function(double) onWeight;
  final void Function(int) onAge;
  final VoidCallback onNext;
  const _WeightAgePage({required this.weight, required this.age,
      required this.onWeight, required this.onAge, required this.onNext});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'Your body stats',
    subtitle: 'Used to calculate your fitness metrics',
    child: Column(children: [
      const SizedBox(height: 24),
      _SliderCard(label: 'Weight', value: weight, unit: 'kg',
          min: 40, max: 150, divisions: 110, color: kGreen,
          display: weight.toStringAsFixed(1),
          onChanged: onWeight),
      const SizedBox(height: 14),
      _SliderCard(label: 'Age', value: age.toDouble(), unit: 'yrs',
          min: 14, max: 80, divisions: 66, color: const Color(0xFF00E5FF),
          display: '$age',
          onChanged: (v) => onAge(v.round())),
      const SizedBox(height: 36),
      _NextBtn(onTap: onNext, enabled: true),
    ]));
}

class _SliderCard extends StatelessWidget {
  final String label, unit, display;
  final double value, min, max;
  final int divisions;
  final Color color;
  final void Function(double) onChanged;
  const _SliderCard({required this.label, required this.value,
      required this.unit, required this.display,
      required this.min, required this.max, required this.divisions,
      required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
    decoration: BoxDecoration(color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(
          color: Colors.white54, fontSize: 12, letterSpacing: 1.5)),
      const SizedBox(height: 6),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, children: [
        Text(display, style: GoogleFonts.dmSans(
            color: Colors.white, fontSize: 42, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Text(unit, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 16)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbColor: color,
          activeTrackColor: color,
          inactiveTrackColor: color.withOpacity(0.12),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          trackHeight: 4),
        child: Slider(
            value: value, min: min, max: max,
            divisions: divisions, onChanged: onChanged)),
    ]));
}

// ── Page 3: Goal ──────────────────────────────────────────────────────────────
class _GoalPage extends StatelessWidget {
  final String selected;
  final List<String> goals;
  final void Function(String) onSelect;
  final VoidCallback onNext;
  const _GoalPage({required this.selected, required this.goals,
      required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'What\'s your goal?',
    subtitle: 'Workouts will be tailored to this',
    child: Column(children: [
      const SizedBox(height: 20),
      ...goals.map((g) => _GoalTile(
          label: g, icon: _icon(g),
          selected: selected == g,
          onTap: () => onSelect(g))),
      const SizedBox(height: 20),
      _NextBtn(onTap: onNext, enabled: selected.isNotEmpty),
    ]));

  static IconData _icon(String g) {
    if (g.contains('Lose'))      return Icons.trending_down_rounded;
    if (g.contains('Build'))     return Icons.fitness_center_rounded;
    if (g.contains('Fitter'))    return Icons.bolt_rounded;
    if (g.contains('Endurance')) return Icons.directions_run_rounded;
    return Icons.favorite_rounded;
  }
}

class _GoalTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GoalTile({required this.label, required this.icon,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: selected ? kGreen.withOpacity(0.1) : kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: selected ? kGreen : kBorder,
            width: selected ? 1.5 : 1)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: selected
                ? kGreen.withOpacity(0.15)
                : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon,
              color: selected ? kGreen : Colors.white38, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: GoogleFonts.dmSans(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 15))),
        AnimatedScale(
          scale: selected ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
                color: kGreen, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: Colors.black, size: 14))),
      ])));
}

// ── Page 4: Summary ───────────────────────────────────────────────────────────
class _SummaryPage extends StatelessWidget {
  final String name, gender, goal;
  final double weight;
  final int age;
  final VoidCallback onFinish;
  const _SummaryPage({required this.name, required this.gender,
      required this.goal, required this.weight,
      required this.age, required this.onFinish});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'You\'re all set!',
    subtitle: 'Here\'s your profile summary',
    child: Column(children: [
      const SizedBox(height: 24),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 900),
        curve: Curves.elasticOut,
        builder: (_, v, __) => Transform.scale(scale: v,
          child: Container(
            width: 88, height: 88,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: kGreen.withOpacity(0.12),
                border: Border.all(color: kGreen, width: 2)),
            child: Center(child: Text(
                gender == 'female' ? '🌸' : '💪',
                style: const TextStyle(fontSize: 42)))))),
      const SizedBox(height: 14),
      Text(name, style: GoogleFonts.dmSans(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 24),
      _SummaryRow(Icons.wc_rounded, 'Gender',
          gender == 'female' ? 'Female' : 'Male'),
      _SummaryRow(Icons.monitor_weight_outlined, 'Weight',
          '${weight.toStringAsFixed(1)} kg'),
      _SummaryRow(Icons.cake_outlined, 'Age', '$age years'),
      _SummaryRow(Icons.flag_rounded, 'Goal',
          goal.isEmpty ? 'Not set' : goal),
      const SizedBox(height: 28),
      _NextBtn(onTap: onFinish, enabled: true,
          label: 'START MY JOURNEY  🚀'),
    ]));
}

class _SummaryRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _SummaryRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder)),
    child: Row(children: [
      Icon(icon, color: kGreen, size: 18),
      const SizedBox(width: 12),
      Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14)),
      const Spacer(),
      Text(value, style: GoogleFonts.dmSans(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
    ]));
}

// ── Shared page wrapper ───────────────────────────────────────────────────────
class _PageShell extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _PageShell({required this.title, required this.subtitle,
      required this.child});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.dmSans(
          color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(subtitle, style: GoogleFonts.dmSans(
          color: Colors.white38, fontSize: 14)),
      child,
    ]));
}

class _NextBtn extends StatefulWidget {
  final VoidCallback onTap;
  final bool enabled;
  final String? label;
  const _NextBtn({required this.onTap, required this.enabled, this.label});
  @override State<_NextBtn> createState() => _NextBtnState();
}
class _NextBtnState extends State<_NextBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100)); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) { _c.reverse(); if (widget.enabled) widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, child) =>
          Transform.scale(scale: 1 - _c.value * 0.03, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: widget.enabled ? kGreen : kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: widget.enabled ? kGreen : kBorder),
          boxShadow: widget.enabled
              ? [BoxShadow(color: kGreen.withOpacity(0.25),
                  blurRadius: 16, offset: const Offset(0, 6))]
              : []),
        child: Center(child: Text(
            widget.label ?? 'CONTINUE',
            style: GoogleFonts.dmSans(
                color: widget.enabled ? Colors.black : Colors.white38,
                fontWeight: FontWeight.w900,
                fontSize: 15, letterSpacing: 0.5))))));
}
