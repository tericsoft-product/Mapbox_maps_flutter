import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maps_flutter/screens/HomeScreen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _jsonSlideAnimation;
  late Animation<Offset> _bottomCardSlideAnimation;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _jsonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _bottomCardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from below the screen
      end: Offset.zero, // End at original position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCirc),
    ));

    // Start the bottom card animation immediately
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });

      // Start animation for showing JSON
      _animationController.forward();
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // Open app settings if permission is permanently denied
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/map-bg1.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.center,
                colors: [
                  Color(0xD0536DFE),
                  Color(0xD0F3F4F7),
                  // Colors.indigo,
                  // Colors.indigoAccent
                ],
              ),
            ),
            child: SafeArea(
              child: _isPermissionGranted
                  ? Center(
                      child: SlideTransition(
                        position: _jsonSlideAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Lottie animation
                            Lottie.asset(
                              'assets/lottie-files/success.json', // Replace with your lottie file path
                              onLoaded: (composition) {
                                // Navigate after the animation is completed
                                Future.delayed(
                                    composition.duration,
                                    // () => context.go('/home')
                                    () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const HomeScreen())));
                              },
                            ),
                            // const SizedBox(height: 16),
                            // Display JSON content
                            const Text(
                              'Location Access Granted! 🎉',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 70),
                        // Animated Lottie file
                        Image.asset(
                          'assets/icons/location_access.png',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                        const Spacer(),
                        // Animated Bottom Card
                        SlideTransition(
                          position: _bottomCardSlideAnimation,
                          child: Container(
                            width: double.infinity,
                            height: 350,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(60),
                                topRight: Radius.circular(60),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: Lottie.asset(
                                      'assets/lottie-files/location.json'),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    // List<Color> gradientColors = _getGradientColors(content.id);
                                    return LinearGradient(
                                      // colors: [Colors.blue, Colors.purple],
                                      colors: [Colors.blue, Colors.purple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    'Location Services',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    // List<Color> gradientColors = _getGradientColors(content.id);
                                    return LinearGradient(
                                      // colors: [Colors.blue, Colors.purple],
                                      colors: [Colors.blue, Colors.purple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'We need to know where you are in order to find nearby friends',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  width: 250,
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
                                          _requestLocationPermission();
                                          // Navigator.of(context).push(
                                          //     MaterialPageRoute(
                                          //         builder: (_) =>
                                          //             const LocationPermissionScreen()));
                                        },
                                        child: const Center(
                                          child: Text(
                                            'Request Location Access',
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
                                // ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
