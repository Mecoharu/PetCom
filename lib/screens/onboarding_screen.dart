import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(emoji: '🐕', title: 'Find Your\n Anabul ', subtitle: 'Thousands of adorable animals are waiting for a warm and loving home.', color: Color(0xFFE8622A)),
    //_OnboardPage(emoji: '🏡', title: 'Buka Adopsi\nHewan Anda', subtitle: 'Punya hewan yang butuh rumah baru? Post adopsi dan temukan pemilik yang tepat.', color: Color(0xFF4CAF50)),
    //_OnboardPage(emoji: '💕', title: 'Adopsi Penuh\nCinta', subtitle: 'Proses adopsi yang mudah, aman, dan terpercaya. Karena setiap hewan berhak dicintai.', color: Color(0xFFFFB347)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _pages[i],
          ),
          // Dots
          Positioned(
            bottom: 140,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? _pages[_page].color : _pages[_page].color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
          // Buttons
          Positioned(
            bottom: 40,
            left: 24, right: 24,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_page < _pages.length - 1) {
                      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } else {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _pages[_page].color),
                  child: Text(_page == _pages.length - 1 ? 'Start Now' : 'Next'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Skip', style: GoogleFonts.nunito(color: const Color(0xFF8B5E3C), fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardPage({required this.emoji, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 90))),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w600, color: const Color(0xFF2C1810), height: 1.2),
                ),
                const SizedBox(height: 16),
                Text(subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 16, color: const Color(0xFF8B5E3C), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
