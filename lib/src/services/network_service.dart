import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../tao996.dart';

enum NetworkState {
  wifi(1),
  cellular(7),
  no(4);

  const NetworkState(this._enumValue);

  /// Convert value to enum type
  ///
  /// When value not found, and [defaultValue] is null will Return first enum value.
  factory NetworkState.toEnum(int x, {dynamic defaultValue}) {
    var filter = values.where((element) => element._enumValue == x);
    return filter.isNotEmpty ? filter.first : defaultValue ?? values.first;
  }

  final int _enumValue;

  /// 是否 Wi-Fi
  bool get isWifi => _enumValue == 1;

  /// 是否蜂窝数据
  bool get isCellular => _enumValue == 7;

  /// 是否无网络
  bool get isNoNetwork => _enumValue == 4;
}

abstract class INetworkService {
  Rx<NetworkState> state = (NetworkState.no).obs;

  /// 需要自己手动调用 onInit 和 dispose
  void onInit({Future<void> Function()? callback});

  void dispose();

  // 新增：同步获取当前网络状态
  NetworkState get currentNetworkState; // 注意这里改为同步方法

  /// 监听网络变化
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// https://pub.dev/packages/connectivity_plus
class NetworkService extends INetworkService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  // 实现 currentNetworkState
  @override
  NetworkState get currentNetworkState => state.value; // 直接返回 Rx 的当前值

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  NetworkService() {
    // 首次初始化时获取当前网络状态，这是一个异步操作
    _connectivity.checkConnectivity().then((result) {
      _updateNetworkState(result);
      if (isDebugMode) {
        getIDebugService().d('初始网络状态:[${state.value.name}]:$result;');
      }
    });
  }

  @override
  void onInit({Future<void> Function()? callback}) {
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      if (isDebugMode) {
        getIDebugService().d('网络状态变化:[${state.value.name}]:$result;');
      }
      _updateNetworkState(result);
      if (callback != null) {
        await callback();
      }
    });
  }

  // 辅助方法，更新网络状态
  void _updateNetworkState(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      state.value = NetworkState.no;
    } else if (result.contains(ConnectivityResult.wifi)) {
      state.value = NetworkState.wifi;
    } else if (result.contains(ConnectivityResult.mobile)) {
      state.value = NetworkState.cellular;
    } else {
      state.value = NetworkState.no;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
  }
}
