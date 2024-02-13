import 'package:flutter/material.dart';

class PillButton extends StatefulWidget {
  final String label;
  final Function onPressed;
  final bool isActive;

  const PillButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  State<PillButton> createState() => _PillButton();
}

class _PillButton extends State<PillButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
        decoration: widget.isActive
            ? BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(28, 176, 121, 1),
                  width: 1.0,
                ),
                color: const Color.fromRGBO(28, 176, 121, 1),
                borderRadius: BorderRadius.circular(20.0),
              )
            : BoxDecoration(
                border: Border.all(
                  color: const Color.fromRGBO(230, 230, 230, 1),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.isActive
                    ? Colors.white
                    : const Color.fromRGBO(194, 194, 194, 1),
                fontSize: 18.0,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
