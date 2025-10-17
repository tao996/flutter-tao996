import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/src/utils/fn_util.dart';

class MyDialog {
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
    dprint('width: $width; height: $height');
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
}
