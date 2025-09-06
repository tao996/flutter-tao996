import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyButtons {
  /// 向左箭头按钮
  static Widget chevronLeftIconButton(
    BuildContext context, {
    required Function() onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.chevron_left_outlined),
    );
  }

  /// 加载中按钮
  static Widget loadingIconButton({
    Function()? onPressed,
    bool isLoading = false,
  }) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: MyAnimatedIcon(isLoading: isLoading),
    );
  }
}
