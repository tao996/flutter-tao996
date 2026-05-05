import 'package:tao996/tao996.dart';

abstract class IMessageService extends IDebugMessageService {
  /// 成功提示，提前调用 Get.back() 后再调用 [success]
  @override
  void success(String message);

  /// 错误提示
  @override
  void error(String message);

  @override
  void notice(String message);

  @override
  void warning(String message);
}

class MessageService implements IMessageService {
  @override
  void success(String message) {
    tu.sd.success(message);
  }

  @override
  void error(String message) {
    tu.sd.error(message);
  }

  @override
  void notice(String message) {
    tu.sd.notice(message);
  }

  @override
  void warning(String message) {
    tu.sd.warning(message);
  }
}
