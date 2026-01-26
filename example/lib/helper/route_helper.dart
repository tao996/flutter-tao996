import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996_example/demo/page/canvas.dart';
import 'package:tao996_example/demo/page/easy_refresh.dart';
import 'package:tao996_example/demo/page/image.dart';
import 'package:tao996_example/demo/page/network.dart';
import 'package:tao996_example/demo/page/pagination_widget.dart';
import 'package:tao996_example/demo/page/qrcode_view.dart';
import 'package:tao996_example/demo/page/search_input.dart';
import 'package:tao996_example/demo/plugin/pull_to_refresh.dart';
import 'package:tao996_example/demo/helper/form_helper.dart';
import 'package:tao996_example/demo/page/custom_tab_bar.dart';
import 'package:tao996_example/demo/page/smart_refresher_page.dart';

import '../home_page.dart';

class RouteItem {
  final String title;
  final String subtitle;
  final String name;

  RouteItem({required this.title, required this.name, required this.subtitle});
}

class RouteHelper extends IRouteService {
  @override
  String get initRoute => '/';

  @override
  List<GetPage> get routes => [
    GetPage(name: '/', page: () => HomePage()),
    GetPage(name: '/plugin_pull_to_refresh', page: () => PluginPullToRefresh()),
    GetPage(name: '/smartRefresh', page: () => MyDemoSmartRefresherPage()),
    GetPage(name: '/formHelper', page: () => MyDemoFormHelper()),
    GetPage(name: '/customTabBar', page: () => MyDemoCustomTabBar()),
    GetPage(name: '/easyRefresh', page: () => MyDemoEasyRefresh()),
    GetPage(name: '/searchInput', page: () => MyDemoSearchInput()),
    GetPage(name: '/paginationWidget', page: () => MyDemoPagination()),
    GetPage(name: '/image', page: () => MyDemoImage()),
    GetPage(name: '/network', page: () => MyDemoNetwork()),
    GetPage(name: '/qrcode', page: () => MyDemoQrcodeView()),
    GetPage(name: '/canvas', page: () => CanvasTestPage()),
  ];

  Future<dynamic> gotoName(String name) async {
    return Get.toNamed(name);
  }

  List<RouteItem> items() {
    return [
      RouteItem(
        title: '下拉刷新上拉加载',
        name: '/smartRefresh',
        subtitle: 'demo from flutter_pulltorefresh plugin',
      ),
      RouteItem(
        title: 'MySmartRefresher.body',
        name: '/plugin_pull_to_refresh',
        subtitle: '对 flutter_pulltorefresh 进行二次封装',
      ),
      RouteItem(
        title: 'CustomTabBar',
        name: '/customTabBar',
        subtitle: '对 tabBarView 的优化，支持多种显示方式',
      ),
      RouteItem(title: 'MyForm', name: '/formHelper', subtitle: '二次封装的表单组件'),
      RouteItem(
        title: 'EasyRefresh',
        name: '/easyRefresh',
        subtitle: '对 RefreshIndicator 的二次封装; pc 上无效，使用 MySmartRefresher 代替',
      ),
      RouteItem(title: 'SearchInput', name: '/searchInput', subtitle: '搜索框'),
      RouteItem(
        title: 'PaginationWidget',
        name: '/paginationWidget',
        subtitle: 'PC 端分页组件',
      ),
      RouteItem(title: 'Image', name: '/image', subtitle: '图片组件'),
      RouteItem(title: 'Network', name: '/network', subtitle: '网络请求组件'),
      RouteItem(title: 'QrcodeView', name: '/qrcode', subtitle: '二维码组件'),
      RouteItem(title: 'CanvasTestPage', name: '/canvas', subtitle: '绘图测试'),
    ];
  }
}
