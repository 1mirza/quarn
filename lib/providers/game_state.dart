import 'dart:convert';
import 'package:flutter/foundation.dart'; // برای بررسی نسخه وب
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/quran_models.dart';

class GameState extends ChangeNotifier {
  // --- داده‌ها ---
  List<LessonIndex>? lessonIndex;
  bool isIndexLoading = true;
  LessonContent? currentLessonContent;
  bool isLessonLoading = false;

  // --- تنظیمات ---
  double fontSize = 24.0;

  final Map<String, String> availableReciters = {
    "عبدالباسط (تحقیق)":
        "https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps/",
    "مشاری العفاسی (ترتیل)": "https://everyayah.com/data/Alafasy_128kbps/",
    "پرهیزگار (ترتیل)": "https://everyayah.com/data/Parhizgar_48kbps/",
    "منشاوی (تحقیق)": "https://everyayah.com/data/Minshawy_Mujawwad_192kbps/",
  };

  String currentReciterName = "عبدالباسط (تحقیق)";
  late String currentReciterBaseUrl;

  // --- دانلود و پخش ---
  bool isDownloadingAll = false;
  double downloadProgress = 0.0;
  String downloadStatusText = "";

  final AudioPlayer _player = AudioPlayer();
  int? currentPlayingVerseIndex;
  bool isPlaying = false;
  double playbackSpeed = 1.0;
  bool isLooping = false;

  Set<String> memorizedVerses = {};

  GameState() {
    currentReciterBaseUrl = availableReciters[currentReciterName]!;
    loadIndex();
    _initAudioListeners();
  }

  // --- متدهای تنظیمات ---

  void setFontSize(double size) {
    fontSize = size;
    notifyListeners();
  }

  void changeReciter(String name) {
    if (availableReciters.containsKey(name)) {
      currentReciterName = name;
      currentReciterBaseUrl = availableReciters[name]!;
      // اگر در حال پخش است، متوقف کن تا با صدای جدید پخش شود
      if (isPlaying) stopAudio();
      notifyListeners();
    }
  }

  String getReciterUrl(String originalUrl) {
    try {
      final uri = Uri.parse(originalUrl);
      final fileName = uri.pathSegments.last;
      return "$currentReciterBaseUrl$fileName";
    } catch (e) {
      return originalUrl;
    }
  }

  void toggleMemorized(String id) {
    if (memorizedVerses.contains(id)) {
      memorizedVerses.remove(id);
    } else {
      memorizedVerses.add(id);
    }
    notifyListeners();
  }

  bool isMemorized(String id) => memorizedVerses.contains(id);

  // --- متدهای بارگذاری ---

  Future<void> loadIndex() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/index.json');
      final List<dynamic> data = json.decode(response);
      lessonIndex = data.map((e) => LessonIndex.fromJson(e)).toList();
      isIndexLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error loading index: $e");
      isIndexLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLessonContent(String fileName) async {
    isLessonLoading = true;
    currentLessonContent = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final String response =
          await rootBundle.loadString('assets/data/lessons/$fileName');
      final data = json.decode(response);
      currentLessonContent = LessonContent.fromJson(data);
      isLessonLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error loading lesson: $e");
      isLessonLoading = false;
      notifyListeners();
    }
  }

  // --- متدهای صوتی (اصلاح شده) ---

  void _initAudioListeners() {
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (isLooping && currentPlayingVerseIndex != null) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          stopAudio();
        }
      }
      notifyListeners();
    });
  }

  Future<void> playVerse(String originalUrl, int index) async {
    try {
      final url = getReciterUrl(originalUrl);

      // اگر کاربر روی همان آیه کلیک کرد، فقط مکث/پخش کن
      if (currentPlayingVerseIndex == index && _player.audioSource != null) {
        if (isPlaying) {
          await pauseAudio();
        } else {
          await _player.play();
        }
        return;
      }

      // شروع فرآیند پخش جدید
      currentPlayingVerseIndex = index;
      notifyListeners();

      if (kIsWeb) {
        await _player.setUrl(url);
      } else {
        try {
          // در موبایل: تلاش برای پخش از کش
          final fileInfo = await DefaultCacheManager().getFileFromCache(url);
          if (fileInfo != null && await fileInfo.file.exists()) {
            // چک امنیتی ۱: آیا هنوز همین آیه انتخاب شده است؟ (شاید کاربر در این فاصله استپ کرده باشد)
            if (currentPlayingVerseIndex != index) return;
            await _player.setFilePath(fileInfo.file.path);
          } else {
            // اگر در کش نیست، دانلود یا استریم کن
            if (currentPlayingVerseIndex != index) return;
            await _player.setUrl(url);
          }
        } catch (e) {
          if (currentPlayingVerseIndex != index) return;
          await _player.setUrl(url);
        }
      }

      // چک امنیتی نهایی: اگر قبل از شروع پخش، کاربر دکمه توقف یا بازگشت را زده باشد،
      // مقدار currentPlayingVerseIndex نال شده است. پس نباید پخش کنیم.
      if (currentPlayingVerseIndex == index) {
        _player.setSpeed(playbackSpeed);
        _player.play();
        notifyListeners();
      }
    } catch (e) {
      print("Error playing audio: $e");
      stopAudio();
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> stopAudio() async {
    try {
      // توقف کامل پلیر
      await _player.stop();
      // ریست کردن وضعیت به حالت اولیه
      currentPlayingVerseIndex = null;
      isPlaying = false;
      notifyListeners();
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  void setSpeed(double speed) {
    playbackSpeed = speed;
    _player.setSpeed(speed);
    notifyListeners();
  }

  void toggleLoop() {
    isLooping = !isLooping;
    notifyListeners();
  }

  // --- دانلود یکجا ---

  Future<void> downloadAllAudio() async {
    if (lessonIndex == null) return;
    if (kIsWeb) {
      downloadStatusText = "دانلود آفلاین در وب پشتیبانی نمی‌شود.";
      notifyListeners();
      return;
    }

    isDownloadingAll = true;
    downloadProgress = 0.0;
    downloadStatusText = "در حال آماده‌سازی...";
    notifyListeners();

    try {
      List<String> allUrls = [];
      for (var lessonRef in lessonIndex!) {
        final String response = await rootBundle
            .loadString('assets/data/lessons/${lessonRef.fileName}');
        final data = json.decode(response);
        final lesson = LessonContent.fromJson(data);
        for (var session in lesson.sessions) {
          if (session.verses != null) {
            for (var verse in session.verses!) {
              allUrls.add(getReciterUrl(verse.audioUrl));
            }
          }
        }
      }

      int total = allUrls.length;
      int count = 0;
      for (var url in allUrls) {
        if (!isDownloadingAll) break; // امکان لغو دانلود
        count++;
        downloadStatusText = "دانلود فایل $count از $total";
        downloadProgress = count / total;
        notifyListeners();
        await DefaultCacheManager().downloadFile(url);
      }
      if (isDownloadingAll) {
        downloadStatusText = "دانلود تمام شد!";
      }
    } catch (e) {
      downloadStatusText = "خطا در دانلود: $e";
    } finally {
      isDownloadingAll = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
