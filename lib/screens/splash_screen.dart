import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // حتما پکیج flutter_svg را نصب کنید
import 'package:animate_do/animate_do.dart'; // حتما پکیج animate_do را نصب کنید
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // تایمر ۴ ثانیه‌ای برای رفتن به صفحه اصلی
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // تصویر قرآن (اگر فایل SVG دارید آدرس آن را بدهید، وگرنه آیکون نمایش می‌دهد)
              ZoomIn(
                duration: const Duration(seconds: 2),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  // نکته: اگر فایل assets/images/quran.svg را دارید خط زیر را از کامنت خارج کنید
                  // child: SvgPicture.asset('assets/images/quran.svg', color: Colors.white),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // عنوان با انیمیشن
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: const Text(
                  'آموزش قرآن ششم دبستان',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // متن منبع
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'منبع: کتاب درسی قرآن ششم',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'همراه با صوت آیات از سایت',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '[https://everyayah.com/]',
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // لودینگ پایین صفحه
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
