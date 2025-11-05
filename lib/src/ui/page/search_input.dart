import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

abstract class MySearchInputMethods {
  Future<void> onChanged(String text, {dynamic data});

  Future<void> onSubmitted(String text, {dynamic data});
}

class MySearchInputController extends GetxController {
  final RxBool showClearIcon = false.obs;
  final int delay;
  final TextEditingController textController = TextEditingController();
  final MySearchInputMethods methods;
  final dynamic data;

  Timer? _debounce;

  MySearchInputController({
    required this.methods,
    this.delay = 2000,
    this.data,
    String? defaultValue,
  }) : super() {
    if (defaultValue != null) {
      textController.text = defaultValue;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> bindChanged(String query) async {
    showClearIcon.value = query.isNotEmpty;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: delay), () async {
      await methods.onChanged(query, data: data);
    });
  }

  Future<void> bindSubmitted(String query) async {
    await methods.onSubmitted(query, data: data);
  }

  Future<void> bindClearInput() async {
    textController.text = '';
    showClearIcon.value = false;
    await methods.onChanged('', data: data);
  }
}

class MySearchInput extends StatelessWidget {
  final String? hintText;
  final String? defaultValue;
  late final MySearchInputController c;

  MySearchInput(
    MySearchInputMethods methods, {
    super.key,
    this.hintText,
    dynamic data,
    this.defaultValue,
  }) {
    c = Get.put(MySearchInputController(methods: methods, data: data));
  }

  @override
  Widget build(BuildContext context) {
    if (defaultValue != null &&
        defaultValue!.isNotEmpty &&
        c.textController.text.isEmpty) {
      c.textController.text = defaultValue!;
    }
    return Obx(
      () => TextField(
        controller: c.textController,
        onChanged: c.bindChanged,
        onSubmitted: c.bindSubmitted,
        // style: const TextStyle(fontSize: 16.0),
        textAlignVertical: TextAlignVertical.center,
        maxLines: 1,
        // 设置垂直居中
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
          // 移除内部 padding
          hintText: hintText ?? 'Search'.tr,
          suffixIcon: c.showClearIcon.value
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: c.bindClearInput,
                )
              : null,
        ),
      ),
    );
  }
}
