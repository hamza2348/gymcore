import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'auth/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _S();
}

class _S extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logo, _text, _dots;
  late Animation<double> _logoScale, _logoFade, _textFade, _textY;

  @override
  void initState() {
    super.initState();
    _logo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _text = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _dots = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();

    _logoScale = Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _logo, curve: Curves.elasticOut));
    _logoFade  = CurvedAnimation(parent: _logo, curve: Curves.easeIn);
    _textFade  = CurvedAnimation(parent: _text, curve: Curves.easeIn);
    _textY     = Tween(begin: 24.0, end: 0.0).animate(CurvedAnimation(parent: _text, curve: Curves.easeOut));

    _logo.forward().then((_) => _text.forward());
    Future.delayed(const Duration(milliseconds: 3000), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const SignupScreen()),
      transitionDuration: const Duration(milliseconds: 700),
    ));
  }

  @override void dispose() { _logo.dispose(); _text.dispose(); _dots.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: kDark,
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Animated logo ring
      ScaleTransition(scale: _logoScale, child: FadeTransition(opacity: _logoFade,
        child: _GlowRing(child: const Icon(Icons.fitness_center_rounded, color: kGreen, size: 52)))),
      const SizedBox(height: 40),
      // App name
      AnimatedBuilder(animation: _text, builder: (_, __) => Opacity(
        opacity: _textFade.value,
        child: Transform.translate(offset: Offset(0, _textY.value), child: Column(children: [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'GYM', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 4)),
            TextSpan(text: 'CORE', style: GoogleFonts.dmSans(color: kGreen, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 4)),
          ])),
          const SizedBox(height: 6),
          Text('TRAIN SMARTER. LIVE STRONGER.', style: GoogleFonts.dmSans(color: Colors.white30, fontSize: 11, letterSpacing: 3)),
        ])))),
      const SizedBox(height: 72),
      AnimatedBuilder(animation: _dots, builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final on = (_dots.value * 3).floor() % 3 == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: on ? 28 : 8, height: 8,
            decoration: BoxDecoration(
              color: on ? kGreen : Colors.white20,
              borderRadius: BorderRadius.circular(4)));
        }))),
    ])),
  );
}

class _GlowRing extends StatefulWidget {
  final Widget child;
  const _GlowRing({required this.child});
  @override State<_GlowRing> createState() => _GlowRingState();
}
class _GlowRingState extends State<_GlowRing> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => AnimatedBuilder(animation: _c, builder: (_, child) =>
    Container(width: 110, height: 110,
      decoration: BoxDecoration(shape: BoxShape.circle, color: kCard,
        border: Border.all(color: kGreen.withOpacity(0.4 + _c.value * 0.4), width: 2),
        boxShadow: [BoxShadow(color: kGreen.withOpacity(0.15 + _c.value * 0.2), blurRadius: 30 + _c.value * 20)]),
      child: Center(child: widget.child)));
}
