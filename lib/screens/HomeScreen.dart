import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maps_flutter/screens/AddMarkersScreen.dart';
import 'package:maps_flutter/screens/DrawingPointsScreen.dart';
import 'package:maps_flutter/screens/GpsScreen.dart';
import 'package:maps_flutter/screens/WeatherLayersScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(45.0),
          margin: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello David",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.white70,
                        ),
                      )
                    ],
                  ),
                  // Image.asset(
                  //   'assets/icons/filter.png',
                  //   height: 24,
                  //   width: 24,
                  // )
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  children: [
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 150,
                      child: _buildAnimatedCard(
                        "GPS",
                        const Color(0xFFBCDFDC),
                        'assets/icons/home/compass.png',
                        const GpsScreen(),
                      ),
                    ),
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 180,
                      child: _buildAnimatedCard(
                        "Markers",
                        const Color(0xFFE8DEF2),
                        'assets/icons/home/marker.png',
                        const AddMarkersScreen(),
                      ),
                    ),
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 180,
                      child: _buildAnimatedCard(
                        "Weather",
                        const Color(0xFFF2EEEA),
                        'assets/icons/home/weather.png',
                        const WeatherLayersScreen(),
                      ),
                    ),
                    StaggeredGridTile.extent(
                      crossAxisCellCount: 1,
                      mainAxisExtent: 150,
                      child: _buildAnimatedCard(
                        "Draw",
                        const Color(0xFFF1DFDE),
                        'assets/icons/home/draw.png',
                        const DrawingPointsScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(
      String title, Color color, String iconAsset, Widget destinationScreen) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}), // Detect press
      onTapUp: (_) => setState(() {}), // Reset
      child: _AnimatedCard(
        title: title,
        color: color,
        iconAsset: iconAsset,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        },
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final String title;
  final Color color;
  final String iconAsset;
  final VoidCallback onTap;

  const _AnimatedCard({
    required this.title,
    required this.color,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _isPressed = false;
          });
          widget.onTap();
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.95 : 1.0,
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.iconAsset,
                height: 24,
                width: 24,
              ),
              const SizedBox(height: 15),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
