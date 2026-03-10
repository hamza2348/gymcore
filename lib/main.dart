import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const GymCoreApp());
}

// ── Global theme constants ────────────────────────────────────────────────────
const kGreen     = Color(0xFFBEFF00);
const kDark      = Color(0xFF0A0A0A);
const kCard      = Color(0xFF141414);
const kCardLight = Color(0xFF1E1E1E);
const kBorder    = Color(0xFF2A2A2A);

class GymCoreApp extends StatelessWidget {
  const GymCoreApp({super.key});
  @override
  Widget build(BuildContext ctx) => MaterialApp(
    title: 'GymCore',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kDark,
      primaryColor: kGreen,
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
          primary: kGreen, secondary: kGreen, surface: kCard),
    ),
    home: const SplashScreen(),
  );
}
