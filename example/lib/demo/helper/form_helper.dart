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
            tu.form.input(
              controller: createController(),
              labelText: '普通输入框',
              hintText: '请输入内容',
              helperText: '请输入内容',
            ),
            const SizedBox(height: 16),
            tu.form.input(
              controller: createController(),
              labelText: '密码输入框',
              isPassword: true,
            ),
            const SizedBox(height: 16),
            tu.form.input(
              controller: createController(),
              labelText: '数字输入框',
              isInteger: true,
              helperText: '请输入一个整数',
            ),
            const SizedBox(height: 16),
            tu.form.input(
              controller: createController(),
              labelText: '货币输入框',
              isMoney: true,
              helperText: '请输入金额，最多保留两位小数',
            ),

            const SizedBox(height: 16),
            tu.form.select(
              label: '公司',
              items: ConstHelper.kvTitles,
              onChanged: (value) {
                dprint('select: $value');
              },
              value: 'abc',
              hintText: 'tu.form.select',
            ),

            const SizedBox(height: 16),
            tu.form.dateInput(
              labelText: '日期',
              onDateSelected: (dt) {
                dprint(dt);
              },
            ),
            const SizedBox(height: 16),
            tu.form.datetimeInput(
              labelText: '日期时间',
              onDatetimeSelected: (dt) {
                dprint(dt);
              },
            ),

            const SizedBox(height: 16),
            Obx(
              () => tu.form.checkbox(
                '同意协议',
                value: agree.value,
                onChanged: (value) {
                  agree.value = value!;
                },
              ),
            ),

            const SizedBox(height: 16),
            MyText.h3('gridCheckbox'),
            const SizedBox(height: 16),
            tu.form.gridCheckbox(
              items: ConstHelper.titles,
              onSelectionChanged: (title) {
                dprint('title:$title');
              },
              values: ['Facebook', 'Tencent'],
            ),

            const SizedBox(height: 16),
            MyText.h3('listCheckbox'),
            const SizedBox(height: 16),
            tu.form.listCheckbox(
              items: ConstHelper.kvTitles,
              onSelectionChanged: (values) {
                dprint('values: $values');
              },
            ),

            const SizedBox(height: 16),
            MyText.h3('filterChipCheckbox'),
            const SizedBox(height: 16),
            Obx(
              () => tu.form.filterChipCheckbox<Company>(
                items: ConstHelper.kvTitles,
                values: kvCompanyValues,
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
            MyText.h3('segmentedButton'),
            const SizedBox(height: 16),
            Obx(
              () => tu.form.segmentedButton(
                multiSelectionEnabled: true,
                items: ConstHelper.kvTitles,
                onSelectionChanged: (items) {
                  dprint(items);
                },
                values: kvCompanyValues,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
