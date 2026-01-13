import 'package:flutter/material.dart';

class ContextUtil {
  const ContextUtil();

  ThemeData theme(BuildContext context) {
    return Theme.of(context);
  }

  ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  TextTheme textTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }
}
