import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/feed_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibePulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE9B3FF),
          secondary: Color(0xFFFFB2B7),
          tertiary: Color(0xFFC2C1FF),
          surface: Color(0xFF131315),
          onSurface: Color(0xFFE5E1E4),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.copyWith(
                displayLarge: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w800,
                  fontSize: 48,
                  letterSpacing: -0.96,
                ),
                headlineLarge: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  letterSpacing: -0.32,
                ),
                headlineMedium: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
        ),
      ),
      home: const FeedScreen(),
    );
  }
}