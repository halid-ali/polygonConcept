import 'dart:math';

import 'package:flutter/material.dart';

class IntersectionPath extends CustomPainter {
  Offset start;
  Offset end;
  BuildContext context;
  double rotateValue;

  IntersectionPath.withOffset(this.start, this.end);

  IntersectionPath.empty() {
    start = Offset(0, 0);
    end = Offset(0, 0);
  }

  IntersectionPath(this.context, this.rotateValue) {
    start = Offset(0, 0);
    end = Offset(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );
  }

  Offset get startOffset => start;

  Offset get endOffset => end;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 4;
    canvas.drawLine(start, end, paint);
    canvas.rotate(rotateValue + pi / 180);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
