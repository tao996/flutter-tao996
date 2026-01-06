import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:tao996/testing.dart';

import '../mock.dart';

void main() {
  setUp(() {
    mockStart();
  });

  group('MyModelDelegate 逻辑测试', () {
    late RxList<User> testItems;

    setUp(() {
      testItems = <User>[
        User(id: 1, name: 'Item 1'),
        User(id: 2, name: 'Item 2'),
      ].obs;
    });

    test('测试 removeWithId：无需 Service 时应同步更新列表并显示消息', () async {
      final mockMsg = MockIMessageService();
      // 1. 创建无 Service 的 delegate
      final delegate = MyModelDelegate<User>(rxItems: testItems,messageService: mockMsg);

      // 2. 执行删除
      await delegate.removeWithId(id: 1, deleteConfirm: false, navBack: false);

      // 3. 断言
      expect(testItems.length, 1);
      expect(testItems.first.id, 2);
      expect(mockMsg.lastSuccessMsg, contains('delete'.tr));
    });

    test('测试 Delegate 链寻根：子 Delegate 应该操作父 Delegate 的数据', () async {
      final mockMsg = MockIMessageService(name: 'test1');
      // 1. 父级（列表页）
      final parent = MyModelDelegate<User>(rxItems: testItems,messageService: mockMsg);

      // 2. 子级（编辑页），注入 mockMsg 处理 UI
      final child = MyModelDelegate<User>(delegate: parent);

      // 3. 子级执行新增
      final newUser = User(id: 3, name: 'New Item');
      // 模拟没有 service 的纯同步
      await child.save(entity: newUser, index: -1, navBack: false);

      // 4. 断言：父级的数据源应该被改变了
      expect(testItems.length, 3);
      expect(testItems.first.name, 'New Item');
      expect(mockMsg.lastSuccessMsg, isNotNull);
    });
  });
}
