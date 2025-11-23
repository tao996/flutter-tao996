import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class FormHelper {
  /// 网络布局的 checkbox 按钮组
  /// [crossAxisCount] 列数，会根据列数自动计算自身的尺寸
  /// 跟 FlowChipBar 有点类似，但 FlowChipBar 是单选，并且不是网络布局
  static Widget gridCheckbox({
    required List<String> items,
    required ValueChanged<List<String>> onSelectionChanged,
    List<String>? values,
    int crossAxisCount = 3,
    double horizontal = 18,
  }) {
    return GridCheckbox(
      items: items,
      onSelectionChanged: onSelectionChanged,
      values: values,
      crossAxisCount: crossAxisCount,
      horizontal: horizontal,
    );
  }

  /// 列表布局的 checkbox 复选列表（占据最宽），可用于多项选择
  static Widget listCheckbox<T>({
    required List<KV<T>> items,
    required ValueChanged<List<T>> onSelectionChanged,
    List<T>? values,
    bool dense = false,
  }) {
    return ListCheckbox(
      items: items,
      onSelectionChanged: onSelectionChanged,
      values: values,
      dense: dense,
    );
  }

  /// 水平布局的 按钮组，可用于多单或单选（oneFilterChip），被选中的选项会打上一个勾（改变了尺寸）
  /// 跟 [gridCheckbox] 的区别是会自动换行
  static Widget filterChipCheckbox<T>({
    required List<KV<T>> items,
    required void Function(bool selected, T item) onSelectionChanged,
    List<T>? values,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) {
        final isSelected = values != null && values.contains(item.value);
        return FilterChip(
          // avatar: item.iconData != null ? Icon(item.iconData) : null,
          label: Text(item.label),
          selected: isSelected,
          onSelected: (selected) {
            onSelectionChanged(selected, item.value);
          },
        );
      }).toList(),
    );
  }

  /// 水平布局的 按钮组，可用于单选
  static Widget oneFilterChip<T>({
    required List<KV<T>> items,
    required void Function(T? item) onSelectionChanged,
    T? value,
    String? label,
    InputDecoration? decoration, // 允许传入自定义 decoration
    bool isRequired = false,
  }) {
    final child = filterChipCheckbox<T>(
      items: items,
      onSelectionChanged: (selected, item) {
        if (selected) {
          onSelectionChanged(item);
        } else if (!isRequired) {
          onSelectionChanged(null);
        }
      },
      values: value == null ? null : [value],
    );
    if (label != null && label.isNotEmpty) {
      return inputDecoration(
        label,
        child,
        decoration: decoration,
        isRequired: isRequired,
      );
    }

    return child;
  }

  /// 分段按钮，2-3个选项时可使用，如果选项太多或内容太长则不建议使用，因为文字换行显示很难看
  /// [multiSelectionEnabled] 是否支持多选; [emptySelectionAllowed] 是否允许空选项
  static Widget segmentedButton<T>({
    required List<KV<T>> items,
    required void Function(Set<T> items) onSelectionChanged,
    required List<T> values,
    bool multiSelectionEnabled = false,
    bool emptySelectionAllowed = true,
  }) {
    return SegmentedButton<T>(
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      segments: items.map((kv) {
        return ButtonSegment<T>(
          value: kv.value,
          label: Text(kv.label),
          icon: kv.icon,
        );
      }).toList(),
      selected: values.toSet(),
      onSelectionChanged: onSelectionChanged,
    );
  }

  /// 单选分段按钮
  static Widget oneSegmentedButton<T>({
    required List<KV<T>> items,
    required void Function(T value) onSelectionChanged,
    T? value,
    String? label,
    bool isRequired = false,
  }) {
    final child = segmentedButton<T>(
      items: items,
      onSelectionChanged: (data) {
        onSelectionChanged(data.first);
      },
      values: value == null ? [] : [value],
    );
    if (label != null && label.isNotEmpty) {
      return inputDecoration(label, child, isRequired: isRequired);
    }
    return child;
  }

  /// 水平列表框
  static Widget select<T>({
    required String label,
    required List<KV<T>> items,
    required ValueChanged<T?> onChanged,
    T? value,
    String? hintText,
    String? helperText,
    bool isRequired = false,
  }) {
    if (value != null) {
      final values = items.map((kv) => kv.value).toList();
      if (!values.contains(value)) {
        value = null;
      }
    }

    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        label: MyInputLabel(label: label, isRequired: isRequired),
        helperText: helperText,
        border: OutlineInputBorder(),
      ),
      items: items.map((KV kv) {
        return DropdownMenuItem<T>(value: kv.value, child: Text(kv.label));
      }).toList(),
      onChanged: onChanged,
      hint: hintText != null ? Text(hintText) : null,
    );
  }

  /// 注意 [onChanged] 里不需要再次更新 controller.text，否则会触发 auto Fours
  static Widget input({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? helperText,
    String? defaultValue,
    bool isPassword = false,
    bool isRequired = false,
    num? minNumber, // 最小值限制
    num? maxNumber, // 最大值限制
    bool isInteger = false,
    bool isDouble = false,
    bool isMoney = false,
    int? maxLines,
    int? minLines,
    void Function(String)? onChanged,
  }) {
    return MyInput(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      defaultValue: defaultValue,
      isPassword: isPassword,
      isRequired: isRequired,
      isInteger: isInteger,
      isDouble: isDouble,
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

  static Widget timeInput({
    DateTime? initTime,
    required String labelText,
    required Function(DateTime?) onTimeSelected,
    String? hintText,
  }) {
    return FakeTimeInput(
      initTime: initTime,
      labelText: labelText,
      onTimeSelected: onTimeSelected,
      hintText: hintText,
    );
  }

  static Widget datetimeInput({
    DateTime? initialDatetime,
    required String labelText,
    required Function(DateTime?) onDatetimeSelected,
    String? hintText,
  }) {
    return FakeDatetimeInput(
      labelText: labelText,
      hintText: hintText,
      initialDatetime: initialDatetime,
      onDatetimeSelected: onDatetimeSelected,
    );
  }

  static Widget checkboxListTile({
    required String title,
    required void Function(bool) onChanged,
    String? subtitle,
    bool value = false,
    IconData? iconData,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null && subtitle.isNotEmpty ? Text(subtitle) : null,
      value: value,
      onChanged: (bool? newValue) {
        onChanged(newValue == true);
      },
      secondary: iconData == null ? null : Icon(iconData),
    );
  }

  /// 一个普通的简单复选组件
  static Widget checkbox(
    String label, {
    bool? value,
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
                  value: initValue,
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

  // static Widget radioGroup(){}

  /// 搜索框 [data] 原始数据，在用户输入或提交时会同时将原始数据返回
  static Widget search(
    MySearchInputMethods method, {
    double fontSize = 16,
    String? hintText,
    String? value,
    dynamic data,
  }) {
    return MySearchInput(
      method,
      fontSize: fontSize,
      hintText: hintText,
      data: data,
      defaultValue: value,
    );
  }

  /// 用来模拟一个输入框，如果只是单纯需要显示文字，使用 MyText.label
  static InputDecorator inputDecoration(
    String label,
    Widget child, {
    InputDecoration? decoration,
    bool isRequired = false,
    String? helperText,
  }) {
    final textWidget = MyInputLabel(label: label, isRequired: isRequired);

    final usedDecoration =
        (decoration ??
                InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  helperText: helperText,
                  // 适当调整内容内边距，确保内容不会顶到边框
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                ))
            .copyWith(label: textWidget);

    return InputDecorator(
      decoration: usedDecoration,
      // child 内部的 padding 用于调整芯片内容与装饰器内边距的契合度
      child: child,
    );
  }
}
