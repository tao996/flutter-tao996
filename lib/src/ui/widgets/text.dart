import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyText {
  static Widget h1(String text) {
    return Text(text, style: getTextTheme().displayLarge);
  }

  static Widget h2(String text) {
    return Text(text, style: getTextTheme().headlineMedium);
  }

  static Widget h3(String text) {
    return Text(text, style: getTextTheme().titleLarge);
  }

  static Widget h4(String text) {
    return Text(text, style: getTextTheme().titleMedium);
  }

  static Widget h5(String text) {
    return Text(text, style: getTextTheme().bodyLarge);
  }

  static Widget h6(String text) {
    return Text(text, style: getTextTheme().bodyMedium);
  }

  static Widget groupText(
    String title, {
    double horizontal = 18,
    double vertical = 10,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: Text(title, style: getTextTheme().bodyMedium),
    );
  }

  static Widget warning(String text) {
    return Text(
      text,
      style: TextStyle(
        color: getColorScheme().error,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget info(String text) {
    return Text(
      text,
      style: TextStyle(color: MyColor.info(), fontWeight: FontWeight.bold),
    );
  }

  static Widget listTitle(String title, {String? subTitle, bool bold = true}) {
    final Color primaryTextColor = getColorScheme().onSurface;
    final Color subduedTextColor = MyColor.text(
      0.6,
    ); // 模拟 Colors.grey[600] 的柔和效果

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: (bold ? TextStyle(fontWeight: FontWeight.bold) : null)
              ?.copyWith(
                color: primaryTextColor, // 替换 Colors.black
              ),
        ),
        if (subTitle != null && subTitle.isNotEmpty)
          Text(
            subTitle,
            style: TextStyle(
              fontSize: 12,
              color: subduedTextColor, // 替换 Colors.grey[600]
            ),
          ),
      ],
    );
  }

  static Widget labelText(
    String label,
    String content, {
    String? helperText,
    // bool border = true,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        // enabled: border,
        // border: border ? null : InputBorder.none,
        // enabledBorder: border ? null : InputBorder.none,
        helperText: helperText,
        isDense: true,
      ),
      child: Text(content),
    );
  }

  /// 加粗显示
  static Widget bold(String text) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold));
  }
}
