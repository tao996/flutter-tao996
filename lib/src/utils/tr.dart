// 定义扩展
import 'package:get/get.dart';

extension StringTrExt on String {
  // 优化后：'xxx'.mustRequired -> 'mustRequired'.trParams({'title': 'xxx'.tr})

  // 校验类：结构化处理
  String get mustRequired => 'mustRequired'.trParams({'title': tr});
  String get mustInteger => 'mustInteger'.trParams({'title': tr});
  String get isRepeat => 'isRepeat'.trParams({'title': tr});
  String get noRecordFound =>
      'noRecordFound'.trParams({'title': tr}); // 没有找到符合条件的记录
  String get noRecord => 'noRecord'.trParams({'title': tr}); // 暂无记录
  String get mustSelected => 'mustSelected'.trParams({'title': tr}); // 没有记录被选中

  // 操作类：通过占位符解决词序问题
  String get toAdd => 'toAdd'.trParams({'title': tr});
  String get toEdit => 'toEdit'.trParams({'title': tr});
  String get toDelete => 'toDelete'.trParams({'title': tr});
  String get toSuccess => 'toSuccess'.trParams({'title': tr});
  String get toFailed => 'toFailed'.trParams({'title': tr});

  // 结果类：
  String get addSuccess => 'addSuccess'.trParams({'title': tr});
  String get addFailed => 'addFailed'.trParams({'title': tr});
  String get saveSuccess => 'saveSuccess'.trParams({'title': tr});
  String get saveFailed => 'saveSuccess'.trParams({'title': tr});
  String get editSuccess => 'editSuccess'.trParams({'title': tr});
  String get editFailed => 'editFailed'.trParams({'title': tr});
  String get updateSuccess => 'updateSuccess'.trParams({'title': tr});
  String get updateFailed => 'updateFailed'.trParams({'title': tr});
  String get deleteSuccess => 'deleteSuccess'.trParams({'title': tr});
  String get deleteFailed => 'deleteFailed'.trParams({'title': tr});
}
