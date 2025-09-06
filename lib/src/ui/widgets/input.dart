import 'package:flutter/material.dart';

/// 带有后缀按钮的输入框
class MyInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool isPassword;
  final bool autoDispose;
  final int? maxLines;

  const MyInput(
    this.label, {
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.autoDispose = false,
    this.maxLines,
    super.key,
  });

  @override
  State<MyInput> createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> {
  bool isPassword = false;

  @override
  void initState() {
    super.initState();
    isPassword = widget.isPassword;
    // 添加监听器，每当文本发生变化时都调用 setState；
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.autoDispose) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: isPassword,
      maxLines: widget.maxLines ?? 1,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        suffixIcon: widget.controller.text.isNotEmpty ? _suffix() : null,
      ),
    );
  }

  Widget _suffix() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isPassword)
          IconButton(
            onPressed: () {
              setState(() {
                isPassword = !isPassword;
              });
            },
            icon: isPassword
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
          ),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            widget.controller.clear();
          },
        ),
      ],
    );
  }
}
