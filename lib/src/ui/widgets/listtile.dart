import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyListTile {
  static Widget trailing(void Function()? onPressed, {String? tooltip}) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(MyIcon.chevronRight),
    );
  }

  static Widget build({
    required String titleText,
    Widget? leading,
    Widget? subtitle,
    Widget? trailing,
    EdgeInsetsGeometry? contentPadding,
    void Function()? onTitleTap,
    void Function()? onTrailingTap,
  }) {
    return Card(
      margin: MySpace.cardMargin,
      child: ListTile(
        contentPadding: contentPadding ?? MySpace.contentPadding8,
        leading: leading,
        // 点击名称
        title: MyEvents.inkWell(
          child: Text(
            titleText,
            softWrap: true,
            style: TextStyle(
              decoration: onTitleTap == null ? null : TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),

          onTap: onTitleTap,
        ),
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }
}
