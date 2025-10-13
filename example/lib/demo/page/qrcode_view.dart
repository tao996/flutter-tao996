import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyDemoQrcodeView extends StatelessWidget {
  final result = ''.obs;

  MyDemoQrcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: false,
      appBar: AppBar(title: Text('扫码')),
      body: Column(
        children: [
          Center(
            child: MyQrcodeIconButton(
              onChange: (text) {
                result.value = text ?? '';
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('扫码结果'),
          Center(child: Obx(() => Text(result.value))),
        ],
      ),
    );
  }
}
