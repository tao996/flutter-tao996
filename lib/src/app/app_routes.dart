import 'package:get/get.dart';

/// ```dart
/// // 模块入口
/// AppRoutes.routes.add(GetPage( ... ));
/// // 其它模块使用
/// Get.addPages([])
/// ```
class AppRoutes {
  /// 路由，通常在这里初始化 '/' 入口
  static List<GetPage> routes = [];
}
/// Get.addPages([
//     GetPage(
//     name: _bookEdit,
//     page: () => BookEditPage(),
//     binding: BindingsBuilder(() {
//       tu.get.putController(BookEditController(tu.get.arguments()));
//     }),
//   ),
//  ]);