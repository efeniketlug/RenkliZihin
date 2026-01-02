import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renkli Zihin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// -------------------- GİRİŞ EKRANI --------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6dd5ed), Color(0xFF2193b0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text('🎮', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 10),
                  Text(
                    'Oyun Tüneline\nHoşgeldiniz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.deepPurple,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'MACERAYA BAŞLA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- OYUN EKRANI --------------------
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebViewController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isCompleted = false;

  // --- OYUN LİSTESİ ---
  final List<String> _gameUrls = [
    'https://play2048.co/',
    'https://hextris.io/',
    'https://playsnake.org/',
    'https://www.google.com/logos/2010/pacman10-i.html',
    'https://www.google.com/logos/2017/cricket17/cricket17.html',
    'https://flappybird.io/',
    'https://playtictactoe.org/',
    'https://musiclab.chromeexperiments.com/Kandinsky/',
    'https://musiclab.chromeexperiments.com/Song-Maker/',
    'https://quickdraw.withgoogle.com/',
    'https://littlealchemy2.com/',
    'https://www.jacksonpollock.org/',
    'https://musiclab.chromeexperiments.com/Rhythm/',
    'https://cardgames.io/checkers/',
    'https://musiclab.chromeexperiments.com/Strings/',
    'https://musiclab.chromeexperiments.com/Oscillators/',
    'https://www.koalastothemax.com/',
    'https://musiclab.chromeexperiments.com/Spectrogram/',
    'https://musiclab.chromeexperiments.com/Arpeggios/',
    'http://weavesilk.com/',
  ];

  final Set<int> _silentLevels = {7, 8, 12, 14, 15, 17, 18};

  final List<Color> _levelColors = [
    Colors.orange, Colors.blue, Colors.green, Colors.red, Colors.purple,
    Colors.teal, Colors.amber, Colors.cyan, Colors.indigo, Colors.pink,
    Colors.lime, Colors.brown, Colors.deepOrange, Colors.lightBlue, Colors.deepPurple,
    Colors.lightGreen, Colors.blueGrey, Colors.yellow.shade800, Colors.redAccent, Colors.black87
  ];

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _manageBackgroundMusic();
  }

  Future<void> _manageBackgroundMusic() async {
    try {
      if (_isCompleted) {
         if (_audioPlayer.state != PlayerState.playing) {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.setVolume(0.2);
          await _audioPlayer.play(AssetSource('background_music.mp3'));
        }
        return;
      }

      if (_silentLevels.contains(_currentIndex)) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.state != PlayerState.playing) {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.setVolume(0.2);
          await _audioPlayer.play(AssetSource('background_music.mp3'));
        }
      }
    } catch (e) {
      debugPrint("Müzik hatası: $e");
    }
  }

  void _initializeWebView() {
    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setBackgroundColor(const Color(0xFFFFFFFF));
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (String url) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('HATA: ${error.description}');
        },
      ),
    );
    _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
  }

  void _nextGame() {
    setState(() {
      if (_currentIndex < _gameUrls.length - 1) {
        _currentIndex++;
        _isLoading = true;
        _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
      } else {
        _isCompleted = true;
      }
      _manageBackgroundMusic();
    });
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _isCompleted = false;
      _isLoading = true;
      _manageBackgroundMusic();
    });
    _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                "TEBRİKLER!",
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white,
                  letterSpacing: 2
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Tüm oyunları tamamladın.",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                ),
                child: const Text(
                  "EĞLENCEYİ TEKRARLAMAK\nİÇİN TIKLA",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    double progressValue = (_currentIndex + 1) / _gameUrls.length;
    Color currentColor = _levelColors[_currentIndex % _levelColors.length];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Üst Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: currentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // BURADA "OYUN X" YAZIYOR
                        child: Text(
                          'OYUN ${_currentIndex + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '%${(progressValue * 100).toInt()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      color: currentColor,
                    ),
                  ),
                ],
              ),
            ),

            // --- DEĞİŞİKLİK: ANİMASYONU KALDIRDIM ---
            // Artık düz Stack kullanıyoruz, hata vermez.
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  
                  if (_isLoading)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: currentColor,
                              strokeWidth: 4,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Oyun Hazırlanıyor...",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: currentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Alt Panel (Buton)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _nextGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SONRAKİ OYUN',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}