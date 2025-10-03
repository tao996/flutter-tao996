import 'package:flutter/material.dart';

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
    String title, {
    double horizontal = 18,
    double vertical = 10,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: Text(title),
    );
  }

  static Widget warning(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
  }

  static Widget info(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
    );
  }

  static Widget listTitle(String title, {String? subTitle, bool bold = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: bold
              ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
              : null,
        ),
        if (subTitle != null && subTitle.isNotEmpty)
          Text(
            subTitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }
}
