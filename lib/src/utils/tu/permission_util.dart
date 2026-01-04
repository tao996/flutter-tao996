import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  const PermissionUtil();

  Future<void> mustMicrophone() async {
    // 1. 检查并请求麦克风权限
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
  }
}
