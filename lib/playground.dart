import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:polygonConcept/common/intersectionPath.dart';

class Playground extends StatefulWidget {
  @override
  _PlaygroundState createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  double angle = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              child: Transform.rotate(
                angle: angle * pi / 180,
                child: CustomPaint(
                  painter: IntersectionPath(context),
                ),
                origin: Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                ),
              ),
            ),
            SlidingUpPanelWidget(
              controlHeight: 100,
              panelController: null,
              child: Container(
                color: Colors.grey[200],
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    height: 50,
                    child: Slider(
                      value: angle,
                      min: 0,
                      max: 360,
                      divisions: 36,
                      activeColor: Colors.red,
                      label: angle.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          angle = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
