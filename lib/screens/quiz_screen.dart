import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart'; // پکیج فونت
import '../models/quran_models.dart';
import '../widgets/common_widgets.dart';

class QuizScreen extends StatefulWidget {
  final Session session;
  const QuizScreen({super.key, required this.session});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  int? selectedOptionIndex;

  @override
  Widget build(BuildContext context) {
    // اطمینان از وجود سوالات
    final questions = widget.session.questions;
    if (questions == null || questions.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('آزمون', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: AppBackground(
          child: Center(
            child: Text("سوالی برای این درس یافت نشد",
                style:
                    GoogleFonts.vazirmatn(color: Colors.white, fontSize: 18)),
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('آزمون: ${widget.session.title}',
            style: GoogleFonts.vazirmatn(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // هدر و نوار پیشرفت با انیمیشن ورود
                FadeInDown(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "سوال ${currentQuestionIndex + 1} از ${questions.length}",
                            style: GoogleFonts.vazirmatn(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "امتیاز: $score",
                            style: GoogleFonts.vazirmatn(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (currentQuestionIndex + 1) / questions.length,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.cyanAccent),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // کارت نمایش سوال با افکت شیشه‌ای و انیمیشن زوم
                Expanded(
                  flex: 2,
                  child: ZoomIn(
                    key: ValueKey<int>(
                        currentQuestionIndex), // کلید برای انیمیشن مجدد هنگام تغییر سوال
                    child: Center(
                      child: GlassCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.help_outline_rounded,
                                size: 48, color: Colors.white54),
                            const SizedBox(height: 20),
                            Text(
                              currentQuestion.question,
                              style: GoogleFonts.vazirmatn(
                                // استفاده از فونت وزیر برای سوال
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // لیست گزینه‌ها با انیمیشن تاخیری
                Expanded(
                  flex: 3,
                  child: ListView.separated(
                    itemCount: currentQuestion.options.length,
                    separatorBuilder: (ctx, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 100 + 200),
                        child: _buildOptionButton(index, currentQuestion),
                      );
                    },
                  ),
                ),

                // دکمه مرحله بعد (فقط بعد از پاسخ دادن نمایش داده می‌شود)
                if (isAnswered)
                  FadeInUp(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentQuestionIndex < questions.length - 1) {
                            setState(() {
                              currentQuestionIndex++;
                              isAnswered = false;
                              selectedOptionIndex = null;
                            });
                          } else {
                            _showResultDialog(questions.length);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: const Color(0xFF1A2980),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          shadowColor: Colors.cyanAccent.withOpacity(0.4),
                        ),
                        child: Text(
                          currentQuestionIndex < questions.length - 1
                              ? 'سوال بعدی'
                              : 'پایان آزمون',
                          style: GoogleFonts.vazirmatn(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ویجت دکمه‌های گزینه با استایل شیشه‌ای و تغییر رنگ وضعیت
  Widget _buildOptionButton(int index, QuizQuestion question) {
    Color borderColor = Colors.white24;
    Color bgColor = Colors.white.withOpacity(0.05);
    IconData? icon;
    Color textColor = Colors.white;

    if (isAnswered) {
      if (index == question.correctIndex) {
        // گزینه صحیح: سبز
        borderColor = Colors.greenAccent;
        bgColor = Colors.green.withOpacity(0.2);
        icon = Icons.check_circle_rounded;
        textColor = Colors.greenAccent;
      } else if (index == selectedOptionIndex) {
        // گزینه غلط انتخاب شده: قرمز
        borderColor = Colors.redAccent;
        bgColor = Colors.red.withOpacity(0.2);
        icon = Icons.cancel_rounded;
        textColor = Colors.redAccent;
      } else {
        // سایر گزینه‌ها کمرنگ شوند
        textColor = Colors.white38;
      }
    }

    return GestureDetector(
      onTap:
          isAnswered ? null : () => _checkAnswer(index, question.correctIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question.options[index],
                style: GoogleFonts.vazirmatn(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            if (icon != null) Icon(icon, color: textColor),
          ],
        ),
      ),
    );
  }

  void _checkAnswer(int selectedIndex, int correctIndex) {
    setState(() {
      isAnswered = true;
      selectedOptionIndex = selectedIndex;
      if (selectedIndex == correctIndex) {
        score++;
      }
    });
  }

  // نمایش دیالوگ نتیجه نهایی با افکت شیشه‌ای
  void _showResultDialog(int totalQuestions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A2980).withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZoomIn(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      size: 60, color: Colors.amber),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'پایان آزمون',
                style: GoogleFonts.vazirmatn(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'شما به $score سوال از $totalQuestions سوال پاسخ صحیح دادید.',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.vazirmatn(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // بستن دیالوگ
                        // ریست کردن آزمون برای تکرار
                        setState(() {
                          currentQuestionIndex = 0;
                          score = 0;
                          isAnswered = false;
                          selectedOptionIndex = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('تکرار آزمون',
                          style: GoogleFonts.vazirmatn(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: const Color(0xFF1A2980),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('بازگشت',
                          style: GoogleFonts.vazirmatn(
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
