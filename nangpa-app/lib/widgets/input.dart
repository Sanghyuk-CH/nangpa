import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final Function(String) onSubmit;
  final Function(String) onChange;
  final Function onClear;
  final String placeholder;

  const Input(
      {super.key,
      required this.onSubmit,
      required this.onChange,
      required this.onClear,
      required this.placeholder});

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isFocused ? const Color(0xFF9CD7C1) : Colors.transparent,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF9CD7C1),
            width: 2,
          ),
        ),
        fillColor: const Color(0xFFF5F5F5),
        filled: true,
        prefixIcon: const Icon(
          Icons.search,
          size: 24,
          color: Color(0xFFBDBDBD),
        ),
        hintText: widget.placeholder,
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder:
              (BuildContext context, TextEditingValue value, Widget? child) {
            return value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      widget.onClear();
                      _controller.clear();
                    },
                    color: const Color(0xFF000000),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
      onSubmitted: (String query) {
        widget.onSubmit(query);
      },
      onChanged: (String query) {
        widget.onChange(query);
      },
    );
  }
}
