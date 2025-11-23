import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class MyNetworkController extends GetxController {
  final results = <ConnectivityResult>[].obs;

  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    checkInitialConnectivity();
  }

  Future<void> checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    results.value = result;
  }
}

/*
// 在你的 main.dart 中初始化
void main() {
  Get.put(NetworkController());
  runApp(MyApp());
}

// 在你的 Widget 中使用
class MyMediaDisplay extends StatelessWidget {
  final c = Get.find<MyNetworkController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.results.isWifi) {
        return Image.network('high_quality_image_url');
      } else if (c.results.isConnected) {
        return Image.network('low_quality_image_url');
      } else {
        return const Text('noInternetConnection');
      }
    });
  }
}
*/
