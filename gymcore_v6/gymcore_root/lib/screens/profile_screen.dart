import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';
import 'auth/signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _PS();
}

class _PS extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _editing = false;
  UserProfile? get user => AuthService().currentUser;

  late TextEditingController _nameCtrl, _goalCtrl;
  late double _weight;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _goalCtrl = TextEditingController(text: user?.fitnessGoal ?? '');
    _weight   = user?.weight ?? 70;
  }
  @override void dispose() { _ctrl.dispose(); _nameCtrl.dispose(); _goalCtrl.dispose(); super.dispose(); }

  void _save() {
    final u = user; if (u == null) return;
    u.name = _nameCtrl.text.trim();
    u.fitnessGoal = _goalCtrl.text.trim();
    u.weight = _weight;
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile saved!', style: GoogleFonts.dmSans(color: Colors.black)),
      backgroundColor: kGreen, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  Widget build(BuildContext ctx) {
    final u = user;
    return SafeArea(child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeIn).value,
          child: Transform.translate(offset: Offset(0,(1-_ctrl.value)*20), child: child)),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Text('Profile', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const Spacer(),
            GestureDetector(
              onTap: _editing ? _save : () => setState(() => _editing = true),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: _editing ? kGreen : kCard,
                    borderRadius: BorderRadius.circular(20), border: Border.all(color: _editing ? kGreen : kBorder)),
                child: Text(_editing ? 'Save ✓' : 'Edit',
                    style: GoogleFonts.dmSans(color: _editing ? Colors.black : kGreen,
                        fontWeight: FontWeight.w700, fontSize: 13)))),
          ]),
          const SizedBox(height: 28),

          // Avatar
          Stack(alignment: Alignment.bottomRight, children: [
            Container(width: 96, height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, color: kCard,
                  border: Border.all(color: kGreen, width: 2.5),
                  boxShadow: [BoxShadow(color: kGreen.withOpacity(0.2), blurRadius: 20)]),
              child: Center(child: Text(u?.gender == 'female' ? '🌸' : '💪', style: const TextStyle(fontSize: 44)))),
            if (_editing) Container(width: 30, height: 30,
                decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 16)),
          ]),
          const SizedBox(height: 10),
          Text(u?.name ?? '—', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          Text(u?.fitnessGoal ?? '', style: GoogleFonts.dmSans(color: kGreen, fontSize: 13)),
          const SizedBox(height: 24),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _Stat('${u?.completedWorkouts.length ?? 0}', 'Workouts'),
              Container(width: 1, height: 30, color: kBorder),
              _Stat('${u?.workoutCalories.values.fold(0,(a,b)=>a+b) ?? 0}', 'Cal Burned'),
              Container(width: 1, height: 30, color: kBorder),
              _Stat('${u?.workoutDuration.values.fold(0,(a,b)=>a+b) ?? 0}', 'Minutes'),
            ])),
          const SizedBox(height: 24),

          // Editable fields
          _editing
              ? Column(children: [
                  _EditField('Full Name', _nameCtrl, Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  _EditField('Fitness Goal', _goalCtrl, Icons.flag_rounded),
                  const SizedBox(height: 16),
                  Container(padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Weight', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                        Text(_weight.toStringAsFixed(1), style: GoogleFonts.dmSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        Text('kg', style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14)),
                      ]),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: kGreen, activeTrackColor: kGreen,
                          inactiveTrackColor: kGreen.withOpacity(0.15),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                          trackHeight: 3),
                        child: Slider(value: _weight, min: 40, max: 150, divisions: 110,
                            onChanged: (v) => setState(() => _weight = v))),
                    ])),
                ])
              : _ProfileInfo(u),

          const SizedBox(height: 28),

          // Settings items
          _SettingItem(Icons.lock_outline_rounded, 'Change Password', () {}),
          _SettingItem(Icons.notifications_outlined, 'Notifications', () {}),
          _SettingItem(Icons.help_outline_rounded, 'Help & Support', () {}),
          const SizedBox(height: 16),

          // Logout
          SizedBox(width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
              label: Text('Sign Out', style: GoogleFonts.dmSans(color: Colors.redAccent, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
          const SizedBox(height: 24),
        ]))));
  }

  void _logout() => showDialog(context: context, builder: (_) => AlertDialog(
    backgroundColor: kCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text('Sign Out', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w800)),
    content: Text('Are you sure?', style: GoogleFonts.dmSans(color: Colors.white54)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.white54, fontWeight: FontWeight.w700))),
      ElevatedButton(
        onPressed: () {
          AuthService().logout();
          Navigator.pushAndRemoveUntil(context,
              PageRouteBuilder(pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const SignupScreen()),
                  transitionDuration: const Duration(milliseconds: 500)),
              (_) => false);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Text('Sign Out', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700))),
    ]));
}

class _Stat extends StatelessWidget {
  final String val, label;
  const _Stat(this.val, this.label);
  @override build(BuildContext ctx) => Column(children: [
    Text(val, style: GoogleFonts.dmSans(color: kGreen, fontSize: 20, fontWeight: FontWeight.w800)),
    Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11)),
  ]);
}

class _EditField extends StatelessWidget {
  final String label; final TextEditingController ctrl; final IconData icon;
  const _EditField(this.label, this.ctrl, this.icon);
  @override
  Widget build(BuildContext ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
    const SizedBox(height: 6),
    TextField(controller: ctrl, style: GoogleFonts.dmSans(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white30, size: 18),
        filled: true, fillColor: kCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kGreen, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14))),
  ]);
}

class _ProfileInfo extends StatelessWidget {
  final UserProfile? u;
  const _ProfileInfo(this.u);
  @override
  Widget build(BuildContext ctx) => Column(children: [
    _InfoRow(Icons.wc_rounded, 'Gender', u?.gender == 'female' ? 'Female' : 'Male'),
    _InfoRow(Icons.monitor_weight_outlined, 'Weight', '${u?.weight.toStringAsFixed(1)} kg'),
    _InfoRow(Icons.cake_outlined, 'Age', '${u?.age} years'),
    _InfoRow(Icons.flag_rounded, 'Goal', u?.fitnessGoal ?? '—'),
  ]);
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext ctx) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(13), border: Border.all(color: kBorder)),
    child: Row(children: [
      Icon(icon, color: kGreen, size: 17),
      const SizedBox(width: 12),
      Text(label, style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13)),
      const Spacer(),
      Text(value, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
    ]));
}

class _SettingItem extends StatefulWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _SettingItem(this.icon, this.label, this.onTap);
  @override State<_SettingItem> createState() => _SIState();
}
class _SIState extends State<_SettingItem> {
  bool _p = false;
  @override build(BuildContext ctx) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedContainer(duration: const Duration(milliseconds: 130),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      transform: Matrix4.identity()..scale(_p ? 0.97 : 1.0),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
      child: Row(children: [
        Icon(widget.icon, color: kGreen, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(widget.label, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600))),
        const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
      ])));
}
