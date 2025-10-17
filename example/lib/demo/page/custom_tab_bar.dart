import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996_example/example.dart';

class MyDemoCustomTabBar extends StatelessWidget {
  final RxInt activeIndex = 0.obs;
  final RxList<MyCustomTabBarItem> children = <MyCustomTabBarItem>[].obs;

  MyDemoCustomTabBar({super.key}) {
    children.addAll(
      ConstHelper.titles.map((title) {
        return MyCustomTabBarItem(key: title, title: title);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final children = ConstHelper.titles.map((title) {
    //   return Text(title);
    // }).toList();
    return MyScaffold(
      singleChildScrollView: true,
      appBar: AppBar(title: Text('Mock TabBarView')),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              final length = children.length;
              children.add(
                MyCustomTabBarItem(key: 'key:$length', title: 'item $length'),
              );
            },
            child: Text('追加一个 item'),
          ),
          MyText.h3(context, 'MyCustomTabBar.horizontal'),
          const SizedBox(height: 16),
          Obx(
            () => MyCustomTabBar(
              activeIndex: activeIndex,
              onChange: (index) {
                dprint(activeIndex.value);
              },
              children: children.value,
            ),
          ),
          const SizedBox(height: 16),
          MyText.h3(context, 'MyCustomTabBar.bookMark'),
          const SizedBox(height: 16),
          Obx(
            () => MyCustomTabBar(
              activeIndex: activeIndex,
              tabStyle: MyCustomTabBarStyle.bookMark,
              onChange: (index) {
                dprint(activeIndex.value);
              },
              children: children.value,
            ),
          ),
          const SizedBox(height: 16),
          MyText.h3(context, 'MyCustomTabBar.flow'),
          const SizedBox(height: 16),
          Obx(
            () => MyCustomTabBar(
              activeIndex: activeIndex,
              tabStyle: MyCustomTabBarStyle.flow,
              onChange: (index) {
                dprint(activeIndex.value);
              },
              children: children.value,
            ),
          ),
          const SizedBox(height: 16),
          MyText.h3(context, 'MyCustomTabBar.flowChip'),
          const SizedBox(height: 16),
          Obx(
            () => MyCustomTabBar(
              activeIndex: activeIndex,
              tabStyle: MyCustomTabBarStyle.flowChip,
              onChange: (index) {
                dprint(activeIndex.value);
              },
              children: children.value,
            ),
          ),
        ],
      ),
    );
  }
}
