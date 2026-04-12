import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class NetworkSettingController extends GetxController {
  final _settingHelper = getISettingsService();

  late RxBool useProxy;
  late RxString proxyAddress;
  late RxString proxyPort;

  NetworkSettingController() {
    useProxy = _settingHelper.useProxy.obs;
    proxyAddress = _settingHelper.proxyAddress.obs;
    proxyPort = _settingHelper.proxyPort.obs;
  }

  void changeUseProxy(bool value) {
    if (proxyAddress.value.isEmpty || proxyPort.value.isEmpty) {
      tu.sd.toast('proxySettingFailed'.tr);
      return;
    }
    if (value == useProxy.value) return;
    useProxy.value = value;
    _settingHelper.useProxy = value;
  }

  void changeProxyAddress(String value) {
    if (value == proxyAddress.value || value.isEmpty) return;
    proxyAddress.value = value;
    _settingHelper.proxyAddress = value;
  }

  void changeProxyPort(String value) {
    if (value == proxyPort.value || value.isEmpty) return;
    proxyPort.value = value;
    _settingHelper.proxyPort = value;
  }
}
