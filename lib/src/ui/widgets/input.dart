import 'package:flutter/material.dart';

/// 带有后缀按钮的输入框
class MyInput extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool isPassword;
  final bool autoDispose;
  final bool isRequired;
  final int? maxLines;
  final void Function(String)? onChanged;

  const MyInput({
    required this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.isPassword = false,
    this.autoDispose = false,
    this.isRequired = false,
    this.maxLines,
    this.onChanged,
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
      onChanged: (value){
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
      ),
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

  // Widget? _helperWidget() {
  //   if (widget.helperText != null && widget.helperText!.isNotEmpty) {
  //     final child = Text(
  //       widget.helperText!,
  //       style: TextStyle(fontSize: 12, color: Colors.grey),
  //     );
  //     if (widget.isRequired) {
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.circle, size: 6, color: Colors.red),
  //           const SizedBox(width: 4),
  //           child,
  //         ],
  //       );
  //     }
  //     return child;
  //   }
  //   return null;
  // }

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
