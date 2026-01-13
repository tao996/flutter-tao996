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
  final double? fontSize;
  late final MySearchInputController c;

  MySearchInput(
    MySearchInputMethods methods, {
    super.key,
    this.hintText,
    dynamic data,
    this.defaultValue,
    this.fontSize = 16,
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
        style: TextStyle(fontSize: fontSize),
        // textAlign: TextAlign.center,
        // textAlignVertical: TextAlignVertical.bottom,
        maxLines: 1,
        // 设置垂直居中
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          // isDense: true,
          // 移除内部 padding
          hintText: hintText ?? 'search'.tr,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search),
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

/// 搜索结果为空
class MyEmptySearchResultWidget extends StatelessWidget {
  /// 描述当前页面的内容类型（例如：“活动”、“资源”）。
  final String? title;
  final Widget? child;

  const MyEmptySearchResultWidget({super.key, this.title, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // final double upwardShift = DeviceService.screenHeight / 5;
    final titleText = title ?? 'record'.tr;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 32.0, right: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 确保 Column 占据的空间最小化
          children: <Widget>[
            // 1. 引导图标
            Icon(
              Icons.inbox_outlined, // 使用一个清晰的图标表示“空”
              size: 80.0,
              // 使用辅助色，因为主色通常用于主要操作
              color: colorScheme.secondary.withAlpha(125),
            ),

            const SizedBox(height: 24),

            // 2. 提示文本
            Text(
              'noRecord'.trParams({'title': titleText}),
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withAlpha(200),
              ),
              textAlign: TextAlign.center,
            ),

            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
