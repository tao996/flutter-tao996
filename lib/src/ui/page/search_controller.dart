import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:async';

abstract class MySearchMethods {
  Future<void> onChanged(String text);

  Future<void> onSubmitted(String text);
}

class MySearchController extends GetxController {
  final RxBool showClearIcon = false.obs;
  final int delay;
  final TextEditingController textController = TextEditingController();
  final MySearchMethods methods;

  Timer? _debounce;

  MySearchController({
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
