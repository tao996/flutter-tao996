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
  Future<bool?> deleteConfirm(
    String text,
    void Function() yes, {
    bool textIsContent = false,
  }) async {
    return deleteConfirmResponse;
  }

  // 其他方法可以留空或抛出未实现异常，因为这个测试暂不涉及
  @override
  Future<void> alert(String title, {String? content, dynamic icon}) async {}

  @override
  Future<bool?> confirm({
    String? title,
    String? content,
    String? cancelText,
    String? confirmText,
    Function()? yes,
    Function()? no,
  }) async => true;

  @override
  void notice(String message) {
    dprint('notice: $message');
  }

  @override
  void warning(String message) {
    dprint('warning: $message');
  }
}
