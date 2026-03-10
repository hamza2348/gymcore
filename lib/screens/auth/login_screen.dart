import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../widgets/shared.dart';
import '../main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> with SingleTickerProviderStateMixin {
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
    _email.dispose(); _pass.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _error = null);
    final e = _email.text.trim();
    final p = _pass.text;
    if (!e.contains('@')) { setState(() => _error = 'Enter a valid email'); return; }
    if (p.isEmpty)         { setState(() => _error = 'Enter your password'); return; }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final err = AuthService().login(e, p);
    setState(() { _loading = false; _error = err; });

    if (err == null) {
      Navigator.pushAndRemoveUntil(context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) => FadeTransition(
                opacity: a, child: const MainScreen()),
            transitionDuration: const Duration(milliseconds: 500)),
          (_) => false);
    }
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
          Text('Welcome Back',
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 32,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Sign in to continue your journey',
              style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 36),

          GCField(ctrl: _email, hint: 'Email Address',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 14),
          GCField(ctrl: _pass, hint: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure)),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _error != null ? GCErrorBox(_error!) : const SizedBox.shrink()),
          const SizedBox(height: 28),

          GCButton(
              label: _loading ? null : 'SIGN IN',
              onTap: _submit, loading: _loading),
          const SizedBox(height: 24),

          Center(child: GestureDetector(
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SignupScreen())),
            child: RichText(text: TextSpan(children: [
              TextSpan(text: "Don't have an account? ",
                  style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14)),
              TextSpan(text: 'Sign Up',
                  style: GoogleFonts.dmSans(color: kGreen, fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ])))),
        ])))));
}
