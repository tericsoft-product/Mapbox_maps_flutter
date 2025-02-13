import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MarkerData {
  final String id;
  final Point position;
  String title;
  Color color;

  MarkerData({
    required this.id,
    required this.position,
    required this.title,
    required this.color,
  });
}

class PointAnnotationClickListener extends OnPointAnnotationClickListener {
  PointAnnotationClickListener({
    required this.onAnnotationClick,
  });

  final void Function(PointAnnotation annotation) onAnnotationClick;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print("onPointAnnotationClick, id: ${annotation.id}");
    onAnnotationClick(annotation);
  }
}

class AddMarkersScreen extends StatefulWidget {
  const AddMarkersScreen({super.key});

  @override
  _AddMarkersScreenState createState() => _AddMarkersScreenState();
}

class _AddMarkersScreenState extends State<AddMarkersScreen>
    with SingleTickerProviderStateMixin {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  final List<PointAnnotation> _markers = [];
  final List<MarkerData> _markerDataList = [];
  String currentLayer = "add_markers"; // Default layer
  bool isMapStylesMenuOpen = false;

  final Map<String, String> weatherLayers = {
    "Add Markers": "add_markers",
    "Add Icons": "add_icons",
  };

  String selectedIcon = 'assets/icons/location.png';
  List<Map<String, String>> icons = [
    {"icon": 'assets/icons/fire.png', "name": "Fire"},
    {"icon": 'assets/icons/hospital.png', "name": "Hospital"},
    {"icon": 'assets/icons/luggage.png', "name": "Luggage"},
    {"icon": 'assets/icons/restaurant.png', "name": "Restaurant"},
  ];

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0, // Start with no size
      end: 1.0, // Scale to full size
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    await mapboxMap.compass.updateSettings(
      CompassSettings(
        enabled: true,
        position: OrnamentPosition.TOP_LEFT,
        marginLeft: 16,
        marginTop: 32,
      ),
    );

    pointAnnotationManager?.addOnPointAnnotationClickListener(
      PointAnnotationClickListener(
        onAnnotationClick: (annotation) {
          final index =
              _markers.indexWhere((marker) => marker.id == annotation.id);
          if (index != -1) {
            print("Clicked on marker: ${_markerDataList[index].title}");
            _editMarker(index, 'Edit Title');
          }
        },
      ),
    );
  }

  void _onTap(MapContentGestureContext context) {
    final coordinates = context.point.coordinates;
    print("OnLongTap coordinate: {${coordinates.lng}, ${coordinates.lat}}" +
        " point: {x: ${context.touchPosition.x}, y: ${context.touchPosition.y}}" +
        " state: ${context.gestureState}");

    // Add marker at the long press location
    _addMarkerAtPosition(Point(
      coordinates: Position(
        coordinates.lng,
        coordinates.lat,
      ),
    ));
  }

  Future<void> _addMarkerAtPosition(Point coordinates) async {
    if (mapboxMap == null || pointAnnotationManager == null) return;

    // Create marker data
    final markerData = MarkerData(
      id: '1',
      position: coordinates,
      title: '',
      color: Colors.red,
    );

    var loadIcon = currentLayer == 'add_markers'
        ? 'assets/icons/location.png'
        : selectedIcon;

    final ByteData bytes = await rootBundle.load(loadIcon);
    final Uint8List image = bytes.buffer.asUint8List();

    // Create point annotation options
    final options = PointAnnotationOptions(
        geometry: coordinates,
        iconSize: currentLayer == 'add_markers' ? 0.3 : 0.8,
        image: image,
        textField: markerData.title,
        textSize: 20,
        textOffset: [0, 2],
        textTransform: TextTransform.UPPERCASE,
        textAnchor: TextAnchor.BOTTOM);

    // Add point annotation
    final pointAnnotation = await pointAnnotationManager!.create(options);

    setState(() {
      _markers.add(pointAnnotation);
      _markerDataList.add(markerData);
    });

    // Show edit dialog after creating
    // _editMarker(_markerDataList.length - 1, 'Add Title');
  }

  Future<void> _editMarker(int index, String title) async {
    if (pointAnnotationManager == null) return;

    final markerData = _markerDataList[index];
    final markerPoint = _markers[index];

    showDialog(
      context: context,
      builder: (context) {
        _controller.forward(); // Start the animation
        return ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  controller: TextEditingController(text: markerData.title),
                  onChanged: (value) =>
                      {markerData.title = value, markerPoint.textField = value},
                ),
                const SizedBox(height: 16),
                // Display coordinates
                Text(
                  'Location: ${markerData.position.coordinates[1]?.toStringAsFixed(4)}, ${markerData.position.coordinates[0]?.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _controller.reverse(); // Reverse the animation
                  Navigator.pop(context); // Close the dialog
                  _removeMarker(index); // Remove the marker
                },
                child: const Text('Delete'),
              ),
              TextButton(
                onPressed: () async {
                  await _controller.reverse(); // Reverse the animation
                  Navigator.pop(context); // Close the dialog
                  await pointAnnotationManager!.update(_markers[index]);
                  setState(() {});
                },
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: () async {
                  await _controller.reverse(); // Reverse the animation
                  Navigator.pop(context); // Close the dialog

                  if (mapboxMap != null) {
                    await mapboxMap!.flyTo(
                      CameraOptions(
                        center: Point(
                          coordinates: Position(
                            markerData.position.coordinates[0]!,
                            markerData.position.coordinates[1]!,
                          ),
                        ),
                        zoom: 17,
                        bearing: 180,
                        pitch: 30,
                        anchor: ScreenCoordinate(x: 34.43, y: 53.43),
                      ),
                      MapAnimationOptions(duration: 2000, startDelay: 0),
                    );
                  }

                  await pointAnnotationManager!.update(_markers[index]);
                  setState(() {});
                },
                child: const Text('Navigate'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _controller.reset(); // Reset the animation when the dialog is closed
    });
  }

  Future<void> _removeMarker(int index) async {
    if (pointAnnotationManager == null) return;

    await pointAnnotationManager!.delete(_markers[index]);

    setState(() {
      _markers.removeAt(index);
      _markerDataList.removeAt(index);
    });
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
            styleUri: MapboxStyles.STANDARD,
            cameraOptions: CameraOptions(
              center: Point(
                  coordinates: Position(78.49970680992669, 17.37263285651427)),
              zoom: 14.0,
            ),
            onTapListener: _onTap,
            onMapCreated: _onMapCreated,
          ),
          if (currentLayer == 'add_icons')
            Positioned(
              top: 80,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: icons.map((iconData) {
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          selectedIcon = iconData['icon']!;
                        });

                        print("Selected icon: ${iconData} ${selectedIcon}");
                        // await _getCenterCoordinates(iconData);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedIcon == iconData['icon']
                              ? Colors.blue
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.asset(
                          iconData['icon']!,
                          height: 24,
                          width: 24,
                          // color: selectedIcon == iconData['icon']
                          //     ? Colors.white
                          //     : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
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
              setState(() {
                currentLayer =
                    weatherLayers[layer]!; // Update the selected layer
              });
              isMapStylesMenuOpen = false;
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
