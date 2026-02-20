// 定义扩展
import 'package:get/get.dart';

extension StringValidatorExt on String {
  // 优化后：'xxx'.mustRequired -> 'mustRequired'.trParams({'title': 'xxx'.tr})
  String get mustRequired => 'mustRequired'.trParams({'title': tr});
  String get mustInteger => 'mustInteger'.trParams({'title': tr});
}
