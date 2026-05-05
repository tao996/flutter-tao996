import 'package:tao996/tao996.dart';

class MockIMessageService implements IMessageService {
  String? name;
  String? lastSuccessMsg;
  String? lastErrorMsg;
  bool deleteConfirmResponse = true;
  MockIMessageService({this.name});
  @override
  String toString() {
    return 'MockIMessageService:{name: $name,lastSuccessMsg: $lastSuccessMsg, lastErrorMsg: $lastErrorMsg, deleteConfirmResponse: $deleteConfirmResponse}';
  }

  @override
  void success(String message, {bool snackBar = false}) {
    lastSuccessMsg = message;
    dprint('Mock Success: $message');
  }

  @override
  void error(String message, {bool snackBar = false}) {
    lastErrorMsg = message;
    dprint('Mock Error: $message');
  }

  @override
  void notice(String message) {
    dprint('notice: $message');
  }

  @override
  void warning(String message) {
    dprint('warning: $message');
  }
}
