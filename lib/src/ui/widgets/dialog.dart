import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MyDialog {
  /// 单选列表，通常用在 onTab 回调内部
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
}
