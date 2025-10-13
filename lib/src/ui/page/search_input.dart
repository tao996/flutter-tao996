import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

abstract class MySearchInputMethods {
  Future<void> onChanged(String text);

  Future<void> onSubmitted(String text);
}

class MySearchInputController extends GetxController {
  final RxBool showClearIcon = false.obs;
  final int delay;
  final TextEditingController textController = TextEditingController();
  final MySearchInputMethods methods;

  Timer? _debounce;

  MySearchInputController({
    required this.methods,
    this.delay = 2000,
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
      await methods.onChanged(query);
    });
  }

  Future<void> bindSubmitted(String query) async {
    await methods.onSubmitted(query);
  }

  Future<void> bindClearInput() async {
    textController.text = '';
    showClearIcon.value = false;
    await methods.onChanged('');
  }
}

class MySearchInput extends StatelessWidget {
  final String? hintText;
  late final MySearchInputController c;

  MySearchInput(MySearchInputMethods methods, {super.key, this.hintText}) {
    c = Get.put(MySearchInputController(methods: methods));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        controller: c.textController,
        onChanged: c.bindChanged,
        onSubmitted: c.bindSubmitted,
        // style: const TextStyle(fontSize: 16.0),
        textAlignVertical: TextAlignVertical.center,
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
