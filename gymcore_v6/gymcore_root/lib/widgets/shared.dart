// Shared UI widgets used across auth screens
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class GCLogo extends StatelessWidget {
  const GCLogo({super.key});
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(children: [
      TextSpan(text: 'GYM',  style: GoogleFonts.dmSans(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
      TextSpan(text: 'CORE', style: GoogleFonts.dmSans(color: kGreen,        fontSize: 26, fontWeight: FontWeight.w900)),
    ]));
}

class GCField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool? obscure;
  final VoidCallback? onToggle;
  final TextInputType? keyboard;

  const GCField({super.key, required this.ctrl, required this.hint,
      required this.icon, this.obscure, this.onToggle, this.keyboard});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    obscureText: obscure ?? false,
    keyboardType: keyboard,
    style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: Colors.white30),
      prefixIcon: Icon(icon, color: Colors.white30, size: 20),
      suffixIcon: onToggle != null
          ? IconButton(
              icon: Icon(
                obscure! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white30, size: 20),
              onPressed: onToggle)
          : null,
      filled: true,
      fillColor: kCard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kGreen, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ));
}

class GCErrorBox extends StatelessWidget {
  final String message;
  const GCErrorBox(this.message, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: GoogleFonts.dmSans(color: Colors.redAccent, fontSize: 13))),
      ])));
}

class GCButton extends StatefulWidget {
  final String? label;
  final VoidCallback onTap;
  final bool loading;
  const GCButton({super.key, required this.label, required this.onTap, this.loading = false});
  @override State<GCButton> createState() => _GCButtonState();
}
class _GCButtonState extends State<GCButton> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100)); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) { _c.reverse(); widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.scale(scale: 1 - _c.value * 0.03, child: child),
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          color: kGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: kGreen.withOpacity(0.25), blurRadius: 16,
              offset: const Offset(0, 6))]),
        child: Center(child: widget.loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
            : Text(widget.label ?? '',
                style: GoogleFonts.dmSans(
                    color: Colors.black, fontWeight: FontWeight.w900,
                    fontSize: 15, letterSpacing: 0.5))))));
}
