import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996_example/example.dart';

class MyDemoFormHelper extends StatefulWidget {
  const MyDemoFormHelper({super.key});

  @override
  State<MyDemoFormHelper> createState() => _MyDemoFormHelperState();
}

class _MyDemoFormHelperState extends State<MyDemoFormHelper> {
  final List<TextEditingController> controllers = [];
  final RxList<Company> kvCompanyValues = [Company.apple].obs;
  var agree = false.obs;

  TextEditingController createController() {
    final c = TextEditingController();
    controllers.add(c);
    return c;
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: true,
      appBar: AppBar(title: Text('表单')),
      body: MyBodyPadding(
        Column(
          children: [
            const SizedBox(height: 16),
            FormHelper.input(
              controller: createController(),
              labelText: '普通输入框',
              hintText: '请输入内容',
              helperText: '请输入内容',
            ),
            const SizedBox(height: 16),
            FormHelper.input(
              controller: createController(),
              labelText: '密码输入框',
              isPassword: true,
            ),
            const SizedBox(height: 16),
            FormHelper.input(
              controller: createController(),
              labelText: '数字输入框',
              isNumber: true,
              helperText: '请输入一个整数',
            ),
            const SizedBox(height: 16),
            FormHelper.input(
              controller: createController(),
              labelText: '货币输入框',
              isMoney: true,
              helperText: '请输入金额，最多保留两位小数',
            ),

            const SizedBox(height: 16),
            FormHelper.select(
              label: '公司',
              items: ConstHelper.kvTitles,
              onChanged: (value) {
                dprint('select: $value');
              },
              value: 'abc',
              hintText: 'FormHelper.select',
            ),

            const SizedBox(height: 16),
            FormHelper.dateInput(
              labelText: '日期',
              onDateSelected: (dt) {
                dprint(dt);
              },
            ),

            const SizedBox(height: 16),
            Obx(
              () => FormHelper.checkbox(
                '同意协议',
                value: agree.value,
                onChanged: (value) {
                  agree.value = value!;
                },
              ),
            ),

            const SizedBox(height: 16),
            MyText.h3(context, 'gridCheckbox'),
            const SizedBox(height: 16),
            FormHelper.gridCheckbox(
              items: ConstHelper.titles,
              onSelectionChanged: (title) {
                dprint('title:$title');
              },
              initItems: ['Facebook', 'Tencent'],
            ),

            const SizedBox(height: 16),
            MyText.h3(context, 'listCheckbox'),
            const SizedBox(height: 16),
            FormHelper.listCheckbox(
              items: ConstHelper.titles.sublist(0, 5),
              onSelectionChanged: (values) {
                dprint('values: $values');
              },
            ),

            const SizedBox(height: 16),
            MyText.h3(context, 'filterChipCheckbox'),
            const SizedBox(height: 16),
            Obx(
              () => FormHelper.filterChipCheckbox<Company>(
                items: ConstHelper.kvTitles,
                initItems: kvCompanyValues,
                onSelectionChanged: (selected, item) {
                  if (selected) {
                    kvCompanyValues.add(item);
                  } else {
                    kvCompanyValues.remove(item);
                  }
                },
              ),
            ),

            const SizedBox(height: 16),
            MyText.h3(context, 'segmentedButton'),
            const SizedBox(height: 16),
            Obx(
              () => FormHelper.segmentedButton(
                multiSelectionEnabled: true,
                items: ConstHelper.kvTitles,
                onSelectionChanged: (items) {
                  dprint(items);
                },
                initItems: kvCompanyValues,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
