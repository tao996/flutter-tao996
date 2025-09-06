import 'package:flutter/material.dart';
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

  /// 列表布局的 checkbox 按钮组（占据最宽）
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

  /// 水平布局的 按钮组
  static Widget filterChipCheckbox<T>({
    required List<KV<T>> items,
    required void Function(bool selected, T item)? onSelectionChanged,
    List<T>? initItems,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) {
        final isSelected = initItems != null && initItems.contains(item.value);
        return FilterChip(
          label: Text(item.label),
          selected: isSelected,
          onSelected: onSelectionChanged != null
              ? (selected) {
                  onSelectionChanged(selected, item.value);
                }
              : null,
        );
      }).toList(),
    );
  }
  /// 分段按钮，可用于多选或单选
  static Widget segmentedButton<T>({
    required List<KV<T>> items,
    required void Function(Set<T> items) onSelectionChanged,
    required Set<T> initItems,
  }) {
    return SegmentedButton<T>(
      segments: items.map((kv) {
        return ButtonSegment<T>(value: kv.value, label: Text(kv.label));
      }).toList(),
      selected: initItems.toSet(),
      onSelectionChanged: onSelectionChanged,
    );
  }

  /// 水平列表框
  static Widget select<T>({
    required String label,
    required List<KV<T>> items,
    required ValueChanged<T?> onChanged,
    required T value,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items.map((KV kv) {
        return DropdownMenuItem<T>(value: kv.value, child: Text(kv.label));
      }).toList(),
      onChanged: onChanged,
    );
  }

  static Widget input(
    String label, {
    required TextEditingController controller,
    String? hintText,
    bool isPassword = false,
    int? maxLines,
  }) {
    return MyInput(
      label,
      controller: controller,
      hintText: hintText,
      isPassword: isPassword,
      maxLines: maxLines,
    );
  }

  /// 一个普通的简单复选组件
  static Widget checkbox(
    String label, {
    required bool? value,
    required void Function(bool?)? onChanged,
  }) {
    bool initValue = value ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(4.0),
      // 监听点击事件
      onTap: () {
        initValue = !initValue;
        onChanged?.call(initValue);
      },
      child: MyPadding(
        padding: const EdgeInsets.only(right: 10),
        child: Row(
          // 将 Row 的主轴对齐方式设置为 start，以保证内容靠左
          mainAxisAlignment: MainAxisAlignment.start,
          // 将 Row 的交叉轴对齐方式设置为 center，以保证 Checkbox 和文字垂直居中
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: value,
              onChanged: (yes) {
                initValue = yes ?? false;
                onChanged?.call(yes);
              },
            ),
            const SizedBox(width: 4.0), // 添加一些间距
            Text(label),
          ],
        ),
      ),
    );
  }
}
