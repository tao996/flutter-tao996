import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996_example/example.dart';

class MyDemoCustomTabBar extends StatelessWidget {
  final RxInt activeIndex = 0.obs;

  MyDemoCustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final children = ConstHelper.titles.map((title) {
      return Text(title);
    }).toList();
    return MyScaffold(
      singleChildScrollView: false,
      appBar: AppBar(title: Text('Mock TabBarView')),
      body: Column(
        children: [
          MyCustomTabBar(
            activeIndex: activeIndex,
            onChange: (index) {
              dprint(activeIndex.value);
            },
            children: children,
          ),

          Divider(),
          FlowChipBar(
            activeIndex: activeIndex,
            onChange: (index) {
              dprint(activeIndex.value);
            },
            children: children,
          ),
        ],
      ),
    );
  }
}
