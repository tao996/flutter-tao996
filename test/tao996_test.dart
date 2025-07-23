import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/tao996.dart';
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

  test('getPlatformVersion', () async {
    Tao996 tao996Plugin = Tao996();
    MockTao996Platform fakePlatform = MockTao996Platform();
    Tao996Platform.instance = fakePlatform;

    expect(await tao996Plugin.getPlatformVersion(), '42');
  });
}
