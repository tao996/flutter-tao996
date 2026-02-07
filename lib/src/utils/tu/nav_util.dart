import 'package:flutter/material.dart';

/// 导航工具类
class NavUtil {
  const NavUtil();

  /// 跳转页面，如无特殊需要，可以使用 Get.to 代替
  Future<T?> push<T extends Object>(
    BuildContext context,
    Widget page, {
    Object? arguments,
  }) async {
    // 关键点 1: 增加 await，确保方法等待页面关闭
    // 关键点 2: 显式传递泛型 T
    return await Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(arguments: arguments), // 简化了判断，null 也可以传
      ),
    );
  }

  /// 获取 settings 中传递的参数
  Object? getArguments(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments;
  }

  /// 返回数据
  void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }

  /// 拦截器
  /// [onPopInvokedWithResult] 示例
  /// ```dart
  /// onPopInvokedWithResult: (bool didPop, dynamic result) async {
  ///   // 2. 如果 didPop 为 true，说明页面已经关闭（例如通过代码手动 pop），直接返回
  ///   if (didPop) return;
  ///
  ///   // 3. 编写你的自定义逻辑（例如弹窗确认）
  ///   final bool shouldPop = await _showExitDialog(context);
  ///
  ///   // 4. 如果用户确认退出，手动关闭页面
  ///   if (shouldPop && context.mounted) {
  ///     Navigator.pop(context);
  ///   }
  /// },
  /// ```
  Widget popScope(
    BuildContext context, {
    void Function(bool didPop, dynamic result)? onPopInvokedWithResult,
    required Widget child,
  }) {
    return PopScope(
      canPop: false, // 1. 先拦截系统自动返回
      onPopInvokedWithResult: onPopInvokedWithResult,
      // onPopInvokedWithResult: (bool didPop, dynamic result) async {
      //   // 2. 如果 didPop 为 true，说明页面已经关闭（例如通过代码手动 pop），直接返回
      //   if (didPop) return;
      //
      //   // 3. 编写你的自定义逻辑（例如弹窗确认）
      //   final bool shouldPop = await _showExitDialog(context);
      //
      //   // 4. 如果用户确认退出，手动关闭页面
      //   if (shouldPop && context.mounted) {
      //     Navigator.pop(context);
      //   }
      // },
      child: child,
    );
  }
}
