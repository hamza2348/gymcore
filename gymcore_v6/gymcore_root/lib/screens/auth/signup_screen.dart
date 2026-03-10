import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../widgets/shared.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override State<SignupScreen> createState() => _SignupState();
}

class _SignupState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true, _loading = false;
  String? _error;
  late AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))..forward();
  }
  @override
  void dispose() {
    _enterCtrl.dispose();
    _name.dispose(); _email.dispose(); _pass.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _error = null);
    final n = _name.text.trim();
    final e = _email.text.trim();
    final p = _pass.text;
    if (n.isEmpty)      { setState(() => _error = 'Enter your full name'); return; }
    if (!e.contains('@')){ setState(() => _error = 'Enter a valid email'); return; }
    if (p.length < 6)   { setState(() => _error = 'Password must be 6+ characters'); return; }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, a, __) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: OnboardingScreen(name: n, email: e, password: p)),
      transitionDuration: const Duration(milliseconds: 500)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kDark,
    body: SafeArea(child: AnimatedBuilder(
      animation: _enterCtrl,
      builder: (_, child) => Opacity(
          opacity: CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn).value,
          child: Transform.translate(
              offset: Offset(0, (1 - _enterCtrl.value) * 30), child: child)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          const GCLogo(),
          const SizedBox(height: 36),
          Text('Create Account',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 32,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Join GymCore and start your fitness journey',
              style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 36),

          GCField(ctrl: _name,  hint: 'Full Name',
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 14),
          GCField(ctrl: _email, hint: 'Email Address',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 14),
          GCField(ctrl: _pass,  hint: 'Password (min 6 chars)',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure)),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _error != null ? GCErrorBox(_error!) : const SizedBox.shrink()),
          const SizedBox(height: 28),

          GCButton(
              label: _loading ? null : 'CREATE ACCOUNT',
              onTap: _submit, loading: _loading),
          const SizedBox(height: 24),

          Center(child: GestureDetector(
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: RichText(text: TextSpan(children: [
              TextSpan(text: 'Already have an account? ',
                  style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14)),
              TextSpan(text: 'Sign In',
                  style: GoogleFonts.dmSans(color: kGreen, fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ])))),
        ])))));
}
