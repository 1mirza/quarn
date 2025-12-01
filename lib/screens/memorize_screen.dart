import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart'; // پکیج فونت‌های گوگل
import '../models/quran_models.dart';
import '../providers/game_state.dart';
import '../widgets/common_widgets.dart';

class MemorizeScreen extends StatefulWidget {
  final Session session;
  const MemorizeScreen({super.key, required this.session});

  @override
  State<MemorizeScreen> createState() => _MemorizeScreenState();
}

class _MemorizeScreenState extends State<MemorizeScreen> {
  // برای ذخیره وضعیت نمایش/مخفی بودن کلمات کلیدی (آیا کاربر روی آن کلیک کرده؟)
  final Map<String, bool> _revealedWords = {};

  // متغیر کمکی برای دسترسی به GameState در متد dispose
  GameState? _gameState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ذخیره رفرنس به GameState برای دسترسی در زمان بسته شدن صفحه
    _gameState = Provider.of<GameState>(context, listen: false);
  }

  @override
  void dispose() {
    // توقف صدا هنگام خروج از صفحه با استفاده از رفرنس ذخیره شده
    _gameState?.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // اطمینان از وجود محتوا
    if (widget.session.memorizeContent == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('تمرین حفظ',
              style: GoogleFonts.vazirmatn(color: Colors.white)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: AppBackground(
          child: Center(
            child: Text("محتوای حفظ برای این درس یافت نشد",
                style:
                    GoogleFonts.vazirmatn(color: Colors.white, fontSize: 18)),
          ),
        ),
      );
    }

    final content = widget.session.memorizeContent!;
    final hiddenWords = content.hiddenWords;
    // جدا کردن کلمات آیه برای نمایش جداگانه و تعاملی
    final words = content.arabic.split(' ');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('تمرین حفظ',
            style: GoogleFonts.vazirmatn(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
          child: Consumer<GameState>(
            builder: (context, gameState, child) {
              // بررسی اینکه آیا این آیه قبلاً توسط کاربر حفظ شده علامت‌گذاری شده است؟
              final isMemorized = gameState.isMemorized(content.arabic);

              return Column(
                children: [
                  // کارت راهنما با انیمیشن
                  FadeInDown(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded,
                              color: Colors.amberAccent, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'کلمات محو شده را حدس بزنید و برای چک کردن روی آن‌ها ضربه بزنید.',
                              style: GoogleFonts.vazirmatn(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // باکس اصلی نمایش آیه
                  ZoomIn(
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // نمایش کلمات آیه به صورت Wrap
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 15,
                            textDirection: TextDirection.rtl,
                            children: words.map((word) {
                              // پاکسازی علائم نگارشی برای مقایسه دقیق‌تر
                              final cleanWord =
                                  word.replaceAll(RegExp(r'[^\w\s]'), '');

                              // آیا این کلمه جزو کلمات هدف برای مخفی‌سازی است؟
                              bool isHiddenTarget =
                                  hiddenWords.any((h) => word.contains(h));

                              // وضعیت فعلی نمایش (آیا کاربر روی آن کلیک کرده است؟)
                              bool isRevealed = _revealedWords[word] ?? false;

                              if (isHiddenTarget) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _revealedWords[word] = !isRevealed;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      // تغییر رنگ پس‌زمینه در حالت مخفی و آشکار
                                      color: isRevealed
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isRevealed
                                            ? Colors.white30
                                            : Colors.amberAccent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isRevealed
                                        ? Text(
                                            word,
                                            style: GoogleFonts.amiri(
                                              // فونت زیبای عربی
                                              fontSize: gameState.fontSize +
                                                  4, // کمی بزرگتر برای خوانایی
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              height: 1.8,
                                            ),
                                          )
                                        : ImageFiltered(
                                            // اعمال افکت بلور (تاری) روی متن برای ناخوانا کردن
                                            imageFilter: ImageFilter.blur(
                                                sigmaX: 5, sigmaY: 5),
                                            child: Text(
                                              word,
                                              style: GoogleFonts.amiri(
                                                fontSize:
                                                    gameState.fontSize + 4,
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .white54, // کمی کمرنگ‌تر
                                                height: 1.8,
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              } else {
                                // کلمات عادی (غیر مخفی)
                                return Text(
                                  word,
                                  style: GoogleFonts.amiri(
                                    // فونت زیبای عربی
                                    fontSize: gameState.fontSize + 4,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.8,
                                  ),
                                );
                              }
                            }).toList(),
                          ),

                          const SizedBox(height: 25),
                          Divider(color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 10),

                          // دکمه وضعیت حفظ (چک باکس پیشرفته)
                          InkWell(
                            onTap: () {
                              gameState.toggleMemorized(content.arabic);
                              // نمایش پیام تایید
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isMemorized
                                        ? 'از لیست حفظ شده‌ها حذف شد'
                                        : 'تبریک! به لیست حفظ شده‌ها اضافه شد',
                                    style: GoogleFonts.vazirmatn(),
                                  ),
                                  backgroundColor: isMemorized
                                      ? Colors.redAccent
                                      : Colors.green,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMemorized
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isMemorized
                                      ? Colors.greenAccent
                                      : Colors.white30,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isMemorized
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isMemorized
                                        ? Colors.greenAccent
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isMemorized ? 'حفظ کردم' : 'هنوز حفظ نیستم',
                                    style: GoogleFonts.vazirmatn(
                                      color: isMemorized
                                          ? Colors.greenAccent
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // کارت ترجمه فارسی
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      child: Column(
                        children: [
                          Text(
                            'ترجمه',
                            style: GoogleFonts.vazirmatn(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            content.persian,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 18,
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
