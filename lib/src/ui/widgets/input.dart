import 'package:flutter/material.dart';

class InputWithClearButton extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool isPassword;
  final bool autoDispose;

  const InputWithClearButton(
    this.label, {
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.autoDispose = false,
    super.key,
  });

  @override
  State<InputWithClearButton> createState() => _InputWithClearButtonState();
}

class _InputWithClearButtonState extends State<InputWithClearButton> {
  @override
  void initState() {
    super.initState();
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
      obscureText: widget.isPassword,
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
        // 动态显示或隐藏删除按钮
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                },
              )
            : null,
      ),
    );
  }
}
