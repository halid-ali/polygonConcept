import 'dart:io';

import 'package:flutter/material.dart';

class IntersectionDetector {
  final Offset ps;
  final Offset pe;
  final Offset qs;
  final Offset qe;

  IntersectionDetector(this.ps, this.pe, this.qs, this.qe);

  //returns true when clockwise oriented, false when counter-clockwise
  bool orientation(Offset p, Offset q, Offset r) {
    var value = (q.dy - p.dy) * (r.dx - q.dx) - (q.dx - p.dx) * (r.dy - q.dy);
    return value > 0;
  }

  bool isIntersect() {
    var o1 = orientation(ps, pe, qs);
    var o2 = orientation(ps, pe, qe);
    var o3 = orientation(qs, qe, ps);
    var o4 = orientation(qs, qe, pe);

    return o1 != o2 && o3 != o4;
  }

  Offset getIntersectionOffset() {
    var a1 = pe.dy - ps.dy;
    var b1 = ps.dx - pe.dx;
    var c1 = a1 * ps.dx + b1 * ps.dy;

    var a2 = qe.dy - qs.dy;
    var b2 = qs.dx - qe.dx;
    var c2 = a2 * qs.dx + b2 * qs.dy;

    var delta = a1 * b2 - a2 * b1;
    return delta == 0
        ? Offset(150, 30)
        : Offset((b2 * c1 - b1 * c2) / delta, (a1 * c2 - a2 * c1) / delta);
  }
}
