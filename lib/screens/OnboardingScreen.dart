import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maps_flutter/screens/LocationEnableScreen.dart';

class OnboardingContent {
  final String title;
  final String description;
  final Color backgroundColor;
  final Color textColor;
  final String backgroundImage; // Added field for background image

  OnboardingContent({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.backgroundImage,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> contents = [
    OnboardingContent(
      title: 'Mark your favorite spots.',
      description:
          'Add markers on the map, give them names, edit details, or remove them anytime.',
      backgroundColor: Color(0xD033508B),
      textColor: Color(0xD0F6BB85),
      backgroundImage: 'assets/images/map-bg1.png', // Add your image path
    ),
    OnboardingContent(
      title: 'Shape the map your way.',
      description:
          'Draw lines, create polygons, and place custom icons to make the map uniquely yours.',
      backgroundColor: Color(0xFF62435F),
      textColor: Color(0xD0F68484),
      backgroundImage: 'assets/images/map-bg2.png', // Add your image path
    ),
    OnboardingContent(
      title: 'Explore weather layers on the map.',
      description:
          'View live weather updates like temperature, wind, precipitation, cloud cover, and pressure.',
      backgroundColor: Color(0xFF397642),
      textColor: Color(0xFFFAB9EC),
      backgroundImage: 'assets/images/map-bg1.png', // Add your image path
    ),
  ];

  // Rest of the _OnboardingScreenState implementation remains the same...
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
    // The build method remains the same...
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    contents.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_currentPage < contents.length - 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          margin: const EdgeInsets.only(right: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (_) =>
                                    const LocationPermissionScreen()));
                            // context.go('/enable_location');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
  final OnboardingContent content;

  const OnboardingPage({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(content.backgroundImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                content.backgroundColor,
                BlendMode.overlay,
              ),
            ),
          ),
        ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                content.backgroundColor.withOpacity(0.8),
                content.backgroundColor.withOpacity(0.9),
              ],
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                content.title,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w500,
                  color: content.textColor,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                content.description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
