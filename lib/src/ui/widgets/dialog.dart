import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyDialog {
  /// 可用于关闭对话框
  static Widget title(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: getTextTheme().titleLarge),
        IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.close),
        ),
      ],
    );
  }

  /// 全屏对话框，如果你需要在高度/宽度上尽可能小，则需要将 Column/Row 的 mainAxisSize: MainAxisSize.min
  static Future<dynamic> fullScreenDialog(
    BuildContext context, {
    required Widget child,
    double? horizontalPadding = 20.0,
    double? verticalPadding = 20.0,
  }) async {
    double? width;
    if (horizontalPadding != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      width = screenWidth - horizontalPadding; // 比父窗口宽度小 20
      width = width.toInt().toDouble();
    }
    double? height;
    if (verticalPadding != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      height = screenHeight - verticalPadding; // 比父窗口高度小 20
      height = height.toInt().toDouble();
    }
    // dprint('MyDialog.fullScreenDialog width: $width; height: $height');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: const Color(0xFF1F2937),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: SizedBox(
            // 将计算出的动态尺寸应用于对话框的内容
            width: width,
            // 如果 child 高度超过此 height，
            // 则可以使用 ListView
            // 或使用 SingleChildScrollView(child) 来让子元素支持滚动
            height: height,
            child: child,
          ),
        );
      },
    );
  }

  /// 打开一个普通的对话框
  static Future<dynamic> open(
    BuildContext context, {
    required Widget child,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: const Color(0xFF1F2937),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: child,
        );
      },
    );
  }

  /// 一个适用于表单的通用对话框
  /// [onSubmit] 点击保存按钮，你需要自己手动关闭对话框
  static Future<dynamic> form(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    bool? deleteButton = false,
    required void Function() onSubmit,
  }) async {
    final length = children.length;
    return await MyDialog.fullScreenDialog(
      context,
      verticalPadding: null,
      child: MyBodyPadding(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(length + 1, (index) {
            if (index == length) {
              return MyPadding(
                vertical: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    MyCancelButton(type: MyButtonType.outlined),
                    if (deleteButton == true)
                      MyDeleteButton(
                        onPressed: () {
                          getIMessageService().deleteConfirm(title, () {
                            goBackWithResult('delete');
                          });
                        },
                      ),
                    // 保存按钮
                    MySaveButton(onPressed: onSubmit),
                  ],
                ),
              );
            }
            return children[index];
          }),
        ),
      ),
    );
  }

  /// 单选列表对话框，通常用在 onTab 回调内部
  static void radioList({
    Widget? icon,
    required String title,

    /// 列表项
    required List<String> values,

    /// 值项，必须在列表项中
    required String selectedValue,
    required void Function(String) onSubmit,
  }) {
    Get.dialog(
      AlertDialog(
        icon: icon,
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (String value in values)
                  RadioListTile(
                    value: value,
                    groupValue: selectedValue,
                    title: Text(value.tr),
                    onChanged: (value) {
                      if (value != null && value != selectedValue) {
                        setState(() {
                          selectedValue = value;
                        });
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              onSubmit(selectedValue);
              Get.back();
            },
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  /// 在点击位置旁边弹出窗口，通常是在 PC 上使用
  static void window(
    BuildContext context, {
    required String label,
    double offsetY = 0,
    double offsetX = 0,
    required Widget child,
  }) {
    final RenderBox target = context.findRenderObject() as RenderBox;
    final Offset offset = target.localToGlobal(Offset.zero);
    // final Size size = button.size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      // 点击空白处关闭
      barrierLabel: label,
      barrierColor: Colors.transparent,
      // 背景透明
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder:
          (
            BuildContext buildContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return Stack(
              children: [
                Positioned(
                  top: offset.dy + offsetY,
                  left: offset.dx + offsetX,
                  child: child,
                ),
              ],
            );
          },
    );
  }

  /// 定义一个从顶部滑入的函数
  /// [context] 通常为 navigatorKey.currentContext!, 使用全局 Context
  static Future<T?> showTopSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      // 点击外部区域是否关闭
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      // 背景颜色
      transitionDuration: const Duration(milliseconds: 300),
      // 动画时长

      // --------------------------------------------------
      // 关键步骤 1: 定义内容的位置和动画
      // --------------------------------------------------
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 使用 Tween 定义从顶部上方 (offset.dy = -1.0) 滑入到最终位置 (offset.dy = 0.0)
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);

        // 使用 SlideTransition 应用动画
        return SlideTransition(
          position: animation.drive(tween),
          child: child, // 传入下面的 PageBuilder 构建的 Widget
        );
      },

      // --------------------------------------------------
      // 关键步骤 2: 构建要显示的内容
      // --------------------------------------------------
      pageBuilder: (context, animation, secondaryAnimation) {
        // 使用 Align 将内容固定在顶部
        return Align(
          alignment: Alignment.topCenter,
          // 使用 Material 组件，以便内容具有背景和阴影
          child: Material(
            color: Colors.white, // 内容背景色
            elevation: 10, // 阴影
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width, // * 0.9, // 宽度占屏幕的 90%
              child: builder(context), // 调用用户传入的 builder 函数来构建内容
            ),
          ),
        );
      },
    );
  }
}
