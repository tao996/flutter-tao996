import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class DebugSettingController extends GetxController with MixinTao996Service {
  Future<void> clearSetting() async {
    await messageService.confirm(
      title: '警告',
      content: '确定要重置 Preferences 数据吗?',
      yes: () async {
        await prefs.clear();
        messageService.success('重置设置成功');
      },
    );
  }

  Future<void> openLogDir() async {
    final logDir = (await LogService.getLogDir()).path;
    await tu.file.open(logDir);
  }
}
