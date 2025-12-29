import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  // Uygulamanın ve pluginlerin yüklenmesini garantiye alır
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Game Box',
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
            // Başlık Kutusu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                '🎮 SUPER\nGAMES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.deepPurple,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 60),
            // Başla Butonu
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Altın Sarısı
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 25,
                ),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebViewController _controller;
  int _currentIndex = 0;
  bool _isLoading = true;

  // Oyun Linkleri Listesi
  final List<String> _gameUrls = [
    'https://poki.com/en/g/subway-surfers',
    'https://poki.com/en/g/temple-run-2',
    'https://poki.com/en/g/monkey-mart',
    'https://poki.com/en/g/super-stacker-2',
    'https://poki.com/en/g/crossy-road',
    'https://poki.com/en/g/stickman-hook',
    'https://poki.com/en/g/drive-mad',
    'https://poki.com/en/g/moto-x3m',
    'https://poki.com/en/g/soccer-skills-world-cup',
    'https://poki.com/en/g/tag',
  ];

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Controller oluşturuluyor (V4 Syntax)
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('HATA OLUŞTU: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_gameUrls[_currentIndex]));
  }

  void _nextGame() {
    setState(() {
      _currentIndex++;
      // Liste sonuna gelince başa dön
      if (_currentIndex >= _gameUrls.length) {
        _currentIndex = 0;
      }
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(_gameUrls[_currentIndex]));
  }

  @override
  Widget build(BuildContext context) {
    // İlerleme Mantığı: Level 1 -> %10, Level 2 -> %20...
    double progressValue = (_currentIndex + 1) * 0.1;
    if (progressValue > 1.0) progressValue = 1.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Üst Panel (Level ve Progress Bar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.deepPurple.shade50,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LEVEL ${_currentIndex + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${(progressValue * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 15,
                      backgroundColor: Colors.deepPurple.shade100,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),

            // Orta Kısım: Oyun Ekranı (WebView)
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.deepPurple),
                            SizedBox(height: 16),
                            Text(
                              "Oyun Yükleniyor...",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Alt Kısım: İleri Butonu
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
                height: 56,
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
                  child: const Text(
                    'SONRAKİ OYUN ➔',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
