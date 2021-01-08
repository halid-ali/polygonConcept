import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:latlong/latlong.dart';
import 'package:polygonConcept/common/intersectionPath.dart';
import 'package:polygonConcept/intersectionDetector.dart';
import 'package:polygonConcept/playground.dart';

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
  double angle = 0;
  IntersectionPath intersectionPath;

  Widget pathTraverser = Container();
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
            Container(
              child: CustomPaint(
                painter: intersectionPath,
              ),
            ),
            pathTraverser,
            ...intersectionPoints,
            SlidingUpPanelWidget(
              controlHeight: 150,
              panelController: null,
              child: Container(
                color: Colors.white,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            child: RaisedButton(
                              onPressed: _traversePaths,
                              child: Text('Traverse Paths'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                        child: Slider(
                          value: angle,
                          min: 0,
                          max: 360,
                          divisions: 36,
                          activeColor: Colors.red,
                          label: angle.round().toString(),
                          onChanged: (double value) => _rotateAngle(value),
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

  void _rotateAngle(double value) {
    setState(() {
      angle = value;
      var len = intersectionPath.length / 2;
      var iStartX = intersectionPath.start.dx;
      var iStartY = intersectionPath.start.dy;
      var iEndX = intersectionPath.end.dx;
      var iEndY = intersectionPath.end.dy;
      double radAngle;
      Offset newStart;
      Offset newEnd;
      double xDiff;
      double yDiff;

      if (angle >= 0 && angle <= 90) {
        radAngle = value * pi / 180;
        xDiff = sin(radAngle) * len;
        yDiff = cos(radAngle) * len;

        newStart = Offset(iStartX + xDiff, iStartY + (len - yDiff));
        newEnd = Offset(iEndX - xDiff, iEndY - (len - yDiff));
      }
      if (angle > 90 && angle <= 180) {
        radAngle = (value - 90) * pi / 180;
        xDiff = sin(radAngle) * intersectionPath.length / 2;
        yDiff = cos(radAngle) * intersectionPath.length / 2;

        newStart = Offset(iStartX - xDiff, iStartY + yDiff);
        newEnd = Offset(iEndX + xDiff, iEndY - yDiff);
      }
      if (angle > 180 && angle <= 270) {
        radAngle = (value - 180) * pi / 180;
        xDiff = cos(radAngle) * intersectionPath.length / 2;
        yDiff = sin(radAngle) * intersectionPath.length / 2;

        newStart = Offset(iStartX - xDiff, iStartY - yDiff);
        newEnd = Offset(iEndX + xDiff, iEndY + yDiff);
      }
      if (angle > 270 && angle <= 360) {
        radAngle = (value - 270) * pi / 180;
        xDiff = cos(radAngle) * intersectionPath.length / 2;
        yDiff = sin(radAngle) * intersectionPath.length / 2;

        newStart = Offset(iStartX + xDiff, iStartY - yDiff);
        newEnd = Offset(iEndX - xDiff, iEndY + yDiff);
      }

      intersectionPath.start = newStart;
      intersectionPath.end = newEnd;
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
    var iStart = intersectionPath.start;
    var iEnd = intersectionPath.end;

    for (var i = 0; i < polygonOffsets.length - 1; i++) {
      var intersectDetector = IntersectionDetector(
        iStart,
        iEnd,
        polygonOffsets[i],
        polygonOffsets[i + 1],
      );

      if (intersectDetector.isIntersect()) {
        setState(() {
          intersectionPoints.add(
            Container(
              child: CustomPaint(
                painter:
                    CrossPointer(intersectDetector.getIntersectionOffset()),
                child: Container(),
              ),
            ),
          );
        });
      }
    }
  }

  void _handleTap(LatLng latLng) {
    print('tapped');
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

        //add first elements additionally to the end to complete the chain
        polygonPoints.add(polygonPoints.first);
        //polygonOffsets.add(polygonOffsets.first);

        isPolygonCompleted = true;

        intersectionPath = IntersectionPath(context);
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

  EdgePainter(this.offsetStart, this.offsetEnd, {this.color = Colors.red});

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
