import 'dart:async';
import 'dart:math';
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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen(isRandomStart: false)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'MACERAYA BAŞLA',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen(isRandomStart: true)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.casino, size: 28),
              label: const Text(
                'SÜRPRİZ OYUN',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool isRandomStart;
  const GameScreen({super.key, required this.isRandomStart});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebViewController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isCompleted = false;

  int _sessionGameCount = 1; 
  bool _isBreakTime = false; 
  int _breakCountdown = 10;  
  Timer? _timer;             

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
    if (widget.isRandomStart) {
      _currentIndex = Random().nextInt(_gameUrls.length);
    } else {
      _currentIndex = 0;
    }
    _initializeWebView();
    _manageBackgroundMusic();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _manageBackgroundMusic() async {
    try {
      if (_isBreakTime || _isCompleted) {
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
      debugPrint("Audio Error: $e");
    }
  }

  void _initializeWebView() {
    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setBackgroundColor(const Color(0xFFFFFFFF));
    _controller.clearCache(); 
    _controller.setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.181 Mobile Safari/537.36");

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (String url) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView Error: ${error.description}');
        },
      ),
    );
    _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
  }

  void _handleNextButton() {
    _sessionGameCount++;
    if (_sessionGameCount % 4 == 0) {
      _startBreakTime(); 
    } else {
      _goToNextGame(); 
    }
  }

  void _startBreakTime() {
    setState(() {
      _isBreakTime = true;
      _breakCountdown = 10; 
    });
    _manageBackgroundMusic();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_breakCountdown > 0) {
            _breakCountdown--;
          } else {
            _timer?.cancel();
            _isBreakTime = false;
            _goToNextGame(); 
          }
        });
      }
    });
  }

  void _goToNextGame() {
    setState(() {
      if (widget.isRandomStart) {
        _currentIndex = Random().nextInt(_gameUrls.length);
        _isLoading = true;
        _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
      } else {
        if (_currentIndex < _gameUrls.length - 1) {
          _currentIndex++;
          _isLoading = true;
          _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
        } else {
          _isCompleted = true; 
        }
      }
      _manageBackgroundMusic();
    });
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _sessionGameCount = 1; 
      _isCompleted = false;
      _isLoading = true;
      _manageBackgroundMusic();
    });
    _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
  }

  @override
  Widget build(BuildContext context) {
    if (_isBreakTime) {
      return Scaffold(
        backgroundColor: const Color(0xFF4DB6AC), 
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.visibility_off_outlined, size: 100, color: Colors.white),
              const SizedBox(height: 30),
              const Text("Gözlerini Dinlendir", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              const Text("Uzağa bak veya gözlerini kapat.", style: TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 50),
              Text("$_breakCountdown", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              const Text("Saniye kaldı...", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    if (_isCompleted) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              const Text("TEBRİKLER!", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 10),
              const Text("Tüm oyunları tamamladın.", style: TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text("TEKRAR OYNA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    double progressValue = (_currentIndex + 1) / _gameUrls.length;
    Color appBarColor = _levelColors[_currentIndex % _levelColors.length];
    Color buttonColor = _levelColors[(_currentIndex + 10) % _levelColors.length];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'OYUN ${_currentIndex + 1}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '%${(progressValue * 100).toInt()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      color: appBarColor,
                    ),
                  ),
                ],
              ),
            ),
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
                            CircularProgressIndicator(color: appBarColor, strokeWidth: 4),
                            const SizedBox(height: 20),
                            Text("Oyun Hazırlanıyor...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appBarColor)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleNextButton,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.isRandomStart ? 'BAŞKA OYUN' : 'SONRAKİ OYUN',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Icon(widget.isRandomStart ? Icons.casino : Icons.arrow_forward_rounded, size: 28),
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