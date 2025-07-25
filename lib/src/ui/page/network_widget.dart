import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class MyNetworkWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<ConnectivityResult> state)
  builder;

  const MyNetworkWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (
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
      builder: (context, connectivityResult) {
        if (connectivityResult.contains(ConnectivityResult.wifi)) {
          return Image.network('high_quality_image_url');
        } else {
          return const Text('No internet connection');
        }
      },
    );
  }
}
*/
