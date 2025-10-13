import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

typedef NetworkResult = ConnectivityResult;

extension NetworkResultAttr on List<NetworkResult> {
  /// 蓝牙连接
  bool get isBluetooth => contains(NetworkResult.bluetooth);

  /// Wifi 连接
  bool get isWifi => contains(NetworkResult.wifi);

  /// 网卡连接
  bool get isEthernet => contains(NetworkResult.ethernet);

  /// 手机网络
  bool get isMobile => contains(NetworkResult.mobile);

  /// 其它无法识别的网络（在模拟器下可能会出现）
  bool get isOther => contains(NetworkResult.other);

  /// VPN
  bool get isVpn => contains(NetworkResult.vpn);

  /// 无网络
  bool get isNone => contains(NetworkResult.none);

  /// 已连接 wifi 或 移动网络
  bool get isConnected =>
      contains(NetworkResult.wifi) || contains(NetworkResult.mobile);
}

class MyNetworkWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<NetworkResult> state)
  builder;

  const MyNetworkWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<ConnectivityResult>> snapshot,
          ) {
            if (snapshot.hasData) {
              return builder(context, snapshot.data!);
            } else {
              return const CircularProgressIndicator(); // 或其他加载指示器
            }
          },
    );
  }
}

// 在你的 Widget 中使用
/*
class MyMediaDisplay extends StatelessWidget {
  const MyMediaDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return MyNetworkWidget(
      builder: (context, results) {
        if (results.contains(NetworkResult.wifi)) {
          return Image.network('high_quality_image_url');
        } else {
          return const Text('No internet connection');
        }
      },
    );
  }
}
*/
