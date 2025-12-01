import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/game_state.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'آموزش قرآن ششم',
      debugShowCheckedModeBanner: false,

      // تنظیمات زبان فارسی و راست‌چین بودن کل برنامه
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', ''), // Farsi
      ],

      theme: ThemeData(
        // رنگ اصلی برنامه
        primarySwatch: Colors.indigo,

        // رنگ پس‌زمینه پیش‌فرض (هماهنگ با تم آبی تیره)
        scaffoldBackgroundColor: const Color(0xFF1A2980),

        // تنظیم فونت وزیر برای تمام متون برنامه
        textTheme: GoogleFonts.vazirmatnTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),

        // استایل پیش‌فرض آیکون‌ها
        iconTheme: const IconThemeData(color: Colors.white),

        // استایل اپ‌بار
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      // نقطه شروع: نمایش صفحه اسپلش
      home: const SplashScreen(),
    );
  }
}
