import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyText {
  static Widget h1(String text, {BuildContext? context}) {
    return Text(text, style: getTextTheme(context: context).displayLarge);
  }

  static Widget h2(String text, {BuildContext? context}) {
    return Text(text, style: getTextTheme(context: context).headlineMedium);
  }

  static Widget h3(String text, {BuildContext? context}) {
    return Text(text, style: getTextTheme(context: context).titleLarge);
  }

  static Widget h4(String text, {BuildContext? context}) {
    return Text(text, style: getTextTheme(context: context).titleMedium);
  }

  static Widget h5(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    BuildContext? context,
  }) {
    return _text(
      text,
      style: getTextTheme(context: context).bodyLarge,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  static Widget h6(String text, {BuildContext? context}) {
    return Text(text, style: getTextTheme(context: context).bodyMedium);
  }

  static Widget _text(
    String text, {
    TextStyle? style,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    if (style != null) {
      style = style.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      );
    }
    return Text(text, style: style);
  }

  static Widget groupText(
    String title, {
    double horizontal = 18,
    double vertical = 10,
    BuildContext? context,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: Text(title, style: getTextTheme(context: context).titleMedium),
    );
  }

  static Widget warning(String text, {BuildContext? context}) {
    return Text(
      text,
      style: TextStyle(
        color: getColorScheme(context: context).error,
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

  static Widget labelText(
    String label,
    String content, {
    String? helperText,
    // bool border = true,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        fillColor: Colors.grey[100],
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

  /// 分组标题
  static Widget sectionTitle(
    String title, {
    IconData? iconData,
    String? subTitle,
    Widget? trailing,
    BuildContext? context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // 确保垂直居中
      children: <Widget>[
        if (iconData != null) ...[
          Icon(iconData, size: 24),
          const SizedBox(width: 16),
        ], // 间距
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: getTextTheme(context: context).titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getColorScheme(context: context).primary,
                ),
              ),
              if (subTitle != null && subTitle.isNotEmpty)
                Text(
                  subTitle,
                  style: TextStyle(fontSize: 12, color: MyColor.text(0.6)),
                ),
            ],
          ),
        ),

        // Trailing (右侧图标/Widget)
        if (trailing != null) trailing,
      ],
    );
  }
}
