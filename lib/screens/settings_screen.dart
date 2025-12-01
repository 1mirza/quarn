import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/game_state.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('تنظیمات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: AppBackground(
        child: Consumer<GameState>(
          builder: (context, gameState, child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
              children: [
                // 1. تنظیمات فونت
                FadeInDown(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.format_size, color: Colors.amberAccent),
                            SizedBox(width: 10),
                            Text("اندازه متن آیات",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text("کوچک",
                                style: TextStyle(color: Colors.white70)),
                            Expanded(
                              child: Slider(
                                value: gameState.fontSize,
                                min: 18.0,
                                max: 40.0,
                                divisions: 11,
                                activeColor: Colors.amber,
                                inactiveColor: Colors.white24,
                                label: gameState.fontSize.round().toString(),
                                onChanged: (val) => gameState.setFontSize(val),
                              ),
                            ),
                            const Text("بزرگ",
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // پیش‌نمایش متن
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: gameState.fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. انتخاب قاری
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.record_voice_over,
                                color: Colors.cyanAccent),
                            SizedBox(width: 10),
                            Text("انتخاب قاری",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: gameState.currentReciterName,
                              dropdownColor: const Color(0xFF1A2980),
                              style: const TextStyle(
                                  color: Colors.white, fontFamily: 'Vazirmatn'),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              items: gameState.availableReciters.keys
                                  .map((String key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(key),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  gameState.changeReciter(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. دانلود یکجا (آفلاین سازی)
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: GlassCard(
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.download_for_offline_rounded,
                                color: Colors.greenAccent),
                            SizedBox(width: 10),
                            Text("دانلود کل فایل‌ها",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "با زدن این دکمه، تمام صوت‌های کتاب دانلود شده و برنامه برای همیشه آفلاین می‌شود.",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        if (gameState.isDownloadingAll) ...[
                          LinearProgressIndicator(
                            value: gameState.downloadProgress,
                            backgroundColor: Colors.white12,
                            color: Colors.greenAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            gameState.downloadStatusText,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.download_rounded),
                              label: const Text("شروع دانلود"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                _showDownloadDialog(context, gameState);
                              },
                            ),
                          ),
                          if (gameState.downloadStatusText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                gameState.downloadStatusText,
                                style: const TextStyle(
                                    color: Colors.greenAccent, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. درباره سازنده (جدید)
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: GlassCard(
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Colors.white),
                            SizedBox(width: 10),
                            Text("درباره سازنده",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "این برنامه توسط حمیدرضا علی میرزائی طراحی و ساخته شده است.",
                          style: TextStyle(
                              color: Colors.white, fontSize: 16, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 10),
                        const Text(
                          "برای بازخورد و بهبود به ایمیل زیر پیام دهید:",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        const SelectableText(
                          "", // ایمیل شما یا ایمیل نمونه
                          style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold),
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
    );
  }

  void _showDownloadDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2980),
        title: const Text("هشدار مصرف اینترنت",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "حجم کل فایل‌های صوتی حدود ۵۰ تا ۱۰۰ مگابایت است. آیا مایل به ادامه هستید؟",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("خیر"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text("بله، دانلود کن",
                style: TextStyle(color: Colors.greenAccent)),
            onPressed: () {
              Navigator.pop(ctx);
              gameState.downloadAllAudio();
            },
          ),
        ],
      ),
    );
  }
}
