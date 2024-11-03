import 'package:flutter/material.dart';

import '../models/button_model.dart';

class GameButton extends StatefulWidget {
  final ButtonMode buttonMode;
  final Function(String? key)? onDown;
  final Function(String? key)? onUp;
  const GameButton({super.key,required this.buttonMode,this.onDown,this.onUp});

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.buttonMode.color,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.buttonMode.borderRadius??0)),
      child: InkWell(
          borderRadius: BorderRadius.circular(widget.buttonMode.borderRadius??0),
          onTapCancel: () {
            widget.onUp?.call(widget.buttonMode.key);
          },
          onTapDown: (details) {

            widget.onDown?.call(widget.buttonMode.key);
          },
          onTapUp: (details) {
            widget.onUp?.call(widget.buttonMode.key);
          },
          child: SizedBox(
            height: widget.buttonMode.height,
            width: widget.buttonMode.width,
            child: widget.buttonMode.widget??const Icon(Icons.circle, size: 40, color: Colors.white),
          )),
    );
  }
}
