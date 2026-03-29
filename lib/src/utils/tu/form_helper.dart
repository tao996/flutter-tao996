import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class FormHelperUtil {
  const FormHelperUtil();

  /// 生成一个表单 key，使用 if (formKey.currentState!.validate()){ 验证通过 }
  GlobalKey<FormState> formKey() {
    return GlobalKey<FormState>();
  }

  /// 网络布局的 checkbox 按钮组
  /// [crossAxisCount] 列数，会根据列数自动计算自身的尺寸
  /// 跟 FlowChipBar 有点类似，但 FlowChipBar 是单选，并且不是网络布局
  Widget gridCheckbox({
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
  Widget listCheckbox<T>({
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
  /// 跟 [gridCheckbox] 的区别是会自动换行，你可能需要将这个组件包裹在 Expanded 中
  Widget filterChipCheckbox<T>({
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
  /// [isRequired] 是否必填，如果为 false，则必须使用显示声明 `final Rx<Company?> kvCompanyValue = Rx<Company?>(null);`
  Widget oneFilterChip<T>({
    required List<KV<T>> items,
    required void Function(T? item) onSelectionChanged,
    T? value,
    String? label,
    InputDecoration? decoration, // 允许传入自定义 decoration
    bool isRequired = true,
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
  Widget segmentedButton<T>({
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
  Widget oneSegmentedButton<T>({
    required List<KV<T>> items,
    required void Function(T value) onSelectionChanged,
    T? value,
    String? label,
    bool isRequired = false,
  }) {
    final child = segmentedButton<T>(
      items: items,
      onSelectionChanged: (data) {
        if (data.isNotEmpty) {
          onSelectionChanged(data.first);
        }
      },
      values: value == null ? [] : [value],
    );
    if (label != null && label.isNotEmpty) {
      return inputDecoration(label, child, isRequired: isRequired);
    }
    return child;
  }

  Widget radioGroup<T>({
    required List<KV<T>> items,
    T? value,
    required void Function(T value) onSelectionChanged,
    bool horizontal = true,
  }) {
    final children = items.map((kv) {
      return IntrinsicWidth(
        // 让子组件只占用它需要的最小宽度
        child: RadioListTile.adaptive(
          value: kv.value,

          title: Text(kv.label),

          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
        ),
      );
    }).toList();

    return RadioGroup<T>(
      groupValue: value,
      onChanged: (T? newValue) {
        if (newValue != null && newValue != value) {
          onSelectionChanged(newValue);
        }
      },
      child: horizontal
          ? Wrap(spacing: 8.0, children: children)
          : MyLayout.miniColumn(children),
    );
  }

  /// 水平列表框
  Widget select<T>({
    required String label,
    required List<KV<T>> items,
    required ValueChanged<T> onChanged,
    T? value,
    String? hintText,
    String? helperText,
    bool isRequired = false,
    String? Function(T?)? validator,
  }) {
    if (value != null) {
      final values = items.map((kv) => kv.value).toList();
      if (!values.contains(value)) {
        value = null;
      }
    }

    return DropdownButtonFormField<T>(
      isExpanded: true, // 🚀 必须设置为 true
      initialValue: value,
      decoration: InputDecoration(
        label: MyInputLabel(label: label, isRequired: isRequired),
        helperText: helperText,
        border: OutlineInputBorder(),
      ),
      // 下拉菜单列表里显示完整文字，但选中后在输入框里只显示一行缩略文字
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((KV item) {
          return Text(
            item.label,
            overflow: TextOverflow.ellipsis, // 选中后只显示一行+省略号
            maxLines: 1,
          );
        }).toList();
      },
      items: items.map((KV kv) {
        return DropdownMenuItem<T>(
          value: kv.value,
          child: Text(kv.label, softWrap: true),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) {
          onChanged(v);
        }
      },
      hint: hintText != null ? Text(hintText, softWrap: true) : null,
      validator: validator,
    );
  }

  /// 注意 [onChanged] 里不需要再次更新 controller.text，否则会触发 auto Fours
  /// 如果要使用 [validator]，则需要使用 [Form]
  ///
  /// ```
  /// final _formKey = GlobalKey<FormState>();
  /// Form(
  ///    key: _formKey, // 关联 key
  ///    child: Column( children:[ TextFormField() ])
  /// )
  /// 使用 formKey.currentState!.validate() 来检查是否通过验证
  /// ```
  Widget input({
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
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextAlign textAlign = TextAlign.start,
    void Function(String)? onChanged,
    void Function(String)? onSubmit,
    String? Function(String?)? validator,
    bool readonly = false,
  }) {
    if (readonly) {
      return inputDecoration(
        labelText ?? '',
        Text(controller?.text ?? defaultValue ?? ''),
      );
    }
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
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onFieldSubmitted: onSubmit,
      validator: validator,
      textAlign: textAlign,
    );
  }

  Widget dateInput({
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

  Widget timeInput({
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

  Widget datetimeInput({
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

  /// 开关
  Widget switch1(RxBool value) {
    return Obx(
      () => Switch(
        value: value.value,
        onChanged: (bool newValue) {
          value.value = newValue;
        },
      ),
    );
  }

  Widget checkboxListTile(
    String title, {
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
  Widget checkbox(
    String label, {
    bool? value,
    required void Function(bool)? onChanged,
    String? subtitle,
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
                    if (yes != null) {
                      onChanged?.call(yes);
                    }
                  },
                ),
                Text(label),
              ],
            ),
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  /// 搜索框 [data] 原始数据，在用户输入或提交时会同时将原始数据返回
  Widget search(
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

  Widget searchInput(
    void Function(String) onChanged, {
    void Function(String)? onSubmitted,
    double fontSize = 16,
    String? hintText,
    String? value,
  }) {
    final controller = TextEditingController(text: value);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(fontSize: fontSize),
      maxLines: 1,
      // 设置垂直居中
      decoration: InputDecoration(
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        hintText: hintText ?? 'search'.tr,
        hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
        prefixIcon: Icon(Icons.search, size: fontSize),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, size: fontSize),
          onPressed: () {
            controller.text = '';
            onChanged.call('');
          },
        ),
      ),
    );
  }

  /// 用来模拟一个输入框，如果只是单纯需要显示文字，使用 MyText.label
  Widget inputDecoration(
    String label,
    Widget child, {
    InputDecoration? decoration,
    bool isRequired = false,
    String? helperText,
    bool isFocused = false,
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
      isFocused: isFocused,
      decoration: usedDecoration,
      // child 内部的 padding 用于调整芯片内容与装饰器内边距的契合度
      child: child,
    );
  }

  Widget inputReadonly(String label, String text) {
    return InputDecorator(
      // 关键：将 isFocused 设为 false，并根据需要设置其启用状态
      decoration: InputDecoration(
        labelText: label, // 传入标签
        // filled: true,
        // 模拟只读背景：通常比普通输入框更灰一点，或者降低蓝色饱和度
        // fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
        // // 这里的边框需要同时设置 disabledBorder，否则即便设为 readonly 也会有默认边框
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   borderSide: BorderSide.none,
        // ),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   borderSide: BorderSide.none,
        // ),
        // disabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   borderSide: BorderSide.none,
        // ),

        // 内容填充，让只读文本位置与普通输入框对齐
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          // 使用更浅的颜色模拟只读状态
          color: Colors.black54,
        ),
      ),
    );
  }

  static const double myFormLeftWidth = 120;

  /// 左侧控件 + 右侧控件
  Widget leftWidgetRightWidget({
    required Widget right,
    Widget? left,
    double? width,
    EdgeInsetsGeometry? padding,
    bool pZero = false,
  }) {
    return Padding(
      padding: pZero
          ? const EdgeInsets.all(0)
          : (padding ?? const EdgeInsets.symmetric(vertical: 8.0)),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic, // 必须设置 textBaseline
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SizedBox(
              width: width ?? myFormLeftWidth,
              child: left ?? Container(),
            ),
          ),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget leftNullRightWidget(Widget child, {EdgeInsetsGeometry? padding}) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(top: 8, bottom: 8, left: myFormLeftWidth),
      child: child,
    );
  }

  Widget leftStringRightWidget(
    String label, {
    required Widget child,
    bool isRequired = false,
    double? width,
  }) {
    return leftWidgetRightWidget(
      width: width,
      left: Row(
        // crossAxisAlignment: CrossAxisAlignment.start, // 开启后红点上浮
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: isRequired ? 4.0 : 10),
            child: isRequired
                ? const Icon(Icons.circle, size: 8, color: Colors.red)
                : null,
          ),
          MyText.h4(label),
        ],
      ),
      right: child,
    );
  }

  Widget textarea({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? helperText,
    int maxLines = 3,
  }) {
    return MyTextArea(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      maxLines: maxLines,
    );
  }
}
