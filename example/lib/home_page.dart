import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996_example/example.dart';

class HomePage extends StatelessWidget {
  final RouteHelper routeHelper = getRouteHelper();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = routeHelper.items();
    return MyScaffold(
      appBar: AppBar(title: Text('appTitle'.tr)),
      singleChildScrollView: true,
      body: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            onTap: () => routeHelper.gotoName(item.name),
          );
        }),
      ),
    );
  }
}
