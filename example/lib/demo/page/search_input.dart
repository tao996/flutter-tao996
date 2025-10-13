import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyDemoSearchMethods extends MySearchInputMethods {
  var keyword = 'none'.obs;

  @override
  Future<void> onChanged(String text) async {
    keyword.value = 'onChanged: $text';
  }

  @override
  Future<void> onSubmitted(String text) async {
    keyword.value = 'onSubmitted: $text';
  }
}

class MyDemoSearchInput extends StatelessWidget {
  final MyDemoSearchMethods methods = MyDemoSearchMethods();

  MyDemoSearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: true,
      appBar: AppBar(title: Text('search')),
      body: MyBodyPadding(
        Column(
          children: [
            MySearchInput(methods),
            const SizedBox(height: 20,),
            Center(child: Obx(() => Text(methods.keyword.value))),
          ],
        ),
      ),
    );
  }
}
