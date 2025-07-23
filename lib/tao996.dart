
import 'tao996_platform_interface.dart';

class Tao996 {
  Future<String?> getPlatformVersion() {
    return Tao996Platform.instance.getPlatformVersion();
  }
}
