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
  final double? size;
  final Function()? onPressed;

  const MyCancelButton({
    this.id,
    super.key,
    this.type,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      id == null ? 'cancel'.tr : 'back'.tr,
      iconData: id == null ? Icons.cancel_outlined : Icons.navigate_before,
      onPressed:
          onPressed ??
          () {
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
  final String? label;

  const MySaveButton({
    super.key,
    this.onPressed,
    this.isLoading,
    this.type,
    this.showIcon = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      label ?? 'save'.tr,
      onPressed: onPressed,
      iconData: showIcon ? Icons.save_outlined : null,
      isLoading: isLoading,
      type: type,
    );
  }
}

/// 保存图标无文字按钮
class MySaveIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final RxBool? isLoading;
  final double? size;

  const MySaveIconButton({
    super.key,
    this.onPressed,
    this.size,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading == null) {
      return IconButton(
        icon: Icon(
          Icons.save_outlined,
          size: size,
          // color: tu.colorScheme.primary,
        ),
        onPressed: onPressed,
        tooltip: 'save'.tr,
      );
    } else {
      return Obx(() {
        return IconButton(
          icon: Icon(
            Icons.save_outlined,
            size: size,
            // color: tu.colorScheme.primary,
          ),
          onPressed: isLoading!.value ? onPressed : null,
          tooltip: 'save'.tr,
        );
      });
    }
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
      label ?? 'add'.tr,
      onPressed: onPressed,
      icon: showIcon ? const Icon(Icons.add) : null,
      type: type,
    );
  }
}

class MyInsertIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final double? size;

  const MyInsertIconButton({super.key, this.onPressed, this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add, size: size),
      onPressed: onPressed,
      tooltip: 'add'.tr,
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
      type: type,
    );
  }
}

/// 编辑图标无文字按钮
class MyEditIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final double? size;

  const MyEditIconButton({super.key, this.onPressed, this.size});

  @override
  Widget build(BuildContext context) {
    // return MyButton('编辑',onPressed: onPressed,type: ButtonType.info,);
    return IconButton(
      icon: Icon(Icons.edit_outlined, color: MyColor.info(), size: size),
      onPressed: onPressed,
      tooltip: 'edit'.tr,
    );
  }
}

/// 删除按钮
class MyDeleteButton extends StatelessWidget {
  final void Function()? onPressed;

  final MyButtonType? type;
  final bool showIcon;

  /// 是否需要确认对话框
  final bool confirm;

  /// 提示的信息，默认为 “确定要删除当前记录吗？”
  final String? content;

  /// 提示信息是否需要添加 “此操作无法撤销”
  final bool cancel;

  const MyDeleteButton({
    super.key,
    this.onPressed,
    this.confirm = true,
    this.cancel = false,
    this.content,
    this.type,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      'delete'.tr,
      onPressed: confirm
          ? () async {
              final text =
                  (content ??
                      'deleteConfirmContent'.trParams({'title': 'record'.tr})) +
                  (cancel ? '' : 'youCannotUndoThis'.tr);
              await getIMessageService().deleteConfirm(text, () {
                onPressed!();
              }, textIsContent: true);
            }
          : onPressed,
      icon: showIcon ? const Icon(Icons.delete) : null,
      status: MyButtonStatus.danger,
      type: type,
    );
  }
}

/// 删除图标无文字按钮
class MyDeleteIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final double? size;

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
    this.size,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete_outline, color: MyColor.error(), size: size),
      onPressed: confirm
          ? () async {
              final text =
                  (content ??
                      'deleteConfirmContent'.trParams({'title': 'record'.tr})) +
                  (cancel ? '' : 'youCannotUndoThis'.tr);
              await getIMessageService().deleteConfirm(text, () {
                onPressed!();
              }, textIsContent: true);
            }
          : onPressed,
      tooltip: 'delete'.tr,
    );
  }
}

class MyHelperIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final double? size;

  const MyHelperIconButton({super.key, this.onPressed, this.size});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'userGuide'.tr,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.help_outline, size: size),
      ),
    );
  }
}

class MyDetailIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final double? size;

  const MyDetailIconButton({super.key, this.onPressed, this.size});

  @override
  Widget build(BuildContext context) {
    // return MyButton('详情',onPressed: onPressed,type: ButtonType.secondary,);
    return IconButton(
      icon: Icon(Icons.info_outline, size: size),
      onPressed: onPressed,
      tooltip: 'detail'.tr,
    );
  }
}

class MyQrcodeIconButton extends StatelessWidget {
  final void Function(String?) onChange;

  const MyQrcodeIconButton({super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: () {
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => const QRCodeView()))
        //     .then((result) {
        //       dprint('~~~~~~~~~~~~ $result');
        //       onChange(result);
        //     });
        Get.to(() => const QRCodeView())?.then((result) {
          dprint('~~~~~~~~~~~~ $result');
          onChange(result);
        });
      },
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
  static MyButtonType defaultType = MyButtonType.text;
  final IconData? iconData;
  final Widget? icon;
  final String label;
  final VoidCallback? onPressed;
  final MyButtonStatus status;
  final RxBool? isLoading; // 加载状态（GetX 响应式）
  final MyButtonType? type;
  final double? radius; // 新增：自定义圆角（默认 8px）
  final EdgeInsetsGeometry? padding; // 新增：自定义内边距
  final double? size;
  final String? tooltip;

  /// [isLoading] 是否显示加载动画；注意外部组件不需要使用 Obx 包裹，MyButton 内部已经自动处理 isLoading
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
    this.size,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.tooltip,
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

    final buttonType = type ?? MyButton.defaultType;

    // 定义一个统一的渲染函数，避免逻辑散落在 if/else 中
    Widget buildFinalButton(bool loading) {
      final bool disabled = isDisabled || loading;

      Widget btn = _buildButton(
        buttonType,
        baseColor,
        onBaseColor,
        loading ? const MyAnimatedIcon(isLoading: true) : currentIcon,
        disabled,
      );

      if (tooltip != null && !loading) {
        btn = Tooltip(message: tooltip, child: btn);
      }
      return btn;
    }

    // 如果没有加载状态，直接返回普通按钮
    if (isLoading == null) {
      return buildFinalButton(false);
    }

    // 响应式更新
    return Obx(() => buildFinalButton(isLoading!.value));
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
    return iconData != null ? Icon(iconData, size: size) : null;
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

class MyMenuButtonItem {
  final String text;
  final IconData? iconData;
  final Color? color;
  final bool bold;
  final void Function() onPressed;

  const MyMenuButtonItem({
    required this.text,
    required this.onPressed,
    this.iconData,
    this.color,
    this.bold = false,
  });
}

class MyMenuButtons extends StatelessWidget {
  final List<List<MyMenuButtonItem>> items;

  const MyMenuButtons({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final List<PopupMenuEntry<String>> children = [];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(const PopupMenuDivider(height: 1));
      }
      children.addAll(
        items[i].map((item) {
          final textChild = Text(
            item.text,
            style: TextStyle(
              color: item.color,
              fontWeight: item.bold ? FontWeight.bold : null,
            ),
          );
          return PopupMenuItem(
            value: item.text,
            child: item.iconData == null
                ? textChild
                : Row(
                    children: [
                      Icon(item.iconData!, size: 20, color: item.color),
                      const SizedBox(width: 8),
                      textChild,
                    ],
                  ),
          );
        }),
      );
    }
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        final callback = items
            .firstWhere((element) => element.first.text == value)
            .first
            .onPressed;
        callback();
      },
      itemBuilder: (context) => children,
    );
  }
}
