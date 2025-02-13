import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class WeatherLayersScreen extends StatefulWidget {
  const WeatherLayersScreen({Key? key}) : super(key: key);

  @override
  State createState() => _WeatherLayersScreenState();
}

class _WeatherLayersScreenState extends State<WeatherLayersScreen> {
  MapboxMap? mapboxMap;
  String currentLayer = "temp_new"; // Default layer
  bool isMapStylesMenuOpen = false;

  final Map<String, String> weatherLayers = {
    "Temperature": "temp_new",
    "Wind": "wind_new",
    "Precipitation": "precipitation_new",
    "Pressure": "pressure_new",
    "Clouds": "clouds_new",
  };

  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    await map.compass.updateSettings(
      CompassSettings(
        enabled: true,
        position: OrnamentPosition.TOP_LEFT,
        marginLeft: 16,
        marginTop: 32,
      ),
    );
    _initializeWeatherLayer();
  }

  static String getApiKey() {
    print('${dotenv.env['WEATHER_API']} vserf sefser fer');
    return dotenv.env['WEATHER_API'] ?? '';
  }

  Future<void> _initializeWeatherLayer() async {
    try {
      // Add the source
      await mapboxMap?.style.addSource(
        RasterSource(
          id: "weather-source",
          tiles: [
            "https://tile.openweathermap.org/map/$currentLayer/{z}/{x}/{y}.png?appid=${getApiKey()}",
          ],
        ),
      );

      // Add the layer
      await mapboxMap?.style.addLayer(
        RasterLayer(
          id: 'weather-layer',
          sourceId: 'weather-source',
          rasterOpacity: 1.0,
          rasterFadeDuration: 0,
        ),
      );
    } catch (e) {
      print('Error adding weather layer: $e');
    }
  }

  Future<void> _updateWeatherLayer(String newLayer) async {
    try {
      // Remove existing layer and source
      await mapboxMap?.style.removeStyleLayer("weather-layer");
      await mapboxMap?.style.removeStyleSource("weather-source");

      // Update current layer and re-add source and layer
      setState(() {
        currentLayer = newLayer; // Update the selected layer
      });

      await _initializeWeatherLayer();
    } catch (e) {
      print('Error updating weather layer: $e');
    }
  }

  void closeMenu() {
    setState(() {
      isMapStylesMenuOpen = false;
    });
  }

  void _toggleMapStylesMenu() {
    setState(() {
      isMapStylesMenuOpen = !isMapStylesMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            onMapCreated: _onMapCreated,
            styleUri: MapboxStyles.DARK,
            cameraOptions: CameraOptions(
              center:
                  Point(coordinates: Position(-95.7129, 37.0902)), // US center
              zoom: 3.0,
            ),
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
                        child: _buildWeatherOptions(),
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
        ],
      ),
    );
  }

  Widget _buildWeatherOptions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: weatherLayers.keys.map((layer) {
          final isSelected = weatherLayers[layer] == currentLayer;
          return GestureDetector(
            onTap: () {
              _updateWeatherLayer(weatherLayers[layer]!);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                layer,
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
