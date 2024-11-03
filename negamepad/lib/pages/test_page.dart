
import 'package:flutter/material.dart';

import '../controlpad/joystick_view.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Set<String> activeDirections = {};

  void _updateDirection(String direction, bool isActive) {
    if (isActive) {
      if (!activeDirections.contains(direction)) {
        activeDirections.add(direction);
        debugPrint("$direction: 1");
      }
    } else {
      if (activeDirections.contains(direction)) {
        activeDirections.remove(direction);
        debugPrint("$direction: 0");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JoystickView(
        onDirectionChanged: (degrees, distance) {
          _updateDirection("UP", (degrees >= 300 || degrees <= 60) && degrees != 0);
          _updateDirection("LEFT", degrees >= 200 && degrees <= 330);
          _updateDirection("RIGHT", degrees >= 30 && degrees <= 150);
          _updateDirection("BACK", degrees >= 120 && degrees <= 240);

          if (degrees == 0) {
            for (var direction in activeDirections.toList()) {
              _updateDirection(direction, false);
            }
          }
        },
      ),
    );
  }
}
