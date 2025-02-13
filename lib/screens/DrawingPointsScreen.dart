// DrawingPointsScreen
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
  List<Offset> drawingCoordinates = [];
  List<List<Offset>> completedLines = [];
  String selectedIcon = 'assets/icons/dot.png';
  Offset? lastPoint;

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
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

  void _onPanStart(DragStartDetails details) {
    setState(() {
      isDrawing = true;
      drawingCoordinates = [details.localPosition];
      lastPoint = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (lastPoint != null) {
      // Interpolate between last point and current point
      List<Offset> interpolatedPoints = interpolatePoints(
        lastPoint!,
        details.localPosition,
        5.0, // Adjust this value to control point density (smaller = more points)
      );

      setState(() {
        drawingCoordinates.addAll(interpolatedPoints);
        lastPoint = details.localPosition;
      });
    }
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
        textAnchor: TextAnchor.BOTTOM);

    await pointAnnotationManager!.create(options);
  }

  Future<void> _processDrawingCoordinates() async {
    if (mapboxMap == null) return;

    // Convert screen coordinates to map coordinates and add markers
    // Process points in batches to improve performance
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
            coordinates: Position(
              point.coordinates.lng,
              point.coordinates.lat,
            ),
          )));
        } catch (e) {
          print('Error converting coordinates: $e');
        }
      }

      // Wait for current batch to complete
      await Future.wait(batch);
    }
  }

  void _onPanEnd(DragEndDetails details) async {
    setState(() {
      isDrawing = false;
      completedLines.add(List.from(drawingCoordinates));
    });

    // Process all drawing coordinates and add markers
    await _processDrawingCoordinates();

    // Clear drawing coordinates and last point after processing
    setState(() {
      drawingCoordinates.clear();
      lastPoint = null;
    });

    print('Total points captured: ${completedLines.last.length}');
  }

  @override
  Widget build(BuildContext context) {
    print('${drawingCoordinates.length} ${completedLines.length} oloololololo');
    return Scaffold(
      body: Stack(
        children: [
          // Mapbox Map
          Positioned.fill(
            child: MapWidget(
              onMapCreated: _onMapCreated,
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(78.49895980860205, 17.374633752848528),
                ),
                zoom: 15,
              ),
            ),
          ),
          // Drawing Layer
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

    // Draw completed lines
    for (var line in completedLines) {
      if (line.length < 2) continue;
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    // Draw the current line
    if (currentLine.length >= 2) {
      for (int i = 0; i < currentLine.length - 1; i++) {
        canvas.drawLine(currentLine[i], currentLine[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
