import 'package:get/get_navigation/src/routes/get_route.dart';

abstract class IRouteService {
  String initRoute = '/';
  List<GetPage> routes = [];
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