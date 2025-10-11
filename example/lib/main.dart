import 'package:flutter/material.dart';
import 'package:tao996_example/demo/demo_smart_refresher_page.dart';
import 'package:tao996_example/demo/smart_refresh.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: MySmartRefresh(),
      home: DemoSmartRefresherPage(),
    );
  }
}
