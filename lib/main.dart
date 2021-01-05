import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:latlong/latlong.dart';
import 'package:polygonConcept/intersectionDetector.dart';

void main() => runApp(MaterialApp(home: PolygonConcept()));

class PolygonConcept extends StatefulWidget {
  @override
  _PolygonConceptState createState() => _PolygonConceptState();
}

class _PolygonConceptState extends State<PolygonConcept> {
  List<LatLng> polygonPoints = [];
  List<Offset> polygonOffsets = [];
  bool isPolygonCompleted = false;
  int offsetIndex = 0;
  double rotateVal = 0;

  Widget pathTraverser = Container();
  Widget intersectionPath = Container();
  List<Widget> intersectionPoints = List<Widget>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTapDown: (detail) => _getOffset(detail),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(49.464852, 11.076512),
                  zoom: 13.0,
                  onTap: _handleTap,
                  onLongPress: _completePolygon,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(markers: _getMarkers()),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                        points: polygonPoints,
                        strokeWidth: 4.0,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            intersectionPath,
            pathTraverser,
            ...intersectionPoints,
            SlidingUpPanelWidget(
              controlHeight: 100,
              panelController: null,
              child: Container(
                color: Colors.white,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: RaisedButton(
                          onPressed: _traversePaths,
                          child: Text('Traverse Paths'),
                        ),
                      ),
                      Container(
                        child: RaisedButton(
                          onPressed: _rotatePath,
                          child: Text('Rotate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rotatePath() {
    setState(() {
      rotateVal += 10;
      intersectionPath = Container(
        child: CustomPaint(
          painter: EdgePainter(
            Offset(rotateVal, 0),
            Offset(
              MediaQuery.of(context).size.width - rotateVal,
              MediaQuery.of(context).size.height,
            ),
            color: Colors.yellow,
          ),
          child: Container(),
        ),
      );
    });

    _intersectionPoints();
  }

  void _traversePaths() {
    var start = offsetIndex % polygonOffsets.length;
    var end = (offsetIndex + 1) % polygonOffsets.length;
    print('Path: from ${polygonOffsets[start]} to ${polygonOffsets[end]}');

    setState(() {
      offsetIndex++;
      pathTraverser = Container(
        child: CustomPaint(
          painter: EdgePainter(
            polygonOffsets[start],
            polygonOffsets[end],
          ),
        ),
      );
    });
  }

  void _intersectionPoints() {
    if (!isPolygonCompleted) return;

    setState(() {
      intersectionPoints.clear();
    });
    var offsetStart = Offset(rotateVal, 0);
    var offsetEnd = Offset(
      MediaQuery.of(context).size.width - rotateVal,
      MediaQuery.of(context).size.height,
    );

    for (var i = 0; i < polygonOffsets.length - 1; i++) {
      var intersectDetector = IntersectionDetector(
        offsetStart,
        offsetEnd,
        polygonOffsets[i],
        polygonOffsets[i + 1],
      );

      if (intersectDetector.isIntersect()) {
        double a1 = offsetEnd.dy - offsetStart.dy;
        double b1 = offsetStart.dx - offsetEnd.dx;
        double c1 = a1 * offsetStart.dx + b1 * offsetStart.dy;

        double a2 = polygonOffsets[i + 1].dy - polygonOffsets[i].dy;
        double b2 = polygonOffsets[i].dx - polygonOffsets[i + 1].dx;
        double c2 = a2 * polygonOffsets[i].dx + b2 * polygonOffsets[i].dy;

        double delta = a1 * b2 - a2 * b1;
        Offset intersection = delta == 0
            ? Offset(150, 30)
            : Offset((b2 * c1 - b1 * c2) / delta, (a1 * c2 - a2 * c1) / delta);

        setState(() {
          intersectionPoints.add(
            Container(
              child: CustomPaint(
                painter: CrossPointer(intersection),
                child: Container(),
              ),
            ),
          );
        });
      }
    }
  }

  void _handleTap(LatLng latLng) {
    setState(() {
      if (isPolygonCompleted) {
        isPolygonCompleted = false;
        polygonPoints.clear();
        polygonOffsets.clear();
      }

      polygonPoints.add(latLng);
    });
  }

  void _completePolygon(LatLng latLng) {
    setState(() {
      if (polygonPoints.length >= 2) {
        polygonPoints.add(latLng);
        polygonPoints.add(polygonPoints.first);
        isPolygonCompleted = true;

        intersectionPath = Container(
          child: CustomPaint(
            painter: EdgePainter(
              Offset(0, 0),
              Offset(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              color: Colors.yellow,
            ),
            child: Container(),
          ),
        );
      }
    });

    _intersectionPoints();
  }

  void _getOffset(TapDownDetails details) {
    setState(() {
      polygonOffsets.add(details.globalPosition);
    });
  }

  List<Marker> _getMarkers() {
    return polygonPoints.map(
      (latLng) {
        return _getMarker(latLng);
      },
    ).toList();
  }

  Marker _getMarker(LatLng latLng) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: latLng,
      builder: (ctx) => Container(
        child: Icon(
          Icons.fiber_manual_record_outlined,
          color: Colors.red,
          size: 45.0,
        ),
      ),
    );
  }
}

class EdgePainter extends CustomPainter {
  final Offset offsetStart;
  final Offset offsetEnd;
  final Color color;

  EdgePainter(this.offsetStart, this.offsetEnd, {this.color = Colors.purple});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 4;
    canvas.drawLine(offsetStart, offsetEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CrossPointer extends CustomPainter {
  final Offset offset;

  CrossPointer(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 7;
    canvas.drawPoints(PointMode.points, <Offset>[offset], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
