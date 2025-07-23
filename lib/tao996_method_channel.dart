import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tao996_platform_interface.dart';

/// An implementation of [Tao996Platform] that uses method channels.
class MethodChannelTao996 extends Tao996Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tao996');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
