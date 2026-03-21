import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../tao996.dart';

typedef NetworkState = ConnectivityResult;

abstract class INetworkService {
  RxList<NetworkState> state = RxList();

  /// 需要自己手动调用 onInit 和 dispose
  void onInit({Future<void> Function()? callback});

  void dispose();

  /// 监听网络变化
  Stream<List<ConnectivityResult>> get onConnectivityChanged;

  bool get isNoNetwork;

  /// 移动网络
  bool get isMobileNetwork;

  /// 高速网络
  bool get isSpeedNetwork;
}

/// https://pub.dev/packages/connectivity_plus
class NetworkService extends INetworkService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  NetworkService() {
    // 首次初始化时获取当前网络状态，这是一个异步操作
    _connectivity.checkConnectivity().then((result) {
      _updateNetworkState(result);
    });
  }

  @override
  void onInit({Future<void> Function()? callback}) {
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      _updateNetworkState(result);
      if (callback != null) {
        await callback();
      }
    });
  }

  // 辅助方法，更新网络状态
  void _updateNetworkState(List<ConnectivityResult> result) {
    state.value = result;
    getIDebugService().d('网络状态变更:$result');
  }

  @override
  void dispose() {
    _subscription.cancel();
  }

  @override
  bool get isMobileNetwork => state.value.contains(ConnectivityResult.mobile);

  @override
  bool get isNoNetwork => state.value.contains(ConnectivityResult.none);

  @override
  bool get isSpeedNetwork =>
      state.value.contains(ConnectivityResult.wifi) ||
      state.value.contains(ConnectivityResult.ethernet);
}
