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
    String? hintText,
    required List<KV<T>> items,
    required ValueChanged<T?> onChanged,
    required T value,
    T? defaultValue,
  }) {
    List<KV<T>> defaultItems = items;
    if (defaultValue != null) {
      defaultItems.insert(0, KV(label: hintText ?? label, value: defaultValue));
    }

    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: defaultItems.map((KV kv) {
        return DropdownMenuItem<T>(value: kv.value, child: Text(kv.label));
      }).toList(),
      onChanged: onChanged,
      // 移除默认的hint提示（由selectedItemBuilder控制显示）
      hint: const SizedBox.shrink(),
    );
  }

  /// 注意 [onChanged] 里不需要再次更新 controller.text，否则会触发 auto Fours
  static Widget input({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? helperText,
    bool isPassword = false,
    bool isRequired = false,
    bool isNumber = false, // 是否为数字输入（整数或小数，取决于是否有 min/max）
    num? minNumber, // 最小值限制
    num? maxNumber, // 最大值限制
    bool isMoney = false, // 是否为货币输入（最高优先级）
    int? maxLines,
    int? minLines,
    void Function(String)? onChanged,
  }) {
    return MyInput(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      isPassword: isPassword,
      isRequired: isRequired,
      isNumber: isNumber,
      minNumber: minNumber,
      maxNumber: maxNumber,
      isMoney: isMoney,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
    );
  }

  static Widget dateInput({
    DateTime? initDate,
    required String labelText,
    required Function(DateTime?) onDateSelected,
    String? hintText,
  }) {
    return FakeDateInput(
      labelText: labelText,
      hintText: hintText,
      initialDate: initDate,
      onDateSelected: onDateSelected,
    );
  }

  /// 一个普通的简单复选组件
  static Widget checkbox(
    String label, {
    required bool? value,
    required void Function(bool?)? onChanged,
    String? helperText,
    bool helperTextBottom = true,
  }) {
    bool initValue = value ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
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
                Text(label),
                if (helperText != null &&
                    helperText.isNotEmpty &&
                    !helperTextBottom)
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      helperText,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (helperText != null && helperText.isNotEmpty && helperTextBottom)
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: Text(
              helperText,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
