import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class MyFileService {
  // 【桌面端专用】通过对话框让用户选择保存路径，并执行文件复制
  static Future<bool?> _saveFileToUserSelectedPath(
    File sourceFile,
    String dialogTitle,
    String suggestedFileName,
  ) async {
    // 1. 获取用户选择的保存路径
    final FileSaveLocation? result = await getSaveLocation(
      suggestedName: suggestedFileName,
    );
    if (result == null) {
      // Operation was canceled by the user.
      return null;
    }
    // 2. 将源文件复制到用户指定的路径
    await sourceFile.copy(result.path);

    // 可以在这里添加一个 Get.snackbar 或其他 UI 提示：文件已保存到 $savePath
    dprint('文件已成功保存到: ${result.path}');
    return true;
  }

  /// 保存图片
  static Future<void> saveImage(File file) async {
    if (DeviceService.isPc()) {
      // 桌面端：调用通用保存逻辑
      final suggestedName = FilepathUtil.basename(file.path);
      await _saveFileToUserSelectedPath(file, 'image save'.tr, suggestedName);
      return;
    }
    await FlutterImageGallerySaver.saveImage(await file.readAsBytes());
  }

  /// 保存图片
  static Future<void> saveFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw 'file not exists'.tr;
    }
    if (DeviceService.isPc()) {
      // 提取文件名作为建议名称
      final fileName = FilepathUtil.basename(filePath);
      await _saveFileToUserSelectedPath(file, 'file save'.tr, fileName);
      return;
    }
    await FlutterImageGallerySaver.saveFile(filePath);
  }
}
