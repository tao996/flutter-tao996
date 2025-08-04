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
}
