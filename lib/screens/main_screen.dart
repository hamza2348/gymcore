import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'dashboard_screen.dart';
import 'activity_screen.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MS();
}

class _MS extends State<MainScreen> with TickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _tabAnim;

  final _screens = const [DashboardScreen(), ActivityScreen(), DiscoverScreen(), ProfileScreen()];
  final _icons   = [Icons.home_rounded, Icons.bar_chart_rounded, Icons.explore_rounded, Icons.person_rounded];
  final _labels  = ['Home', 'Activity', 'Discover', 'Profile'];

  @override
  void initState() {
    super.initState();
    _tabAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..forward();
  }
  @override void dispose() { _tabAnim.dispose(); super.dispose(); }

  void _tap(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
    _tabAnim.reset(); _tabAnim.forward();
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: kDark,
    body: AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(key: ValueKey(_tab), child: _screens[_tab])),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        border: Border(top: BorderSide(color: kBorder, width: 0.5))),
      child: SafeArea(child: SizedBox(height: 62,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (i) => _NavItem(
            icon: _icons[i], label: _labels[i],
            active: _tab == i, onTap: () => _tap(i))))))));
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(width: 72, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedContainer(duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? kGreen.withOpacity(0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(18)),
        child: Icon(icon, color: active ? kGreen : Colors.white30, size: 22)),
      const SizedBox(height: 2),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: GoogleFonts.dmSans(color: active ? kGreen : Colors.white30, fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400),
        child: Text(label)),
    ])));
}
