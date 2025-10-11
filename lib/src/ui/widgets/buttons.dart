import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

/// 提供静态方法的按钮
class MyButtons {
  /// 向左箭头按钮
  static Widget chevronLeftIconButton(
    BuildContext context, {
    required Function() onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.chevron_left_outlined),
    );
  }

  static Widget chevronRightIconButton(
    BuildContext context, {
    required Function() onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.chevron_right_outlined),
    );
  }

  /// 加载中按钮
  static Widget loadingIconButton({
    Function()? onPressed,
    bool isLoading = false,
  }) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: MyAnimatedIcon(isLoading: isLoading),
    );
  }
}

class MyCancelButton extends StatelessWidget {
  final int? id;
  final MyButtonType? type;

  const MyCancelButton({this.id, super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return MyButton(
      id == null ? '取消' : '返回',
      iconData: id == null ? Icons.cancel_outlined : Icons.navigate_before,
      onPressed: () {
        Get.back();
      },
      status: MyButtonStatus.secondary,
      type: type,
    );
  }
}

/// 保存按钮
class MySaveButton extends StatelessWidget {
  final void Function()? onPressed;
  final RxBool? isLoading;
  final MyButtonType? type;
  final bool showIcon;

  const MySaveButton({
    super.key,
    this.onPressed,
    this.isLoading,
    this.type,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      'save'.tr,
      onPressed: onPressed,
      iconData: showIcon ? Icons.send : null,
      isLoading: isLoading,
      type: type ?? MyButtonType.filled,
    );
  }
}

/// 添加按钮
class MyInsertButton extends StatelessWidget {
  final String? label;
  final void Function()? onPressed;
  final MyButtonType? type;
  final bool showIcon;

  const MyInsertButton({
    super.key,
    this.label,
    this.onPressed,
    this.type,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      label ?? 'insert'.tr,
      onPressed: onPressed,
      icon: showIcon ? const Icon(Icons.add) : null,
      type: type ?? MyButtonType.outlined,
    );
  }
}

class MyEditButton extends StatelessWidget {
  final String? label;
  final void Function()? onPressed;
  final MyButtonType? type;
  final bool showIcon;

  const MyEditButton({
    super.key,
    this.label,
    this.onPressed,
    this.type,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      label ?? 'edit'.tr,
      onPressed: onPressed,
      icon: showIcon ? const Icon(Icons.edit) : null,
      type: type ?? MyButtonType.outlined,
    );
  }
}

/// 删除按钮
class MyDeleteButton extends StatelessWidget {
  final void Function()? onPressed;
  final RxBool? isLoading;
  final MyButtonType? type;
  final bool showIcon;

  const MyDeleteButton({
    super.key,
    this.onPressed,
    this.isLoading,
    this.type,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      '删除',
      onPressed: onPressed,
      icon: showIcon ? const Icon(Icons.delete) : null,
      status: MyButtonStatus.danger,
      type: type ?? MyButtonType.outlined,
    );
  }
}

class MyHelperIconButton extends StatelessWidget {
  final void Function()? onPressed;

  const MyHelperIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '操作指引',
      child: IconButton(onPressed: onPressed, icon: Icon(Icons.help_outline)),
    );
  }
}

/// 编辑图标无文字按钮
class MyEditIconButton extends StatelessWidget {
  final void Function()? onPressed;

  const MyEditIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // return MyButton('编辑',onPressed: onPressed,type: ButtonType.info,);
    return IconButton(
      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
      onPressed: onPressed,
      tooltip: '编辑',
    );
  }
}

class MyDetailIconButton extends StatelessWidget {
  final void Function()? onPressed;

  const MyDetailIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // return MyButton('详情',onPressed: onPressed,type: ButtonType.secondary,);
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: onPressed,
      tooltip: '详情',
    );
  }
}

/// 删除图标无文字按钮
class MyDeleteIconButton extends StatelessWidget {
  final void Function()? onPressed;

  /// 是否需要确认对话框
  final bool confirm;

  /// 提示的信息，默认为 “确定要删除当前记录吗？”
  final String? content;

  /// 提示信息是否需要添加 “此操作无法撤销”
  final bool cancel;

  const MyDeleteIconButton({
    super.key,
    this.onPressed,
    this.confirm = true,
    this.cancel = false,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: confirm
          ? () async {
              final result = await getIMessageService().confirm(
                title: '警告',
                content: (content ?? '确定要删除当前记录吗？') + (cancel ? '' : '此操作无法撤销'),
              );
              if (result == true && onPressed != null) {
                onPressed!();
              }
            }
          : onPressed,
      tooltip: '删除',
    );
  }
}

enum MyButtonStatus { primary, secondary, danger, warning, success, info }

/// [MyButtonType.filled] 填充无阴影； 核心操作，当前流程中必须完成的关键操作，引导用户优先点击，如（保存、提交、确认）
/// [MyButtonType.outlined] 描边无填充； 中等重要操作，需要突出非核心或与核心操作形成“并列选择”（如 编辑、重置、导出）
/// [MyButtonType.text] 纯文字无背景； 次要操作，提供辅助功能（如 “取消”，“查看详情”，“帮助”）
/// [MyButtonType.elevated] 填充带阴影； 高强调核心操作，需要极强的视觉引导的操作（如“下一步”，支持、创建，比较少用，使用 filled 替换）
enum MyButtonType { outlined, text, filled, filledTonal, elevated }

/// 定制的多功能按钮（支持四种样式+六种状态+加载动画）
class MyButton extends StatelessWidget {
  final IconData? iconData;
  final Widget? icon;
  final String label;
  final VoidCallback? onPressed;
  final MyButtonStatus status;
  final RxBool? isLoading; // 加载状态（GetX 响应式）
  final MyButtonType? type;
  final double? radius; // 新增：自定义圆角（默认 8px）
  final EdgeInsetsGeometry? padding; // 新增：自定义内边距

