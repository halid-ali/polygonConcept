import 'package:flutter/material.dart';

class IntersectionPath extends CustomPainter {
  Offset start;
  Offset end;
  double length;
  BuildContext context;

  IntersectionPath(this.context) {
    start = Offset(MediaQuery.of(context).size.width / 2, 0);
    end = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height,
    );
    length = MediaQuery.of(context).size.height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
