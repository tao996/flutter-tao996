import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

mixin MixinTao996Service {
  final IMessageService messageService = getIMessageService();
  final IDebugService debugService = getIDebugService();
}

void goBackWithResult(dynamic result) {
  Get.back(result: result);
}

void goBack() {
  Get.back();
}
