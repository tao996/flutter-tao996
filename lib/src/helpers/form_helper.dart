import 'package:flutter/cupertino.dart';
import 'package:tao996/tao996.dart';

class FormHelper {
  /// 网络布局的 checkbox 按钮组
  static Widget gridCheckbox({
    required List<String> items,
    required ValueChanged<List<String>> onSelectionChanged,
    List<String>? initItems,
    int crossAxisCount = 3,
    double horizontal = 18,
  }) {
    return GridCheckbox(
      items: items,
      onSelectionChanged: onSelectionChanged,
      initItems: initItems,
      crossAxisCount: crossAxisCount,
      horizontal: horizontal,
    );
  }

  /// 列表布局的 checkbox 按钮组
  static Widget listCheckbox({
    required List<String> items,
    required ValueChanged<List<String>> onSelectionChanged,
    List<String>? initItems,
  }) {
    return ListCheckbox(
      items: items,
      onSelectionChanged: onSelectionChanged,
      initItems: initItems,
    );
  }
}
