import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quran_models.dart';
import '../providers/game_state.dart';
import '../widgets/common_widgets.dart';

class ReadingScreen extends StatefulWidget {
  final Session session;
  const ReadingScreen({super.key, required this.session});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ScrollController _scrollController = ScrollController();

  // مدیریت دکمه بازگشت (Back)
  Future<bool> _onWillPop() async {
    final gameState = Provider.of<GameState>(context, listen: false);

    // اگر صدا در حال پخش است، کادر هشدار نشان بده
    if (gameState.isPlaying) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (ctx) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1A2980).withOpacity(0.95),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.amberAccent),
                const SizedBox(width: 10),
                Text('توقف پخش',
                    style: GoogleFonts.vazirmatn(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'آیا می‌خواهید پخش صوت را متوقف کنید و خارج شوید؟',
              style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false), // خیر
                child: Text('ادامه پخش',
                    style: GoogleFonts.vazirmatn(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true), // بله
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('بله، خروج',
                    style: GoogleFonts.vazirmatn(color: Colors.white)),
              ),
            ],
          ),
        ),
      );

      if (shouldExit == true) {
        await gameState.stopAudio(); // قطع صدا
        return true; // خروج
      } else {
        return false; // ماندن در صفحه
      }
    }

    // اگر صدا پخش نمی‌شود، مستقیماً خارج شو
    return true;
  }

  @override
  void dispose() {
    try {
      Provider.of<GameState>(context, listen: false).stopAudio();
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verses = widget.session.verses!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.session.title,
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
          child: Column(
            children: [
              Expanded(
                child: Consumer<GameState>(
                  builder: (context, gameState, child) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 120),
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final verse = verses[index];
                        final isPlaying =
                            gameState.currentPlayingVerseIndex == index;

                        return FadeInUp(
                          delay: Duration(milliseconds: index * 50),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isPlaying
                                    ? [
                                        BoxShadow(
                                            color:
                                                Colors.amber.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 2)
                                      ]
                                    : [],
                                border: isPlaying
                                    ? Border.all(
                                        color:
                                            Colors.amberAccent.withOpacity(0.8),
                                        width: 2)
                                    : Border.all(
                                        color: Colors.white10, width: 1),
                              ),
                              child: GlassCard(
                                margin: EdgeInsets.zero,
                                onTap: () =>
                                    gameState.playVerse(verse.audioUrl, index),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: isPlaying
                                                ? Colors.amber
                                                : Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            verse.id,
                                            style: TextStyle(
                                              color: isPlaying
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (isPlaying)
                                          const Icon(Icons.volume_up_rounded,
                                              color: Colors.amberAccent,
                                              size: 24),
                                      ],
                                    ),
                                    const SizedBox(height: 15),

                                    // متن عربی با فونت امیری
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        verse.textArabic,
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.amiri(
                                          fontSize: gameState.fontSize + 4,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 2.4,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Divider(
                                        color: Colors.white.withOpacity(0.2)),
                                    const SizedBox(height: 10),

                                    // ترجمه فارسی با فونت وزیر
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        verse.textPersian,
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.vazirmatn(
                                          fontSize: gameState.fontSize * 0.7,
                                          color: Colors.white.withOpacity(0.95),
                                          height: 1.8,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildGlassAudioControls(context),
      ),
    );
  }

  Widget _buildGlassAudioControls(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2980).withOpacity(0.6),
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ],
          ),
          child: Consumer<GameState>(
            builder: (context, gameState, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlBtn(
                    icon: Icons.repeat_rounded,
                    isActive: gameState.isLooping,
                    onTap: gameState.toggleLoop,
                    activeColor: Colors.greenAccent,
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop_circle_rounded,
                        color: Colors.redAccent, size: 36),
                    onPressed: gameState.stopAudio,
                  ),
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2)
                      ],
                    ),
                    child: IconButton(
                      iconSize: 32,
                      color: Colors.white,
                      icon: Icon(gameState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      onPressed: () {
                        if (gameState.isPlaying) {
                          gameState.pauseAudio();
                        } else if (gameState.currentPlayingVerseIndex != null) {
                          gameState.playVerse(
                              widget
                                  .session
                                  .verses![gameState.currentPlayingVerseIndex!]
                                  .audioUrl,
                              gameState.currentPlayingVerseIndex!);
                        } else if (widget.session.verses!.isNotEmpty) {
                          gameState.playVerse(
                              widget.session.verses![0].audioUrl, 0);
                        }
                      },
                    ),
                  ),
                  PopupMenuButton<double>(
                    offset: const Offset(0, -120),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: const Color(0xFF1A2980).withOpacity(0.95),
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text('${gameState.playbackSpeed}x',
                              style: GoogleFonts.vazirmatn(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    onSelected: gameState.setSpeed,
                    itemBuilder: (context) => [
                      _speedItem(0.75, 'کند'),
                      _speedItem(1.0, 'عادی'),
                      _speedItem(1.25, 'تند'),
                      _speedItem(1.5, 'خیلی تند'),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn(
      {required IconData icon,
      required VoidCallback onTap,
      bool isActive = false,
      Color activeColor = Colors.blue}) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
              color: activeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12))
          : null,
      child: IconButton(
          icon: Icon(icon),
          color: isActive ? activeColor : Colors.white70,
          iconSize: 28,
          onPressed: onTap),
    );
  }

  PopupMenuItem<double> _speedItem(double value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$value x',
            style: GoogleFonts.vazirmatn(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.vazirmatn(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}
