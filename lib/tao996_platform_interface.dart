import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tao996_method_channel.dart';

abstract class Tao996Platform extends PlatformInterface {
  /// Constructs a Tao996Platform.
  Tao996Platform() : super(token: _token);

  static final Object _token = Object();

  static Tao996Platform _instance = MethodChannelTao996();

  /// The default instance of [Tao996Platform] to use.
  ///
  /// Defaults to [MethodChannelTao996].
  static Tao996Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Tao996Platform] when
  /// they register themselves.
  static set instance(Tao996Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
