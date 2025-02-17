import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:ui' as ui;

class DrawingPointsScreen extends StatefulWidget {
  const DrawingPointsScreen({super.key});

  @override
  _DrawingPointsScreenState createState() => _DrawingPointsScreenState();
}

class _DrawingPointsScreenState extends State<DrawingPointsScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  bool isDrawing = false;
  bool isDrawingMode = false;
  List<Offset> drawingCoordinates = [];
  List<List<Offset>> completedLines = [];
  String selectedIcon = 'assets/icons/dot.png';
  Offset? lastPoint;

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapboxMap?.setBounds(CameraBoundsOptions(
        maxZoom: 14, minZoom: 12, maxPitch: 10, minPitch: 0));
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    await mapboxMap.gestures.updateSettings(GesturesSettings(
      scrollEnabled: true,
      rotateEnabled: true,
      pinchToZoomEnabled: true,
      doubleTapToZoomInEnabled: true,
      doubleTouchToZoomOutEnabled: true,
      quickZoomEnabled: true,
      pitchEnabled: true,
    ));
  }

  void _toggleMode() {
    setState(() {
      isDrawingMode = !isDrawingMode;
      // Clear all drawing data when switching modes
      isDrawing = false;
      drawingCoordinates.clear();
      completedLines.clear(); // Clear completed lines
      lastPoint = null;
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (!isDrawingMode) return;
    setState(() {
      isDrawing = true;
      drawingCoordinates = [details.localPosition];
      lastPoint = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!isDrawingMode || !isDrawing) return;
    if (lastPoint != null) {
      List<Offset> interpolatedPoints = interpolatePoints(
        lastPoint!,
        details.localPosition,
        5.0,
      );

      setState(() {
        drawingCoordinates.addAll(interpolatedPoints);
        lastPoint = details.localPosition;
      });
    }
  }

  List<Offset> interpolatePoints(Offset start, Offset end, double spacing) {
    List<Offset> points = [];

    double distance = (end - start).distance;
    if (distance < spacing) {
      points.add(end);
      return points;
    }

    int numberOfPoints = (distance / spacing).ceil();
    for (int i = 1; i <= numberOfPoints; i++) {
      double t = i / numberOfPoints;
      double x = start.dx + (end.dx - start.dx) * t;
      double y = start.dy + (end.dy - start.dy) * t;
      points.add(Offset(x, y));
    }

    return points;
  }

  Future<void> _addMarkerAtPosition(Point coordinates) async {
    if (mapboxMap == null || pointAnnotationManager == null) return;

    final ByteData bytes = await rootBundle.load(selectedIcon);
    final Uint8List image = bytes.buffer.asUint8List();

    final options = PointAnnotationOptions(
      geometry: coordinates,
      iconSize: 0.4,
      image: image,
      textSize: 20,
      textOffset: [0, 2],
      textAnchor: TextAnchor.BOTTOM,
    );

    await pointAnnotationManager!.create(options);
  }

  Future<void> _processDrawingCoordinates() async {
    if (mapboxMap == null) return;

    const int batchSize = 10;
    for (int i = 0; i < drawingCoordinates.length; i += batchSize) {
      int end = min(i + batchSize, drawingCoordinates.length);
      List<Future<void>> batch = [];

      for (int j = i; j < end; j++) {
        Offset screenPosition = drawingCoordinates[j];
        try {
          var screenCoord =
              ScreenCoordinate(x: screenPosition.dx, y: screenPosition.dy);
          var point = await mapboxMap!.coordinateForPixel(screenCoord);
          batch.add(_addMarkerAtPosition(Point(
            coordinates: Position(point.coordinates.lng, point.coordinates.lat),
          )));
        } catch (e) {
          print('Error converting coordinates: $e');
        }
      }
      await Future.wait(batch);
    }
  }

  void _onPanEnd(DragEndDetails details) async {
    if (!isDrawingMode) return;
    setState(() {
      isDrawing = false;
      if (drawingCoordinates.isNotEmpty) {
        completedLines.add(List.from(drawingCoordinates));
      }
    });

    await _processDrawingCoordinates();

    setState(() {
      drawingCoordinates.clear();
      lastPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMode,
        child: Icon(isDrawingMode ? Icons.edit : Icons.pan_tool),
        tooltip: isDrawingMode
            ? 'Switch to Movement Mode'
            : 'Switch to Drawing Mode',
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapWidget(
              onMapCreated: _onMapCreated,
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(78.49895980860205, 17.374633752848528),
                ),
                zoom: 14,
              ),
            ),
          ),
          if (isDrawingMode)
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: DrawingPainter(
                  completedLines: completedLines,
                  currentLine: drawingCoordinates,
                ),
                size: ui.Size.infinite,
              ),
            ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> completedLines;
  final List<Offset> currentLine;

  DrawingPainter({
    required this.completedLines,
    required this.currentLine,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (var line in completedLines) {
      if (line.length < 2) continue;
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    if (currentLine.length >= 2) {
      for (int i = 0; i < currentLine.length - 1; i++) {
        canvas.drawLine(currentLine[i], currentLine[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
