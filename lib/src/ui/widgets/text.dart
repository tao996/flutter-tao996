import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyText {
  static TextTheme getTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.textTheme;
  }

  static Widget h1(BuildContext context, String text) {
    return Text(text, style: getTheme(context).displayLarge);
  }

  static Widget h2(BuildContext context, String text) {
    return Text(text, style: getTheme(context).headlineMedium);
  }

  static Widget h3(BuildContext context, String text) {
    return Text(text, style: getTheme(context).titleLarge);
  }

  static Widget h4(BuildContext context, String text) {
    return Text(text, style: getTheme(context).titleMedium);
  }

  static Widget h5(BuildContext context, String text) {
    return Text(text, style: getTheme(context).bodyLarge);
  }

  static Widget h6(BuildContext context, String text) {
    return Text(text, style: getTheme(context).bodyMedium);
  }

  static Widget groupText(
    BuildContext context,
    String title, {
    double horizontal = 18,
    double vertical = 10,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: Text(title, style: getTheme(context).bodyMedium),
    );
  }

  static Widget warning(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: getColorScheme().error, fontWeight: FontWeight.bold),
    );
  }

  static Widget info(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: MyColor.info(), fontWeight: FontWeight.bold),
    );
  }

  static Widget listTitle(String title, {String? subTitle, bool bold = true}) {
    final Color primaryTextColor = getColorScheme().onSurface;
    final Color subduedTextColor = MyColor.text(0.6); // 模拟 Colors.grey[600] 的柔和效果

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: (bold ? TextStyle(fontWeight: FontWeight.bold) : null)?.copyWith(
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

  static Widget labelText(String label, String content, {String? helperText}) {
    return TextFormField(
      readOnly: true,
      initialValue: content,
      style: TextStyle(color: MyColor.info()),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
