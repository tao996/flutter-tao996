import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tao996/src/const/color.dart';
import 'package:tao996/tao996.dart';

// 定义一个枚举，用于区分各种输入限制，使代码更清晰
enum _InputMode {
  none,
  integer, // 纯数字（无小数）
  decimal, // 普通小数（可能用于 isNumber 但无 Money 限制）
  money, // 最多两位小数
}

/// 带有后缀按钮的输入框
class MyInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? defaultValue;
  final bool isPassword;
  final bool isRequired;
  final int? maxLines;
  final int? minLines;

  final int remStep;
  final int addStep;

  /// 是否为整数
  final bool isInteger;

  /// 是否为浮点数
  final bool isDouble;

  // 是否为货币输入（最高优先级），只能精确到分
  final bool isMoney;
  final num? minNumber; // 最小值限制
  final num? maxNumber; // 最大值限制

  final void Function(String)? onChanged;

  /// 确定按钮事件
  final void Function(String)? onFieldSubmitted;

  final String? Function(String?)? validator;

  final Widget? suffix;
  final TextAlign textAlign;

  const MyInput({
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.defaultValue,
    this.isPassword = false,
    this.isRequired = false,
    this.maxLines,
    this.minLines,
    this.isInteger = false,
    this.isDouble = false,
    this.minNumber,
    this.maxNumber,
    this.remStep = -1,
    this.addStep = 1,
    this.isMoney = false,
    this.suffix,
    this.textAlign = TextAlign.start,
    // 回调
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    super.key,
  });

  @override
  State<MyInput> createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> {
  bool isPassword = false;

  // 使用 late var 或 late final，根据是否由外部传入来决定
  late TextEditingController controller;

  // 标志位：判断 controller 是否是内部创建的
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    isPassword = widget.isPassword;

    // 决定是使用外部传入的 controller，还是创建一个内部的 controller
    if (widget.controller != null) {
      controller = widget.controller!;
    } else {
      controller = TextEditingController(text: widget.defaultValue ?? '');
      _isInternalController = true; // 标记为内部创建
    }

    // 为当前使用的 controller 添加监听器
    controller.addListener(_handleControllerChange);
  }

  // Hot Reload/Hot Restart 或父 Widget 配置变化时会被调用
  @override
  void didUpdateWidget(covariant MyInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果外部传入的 controller 发生了变化，需要处理旧 controller 的监听器
    if (widget.controller != oldWidget.controller) {
      // 移除旧 controller 上的监听器
      controller.removeListener(_handleControllerChange);

      // 如果旧 controller 是内部创建的，需要销毁它
      if (_isInternalController) {
        controller.dispose();
      }

      // 切换到新的 controller
      if (widget.controller != null) {
        controller = widget.controller!;
        _isInternalController = false;
      } else {
        controller = TextEditingController(text: widget.defaultValue ?? '');
        _isInternalController = true;
      }

      // 为新 controller 添加监听器
      controller.addListener(_handleControllerChange);
    }

    // 确保其他属性如 isPassword 也能在热更新时更新
    if (widget.isPassword != oldWidget.isPassword) {
      isPassword = widget.isPassword;
    }
  }

  @override
  void dispose() {
    // 1. 移除监听器（必须）
    controller.removeListener(_handleControllerChange);

    // 2. 只有当 controller 是 MyInput 内部创建时，才调用 dispose()
    if (_isInternalController) {
      controller.dispose();
    }

    super.dispose();
  }

  // 添加监听器，每当文本发生变化时都调用 setState；
  void _handleControllerChange() {
    // 仅在需要影响 UI (如 suffixIcon) 时才调用 setState
    setState(() {});
  }

  // --- 验证器逻辑 ---
  String? _validator(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return widget.labelText != null ? '${widget.labelText}不能为空' : '此项不能为空';
    }

    // 只有当有数字限制时，才进行额外的数字校验
    if (widget.isMoney || widget.isInteger || widget.isDouble) {
      if (value != null && value.isNotEmpty) {
        final num? number = widget.isInteger
            ? int.parse(value)
            : num.tryParse(value);
        if (number == null) {
          // 理论上 inputFormatters 会阻止非数字输入，这里作为双重保险
          return '请输入一个有效数字';
        }

        // 检查最小值
        if (widget.minNumber != null && number < widget.minNumber!) {
          return '不能小于 ${widget.minNumber}';
        }

        // 检查最大值
        if (widget.maxNumber != null && number > widget.maxNumber!) {
          return '不能大于 ${widget.maxNumber}';
        }
      }
    }
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    return null;
  }

  // --- 确定输入模式和格式化器 ---
  _InputMode get _currentInputMode {
    if (widget.isPassword) return _InputMode.none;

    // 优先级：isMoney > isNumber
    if (widget.isMoney) {
      return _InputMode.money;
    }
    if (widget.isInteger || widget.isDouble) {
      if (widget.isInteger) {
        return _InputMode.integer;
      }
      return _InputMode.decimal;
    }
    return _InputMode.none;
  }

  TextInputType get _keyboardType {
    if (_currentInputMode == _InputMode.none) {
      return TextInputType.text;
    }
    // 钱/数字都使用数字键盘
    return TextInputType.numberWithOptions(
      signed: true, // 允许负数
      decimal: true,
    );
  }

  List<TextInputFormatter> get _inputFormatters {
    final mode = _currentInputMode;
    if (mode == _InputMode.none) {
      return [];
    }

    // 允许数字和最多一个小数点或负号
    final List<TextInputFormatter> formatters = [
      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*(\.?\d*)')),
    ];

    if (mode == _InputMode.money) {
      // 限制小数点后最多两位
      formatters.add(
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*(\.\d{0,2})?')),
      );
    }

    // 如果是纯整数，则排除小数点
    if (mode == _InputMode.integer) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')));
    }

    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // focusNode: _focusNode,
      obscureText: isPassword,
      maxLines: widget.isPassword ? 1 : widget.maxLines ?? 1,
      minLines: widget.isPassword ? 1 : widget.minLines ?? 1,
      // 新增：限制键盘类型
      keyboardType: _keyboardType,
      // 新增：限制输入格式
      inputFormatters: _inputFormatters,
      // 新增：验证器
      validator: _validator,
      textAlign: widget.textAlign,
      onChanged: (value) {
        // 由于控制器监听器已经处理了 setState，这里只需要调用外部回调;
        // 注意不要在外部再给 controller 赋值，否则会出现错误
        widget.onChanged?.call(value);
      },
      decoration: InputDecoration(
        // labelText: widget.labelText,
        label: _labelWidget(),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: MyColor.text(0.4)),
        // helper: _helperWidget(),
        helperText: widget.helperText,
        border: const OutlineInputBorder(),
        // 只有当文本不为空且输入不是密码时才显示后缀图标（密码图标已包含在 _suffix 中）
        suffixIcon:
            (widget.isPassword ||
                controller.text.isNotEmpty ||
                widget.suffix != null)
            ? _suffix()
            : null,
        isDense: true,
        alignLabelWithHint:
            widget.minLines != null && widget.minLines! > 1, // 标签与输入内容对齐
      ),
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }

  Widget? _labelWidget() {
    if (widget.labelText != null && widget.labelText!.isNotEmpty) {
      return MyInputLabel(
        label: widget.labelText!,
        isRequired: widget.isRequired,
      );
    }
    return null;
  }

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
        if (widget.isInteger || widget.isDouble)
          StepperSuffixIcon(
            controller: controller,
            minValue: widget.minNumber?.toInt(),
            maxValue: widget.maxNumber?.toInt(),
            remStep: widget.remStep,
            addStep: widget.addStep,
          ),
        // 只有当文本不为空时才显示清除按钮
        if (controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              widget.onChanged?.call('');
            },
          ),

        // 追加其它后缀组件
        if (widget.suffix != null) widget.suffix!,
      ],
    );
  }
}

class MyInputLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const MyInputLabel({super.key, required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    if (isRequired) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 6, color: MyColor.error()),
          const SizedBox(width: 4),
          child,
        ],
      );
    }
    return child;
  }
}

class StepperSuffixIcon extends StatelessWidget {
  // 当前 TextField 的控制器
  final TextEditingController controller;

  final int remStep;
  final int addStep;

  // 最小/最大值限制
  final int? minValue;
  final int? maxValue;

  const StepperSuffixIcon({
    super.key,
    required this.controller,
    this.remStep = -1,
    this.addStep = 1,
    this.minValue,
    this.maxValue, // 默认限制最大值
  });

  // ----------------------------------------------------------------------
  // 核心方法：执行步进逻辑
  // ----------------------------------------------------------------------
  void _changeValue(int change) {
    // 1. 获取当前值（如果解析失败，则默认为 minValue）
    int currentValue = int.tryParse(controller.text) ?? 0;

    // 2. 计算新值
    int newValue = currentValue + change;

    // 3. 应用边界限制
    if (minValue != null && newValue < minValue!) {
      newValue = minValue!;
    } else if (maxValue != null && newValue > maxValue!) {
      newValue = maxValue!;
    }

    // 4. 更新 TextField
    controller.text = newValue.toString();

    // 确保光标移动到文本末尾，提供更好的输入体验
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  // ----------------------------------------------------------------------
  // 构建 UI
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // 将两个按钮垂直排列，并限制整体尺寸以适配 suffixIcon
    return SizedBox(
      width: 64, // 确保有足够的宽度容纳图标
      height: 24, // 适应 InputDecoration 的默认高度
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
        children: <Widget>[
          // 减量按钮 (-1)
          _buildButton(
            icon: Icons.remove,
            onPressed: () => _changeValue(remStep),
          ),
          // 增量按钮 (+1)
          _buildButton(icon: Icons.add, onPressed: () => _changeValue(addStep)),
        ],
      ),
    );
  }

  // 辅助方法：构建紧凑的 IconButton
  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 24, // 限制按钮高度为 Column 高度的一半
      width: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        // 移除内边距
        iconSize: 18,
        // 缩小图标尺寸
        icon: Icon(icon, color: Colors.grey.shade600),
        onPressed: onPressed,
        // 可选：减少 Material 触摸反馈的区域
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
