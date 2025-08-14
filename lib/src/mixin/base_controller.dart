import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

mixin BaseController {
  final IMessageService messageService = getIMessageService();
  final IDebugService debugService = getIDebugService();

  void goBack() {
    Get.back();
  }

  void goBackWithResult(dynamic result) {
    Get.back(result: result);
  }
}
