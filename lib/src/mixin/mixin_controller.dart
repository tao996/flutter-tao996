import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

mixin MixinTao996Controller<T extends IModel> {
  // 是否正在执行
  RxBool isDoing = false.obs;

  /// 是否编辑记录
  RxBool isEdit = false.obs;
}
