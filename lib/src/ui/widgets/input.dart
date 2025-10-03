import 'package:flutter/material.dart';

/// 带有后缀按钮的输入框
class MyInput extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool isPassword;
  final bool isRequired;
  final int? maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  const MyInput({
    required this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.isPassword = false,
    this.isRequired = false,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.onFieldSubmitted,
    super.key,
  });

  @override
  State<MyInput> createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> {
  bool isPassword = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: isPassword,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: (value) {
        widget.onChanged?.call(value);
      },
      decoration: InputDecoration(
        // labelText: widget.labelText,
        label: _labelWidget(),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        // helper: _helperWidget(),
        helperText: widget.helperText,
        border: const OutlineInputBorder(),
        suffixIcon: widget.controller.text.isNotEmpty ? _suffix() : null,
        isDense: true,
        alignLabelWithHint: widget.minLines != null && widget.minLines! > 1, // 标签与输入内容对齐
      ),
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }

  Widget? _labelWidget() {
    if (widget.labelText != null && widget.labelText!.isNotEmpty) {
      final child = Text(
        widget.labelText!,
        // style: TextStyle(fontSize: 12, color: Colors.grey),
      );
      if (widget.isRequired) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.circle, size: 6, color: Colors.red),
            const SizedBox(width: 4),
            child,
          ],
        );
      }
      return child;
    }
    return null;
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
            widget.onChanged?.call('');
          },
        ),
      ],
    );
  }
}
