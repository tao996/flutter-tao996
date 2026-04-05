import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/tao996_platform_interface.dart';
import 'package:tao996/tao996_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTao996Platform
    with MockPlatformInterfaceMixin
    implements Tao996Platform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Tao996Platform initialPlatform = Tao996Platform.instance;

  test('$MethodChannelTao996 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTao996>());
  });
}
