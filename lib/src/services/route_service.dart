import 'package:get/get.dart';

abstract class IRouteService {
  // static const String initial = '/';
  String get initRoute => '/';
  List<GetPage> get routes => [];

  Future<dynamic> toName(String routeName, {dynamic arguments}) async {
    return await Get.toNamed(routeName, arguments: arguments);
  }
}
/*
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class RouteHelper implements IRouteService {
  @override
  String initRoute = '/';

  @override
  List<GetPage> routes = [GetPage(name: '/', page: () => HomePage())];
}
 */