  const MyButton(
    this.label, {
    super.key,
    this.icon,
    this.iconData,
    this.onPressed,
    this.status = MyButtonStatus.primary,
    this.isLoading,
    this.type,
    this.radius = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // 1. 根据 ButtonStatus 计算基础颜色（适配主题色）
    final (baseColor, onBaseColor) = _getButtonColors(colorScheme);
    // 2. 获取当前状态的图标（加载中显示动画，否则显示自定义图标）
    final Widget? currentIcon = _getCurrentIcon();
    // 3. 判断是否禁用（加载中或无点击回调时禁用）
    final bool isDisabled = (isLoading?.value ?? false) || onPressed == null;

    final buttonType = type ?? MyButtonType.text;
    // 4. 根据 ButtonType 生成对应样式的按钮
    final Widget buttonWidget = _buildButton(
      buttonType,
      baseColor,
      onBaseColor,
      currentIcon,
      isDisabled,
    );
    if (isLoading == null) {
      return buttonWidget;
    }

    // 5. 加载状态通过 Obx 响应式更新（仅当 isLoading 不为 null 时）
    return Obx(
      () => isLoading!.value
          ? _buildButton(
              buttonType,
              baseColor,
              onBaseColor,
              const MyAnimatedIcon(isLoading: true),
              true,
            )
          : buttonWidget,
    );
  }

  Widget _buildButton(
    MyButtonType buttonType,
    Color baseColor,
    Color onBaseColor,
    Widget? currentIcon,
    bool isDisabled,
  ) {
    return switch (buttonType) {
      MyButtonType.filled => _buildFilledButton(
        baseColor,
        onBaseColor,
        currentIcon,
        isDisabled,
      ),
      MyButtonType.filledTonal => _buildFilledTonalButton(
        baseColor,
        onBaseColor,
        currentIcon,
        isDisabled,
      ),
      MyButtonType.elevated => _buildElevatedButton(
        baseColor,
        onBaseColor,
        currentIcon,
        isDisabled,
      ),
      MyButtonType.outlined => _buildOutlinedButton(
        baseColor,
        onBaseColor,
        currentIcon,
        isDisabled,
      ),
      MyButtonType.text => _buildTextButton(
        baseColor,
        onBaseColor,
        currentIcon,
        isDisabled,
      ),
    };
  }

  /// 1. 根据 ButtonStatus 计算颜色（适配系统主题色，避免硬编码）
  (Color, Color) _getButtonColors(ColorScheme colorScheme) {
    return switch (status) {
      MyButtonStatus.primary => (colorScheme.primary, colorScheme.onPrimary),
      MyButtonStatus.secondary => (
        colorScheme.secondary,
        colorScheme.onSecondary,
      ),
      MyButtonStatus.danger => (colorScheme.error, colorScheme.onError),
      MyButtonStatus.warning => (Colors.orange, Colors.white),
      MyButtonStatus.success => (Colors.green, Colors.white),
      MyButtonStatus.info => (Colors.blue, Colors.white),
    };
  }

  /// 2. 获取当前状态的图标（加载中显示动画，否则显示自定义图标）
  Widget? _getCurrentIcon() {
    // 非加载：优先使用自定义 icon 组件，其次使用 iconData
    if (icon != null) {
      return icon;
    }
    return iconData != null ? Icon(iconData) : null;
  }

  /// 3. 构建 FilledButton（填充样式）
  Widget _buildFilledButton(
    Color baseColor,
    Color onBaseColor,
    Widget? icon,
    bool isDisabled,
  ) {
    return FilledButton.icon(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isDisabled ? baseColor.withAlpha(125) : baseColor,
        foregroundColor: onBaseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius!),
        ),
        padding: padding,
      ),
      icon: icon,
      label: Text(label),
    );
  }

  Widget _buildFilledTonalButton(
    Color baseColor,
    Color onBaseColor,
    Widget? icon,
    bool isDisabled,
  ) {
    return FilledButton.tonalIcon(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isDisabled ? baseColor.withAlpha(125) : baseColor,
        foregroundColor: onBaseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius!),
        ),
        padding: padding,
      ),
      icon: icon,
      label: Text(label),
    );
  }

  /// 4. 构建 ElevatedButton（带阴影的填充样式）
  Widget _buildElevatedButton(
    Color baseColor,
    Color onBaseColor,
    Widget? icon,
    bool isDisabled,
  ) {
    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? baseColor.withAlpha(125) : baseColor,
        foregroundColor: onBaseColor,
        elevation: isDisabled ? 0 : 4,
        // 禁用时取消阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius!),
        ),
        padding: padding,
      ),
      icon: icon,
      label: Text(label),
    );
  }

  /// 5. 构建 OutlinedButton（描边样式）
  Widget _buildOutlinedButton(
    Color baseColor,
    Color onBaseColor,
    Widget? icon,
    bool isDisabled,
  ) {
    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDisabled ? baseColor.withAlpha(125) : baseColor,
        side: BorderSide(
          color: isDisabled ? baseColor.withAlpha(90) : baseColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius!),
        ),
        padding: padding,
      ),
      icon: icon,
      label: Text(label),
    );
  }

  /// 6. 构建 TextButton（纯文字样式）
  Widget _buildTextButton(
    Color baseColor,
    Color onBaseColor,
    Widget? icon,
    bool isDisabled,
  ) {
    return TextButton.icon(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDisabled ? baseColor.withAlpha(125) : baseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius!),
        ),
        padding: padding,
      ),
      icon: icon,
      label: Text(label),
    );
  }
}
