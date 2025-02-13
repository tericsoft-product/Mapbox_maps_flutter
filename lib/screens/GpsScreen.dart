import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:geolocator/geolocator.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  double? latitude;
  double? longitude;
  mapbox.MapboxMap? mapboxMap;
  String currentMapStyle = mapbox.MapboxStyles.STANDARD;
  bool isMapStylesMenuOpen = false;

  final Map<String, String> mapStyles = {
    "Standard View": mapbox.MapboxStyles.STANDARD,
    "Satellite View": mapbox.MapboxStyles.SATELLITE,
    "Dark View": mapbox.MapboxStyles.DARK,
    "Street View": mapbox.MapboxStyles.MAPBOX_STREETS,
    "Satellite Street View": mapbox.MapboxStyles.SATELLITE_STREETS,
  };

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getInitialLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        print("Latitude: $latitude, Longitude: $longitude");
      });

      if (mapboxMap != null) {
        await _enableLocationTracking();
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _enableLocationTracking() async {
    try {
      await mapboxMap!.location.updateSettings(
        mapbox.LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          puckBearingEnabled: true,
          showAccuracyRing: true,
        ),
      );
    } catch (e) {
      print("Error enabling location tracking: $e");
    }
  }

  Future<void> _updateMapStyle(String styleUrl) async {
    if (mapboxMap != null) {
      try {
        await mapboxMap!.loadStyleURI(styleUrl);
        setState(() {
          currentMapStyle = styleUrl;
        });
      } catch (e) {
        print("Error updating map style: $e");
      }
    }
  }

  void _toggleMapStylesMenu() {
    setState(() {
      isMapStylesMenuOpen = !isMapStylesMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    mapbox.CameraOptions camera = mapbox.CameraOptions(
      center: mapbox.Point(
        coordinates: mapbox.Position(
          longitude ?? 2.2945134840474903,
          latitude ?? 48.85844771733131,
        ),
      ),
      zoom: 18,
      bearing: 50,
      pitch: 45,
    );

    void closeMenu() {
      setState(() {
        isMapStylesMenuOpen = false;
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map Widget takes full screen
          mapbox.MapWidget(
            cameraOptions: camera,
            styleUri: currentMapStyle,
            onMapCreated: (mapbox.MapboxMap controller) async {
              mapboxMap = controller;
              if (latitude != null && longitude != null) {
                await _enableLocationTracking();
              }

              await controller.compass.updateSettings(
                mapbox.CompassSettings(
                  enabled: true,
                  position: mapbox.OrnamentPosition.TOP_LEFT,
                  marginLeft: 16,
                  marginTop: 32,
                ),
              );
            },
          ),

          // Invisible layer to handle outside taps
          if (isMapStylesMenuOpen)
            Positioned.fill(
              child: Listener(
                onPointerDown: (_) {
                  if (isMapStylesMenuOpen) {
                    closeMenu();
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    if (isMapStylesMenuOpen) {
                      closeMenu();
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),

          // Map style button and menu
          Positioned(
            top: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                isMapStylesMenuOpen
                    ? GestureDetector(
                        onTap:
                            () {}, // Prevent taps from reaching the invisible layer
                        child: _buildMapStyleOptions(),
                      )
                    : GestureDetector(
                        onTap: _toggleMapStylesMenu,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/icons/filter.png',
                            color: Colors.white,
                            // size: 24,
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // Recenter button
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: "recenterButton",
              onPressed: () async {
                if (latitude != null &&
                    longitude != null &&
                    mapboxMap != null) {
                  await mapboxMap!.flyTo(
                    mapbox.CameraOptions(
                      center: mapbox.Point(
                        coordinates: mapbox.Position(longitude!, latitude!),
                      ),
                      zoom: 17,
                      bearing: 180,
                      pitch: 30,
                      anchor: mapbox.ScreenCoordinate(x: 34.43, y: 53.43),
                    ),
                    mapbox.MapAnimationOptions(duration: 1500, startDelay: 0),
                  );
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapStyleOptions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: mapStyles.keys.map((styleName) {
          final isSelected = mapStyles[styleName] == currentMapStyle;
          return GestureDetector(
            onTap: () {
              _updateMapStyle(mapStyles[styleName]!);
            },
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 150, // Set minimum width
              ),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                textAlign: TextAlign.center,
                styleName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
