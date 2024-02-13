import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final Function onPressed;
  final bool isEnabled;
  final String btnText;

  const Button(
      {Key? key,
      required this.onPressed,
      this.isEnabled = false,
      this.btnText = 'TEXT'})
      : super(key: key);

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (widget.isEnabled) {
          widget.onPressed();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          widget.isEnabled
              ? const Color.fromRGBO(28, 176, 121, 1)
              : Colors.grey,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          Colors.white,
        ),
      ),
      child: Text(
        widget.btnText,
        style: const TextStyle(
          fontFamily: 'EF_watermelonSalad',
          fontSize: 20,
        ),
      ),
    );
  }
}
