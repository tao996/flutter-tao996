import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyListTile {
  static Widget trailing(void Function()? onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Tooltip(message: 'edit'.tr, child: Icon(MyIcon.chevronRight)),
    );
  }
}
