import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maps_flutter/screens/HomeScreen.dart';
import 'package:maps_flutter/screens/LocationEnableScreen.dart';

class OnboardContent {
  final String id;
  final String title;
  final String description;
  final String imagePath;

  OnboardContent({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardContent> contents = [
    OnboardContent(
      id: '1',
      title: 'Global Navigation',
      description: 'Seamless global mapping experience with real-time updates.',
      imagePath: 'assets/icons/globe.png',
    ),
    OnboardContent(
      id: '2',
      title: 'Mark Locations',
      description: 'Save and share your favorite locations effortlessly.',
      imagePath: 'assets/icons/marker.png',
    ),
    OnboardContent(
      id: '3',
      title: 'GPS Tracking',
      description: 'Track your movements with high-precision GPS signals.',
      imagePath: 'assets/icons/compass.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < contents.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: contents.length,
            itemBuilder: (context, index) {
              return OnboardingPage(content: contents[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(height: 20),
                if (_currentPage < contents.length - 1)
                  Container(
                    width: 150,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.7),
                          Colors.purple.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(27),
                          onTap: _nextPage,
                          child: const Center(
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 150,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.7),
                          Colors.purple.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(27),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const HomeScreen()));
                          },
                          child: const Center(
                            child: Text(
                              'Explore',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardContent content;

  const OnboardingPage({super.key, required this.content});

  List<Color> _getGradientColors(String title) {
    switch (title) {
      case '1':
        return [Colors.blue, Colors.greenAccent];
      case '2':
        return [Colors.blueGrey, Colors.blue];
      case '3':
        return [Colors.white54, Colors.blueAccent];
      default:
        return [Colors.blue, Colors.purple]; // Default gradient
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF000000),
      // decoration: const BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [
      //       Color(0xFF0F172A),
      //       Color(0xFF1E293B),
      //     ],
      //   ),
      // ),

      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(width: 2)),
              child: Image.asset(
                content.imagePath,
                width: 400,
                height: 400,
                fit: BoxFit.contain,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) {
                List<Color> gradientColors = _getGradientColors(content.id);
                return LinearGradient(
                  // colors: [Colors.blue, Colors.purple],
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                content.title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) {
                List<Color> gradientColors = _getGradientColors(content.id);
                return LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                content.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
