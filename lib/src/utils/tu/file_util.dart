import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
import 'package:crypto/crypto.dart';

class FileUtil {
  const FileUtil();

  /// 【桌面端专用】通过对话框让用户选择保存路径，并执行文件复制
  Future<bool?> _saveFileToUserSelectedPath(
    String suggestedFileName, {
    File? sourceFile,
    Uint8List? data,
  }) async {
    if (sourceFile == null && data == null) {
      throw 'sourceFile or data is null';
    }
    // 1. 获取用户选择的保存路径
    final FileSaveLocation? result = await getSaveLocation(
      suggestedName: suggestedFileName,
    );
    if (result == null) {
      return null;
    }
    // 2. 将源文件复制到用户指定的路径
    if (sourceFile != null) {
      await sourceFile.copy(result.path);
    } else {
      final file = File(result.path);
      await file.writeAsBytes(data!);
    }
    dprint('文件已成功保存到: ${result.path}');
    return true;
  }

  /// 保存图片到用户相册
  /// 注意：在 iOS 端，需要配置 flutter_image_gallery_saver
  /// [suggestedFileName] 在 [imageBytes] 有值时使用
  Future<void> saveImage({
    File? file,
    Uint8List? imageBytes,
    String? suggestedFileName,
  }) async {
    if (file == null && imageBytes == null) {
      throw 'file or imageBytes is null';
    }
    if (file != null) {
      if (DeviceService.isPc()) {
        // 桌面端：调用通用保存逻辑
        final suggestedName = tu.path.basename(file.path);
        await _saveFileToUserSelectedPath(suggestedName, sourceFile: file);
        return;
      }
      await FlutterImageGallerySaver.saveImage(await file.readAsBytes());
    } else if (imageBytes != null) {
      if (DeviceService.isPc()) {
        await _saveFileToUserSelectedPath(
          suggestedFileName ??
              tu.date.format(
                dateTime: DateTime.now(),
                format: DateTimeFormat.ymdHmFile,
              ),
          data: imageBytes,
        );
        return;
      }
      await FlutterImageGallerySaver.saveImage(imageBytes);
    }
  }

  /// 保存文件
  Future<void> saveFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw 'fileNotExists'.tr;
    }
    if (DeviceService.isPc()) {
      // 提取文件名作为建议名称
      final fileName = tu.path.basename(filePath);
      await _saveFileToUserSelectedPath(fileName, sourceFile: file);
      return;
    }
    await FlutterImageGallerySaver.saveFile(filePath);
  }

  Future<bool> exists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// 异步计算给定文件的 MD5 哈希值
  /// 返回一个 32 字符的十六进制字符串
  Future<String> fileMd5(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }

    try {
      // 1. 打开文件流
      final inputStream = file.openRead();

      // 2. 创建 MD5 哈希器
      final Hash md5Hash = md5;

      // 3. 将文件流通过 md5.bind(inputStream) 注入，计算哈希值
      final digest = await md5Hash.bind(inputStream).first;

      // 4. 将 Digest 对象转换为十六进制字符串
      return digest.toString();
    } catch (e) {
      dprint("Error calculating MD5 for $filePath: $e");
      // 生产环境中，如果计算失败，可以抛出异常或返回一个基于时间的唯一ID
      rethrow;
    }
  }

  Future<String> getContent(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }
}
