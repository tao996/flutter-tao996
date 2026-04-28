import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyListTile {
  static Widget trailing(void Function()? onPressed, {String? tooltip}) {
    return IconButton(
      onPressed: onPressed,
      icon: Tooltip(
        message: tooltip ?? 'edit'.tr,
        child: Icon(MyIcon.chevronRight),
      ),
    );
  }
}
