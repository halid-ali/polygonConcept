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
}
