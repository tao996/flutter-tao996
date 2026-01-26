import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tao996/tao996.dart';

class FontUtil {
  const FontUtil();

  Future<List<String>> getSystemFonts() async {
    // 桌面平台字体枚举
    if (Platform.isMacOS) {
      return _getMacOSFonts();
    } else if (Platform.isWindows) {
      return _getWindowsFonts();
    } else if (Platform.isLinux) {
      return _getLinuxFonts();
    }
    return await _getMobileFont();
  }

  Future<List<String>> _getMacOSFonts() async {
    try {
      final result = await Process.run('fc-list', [':family']);
      final fonts =
          result.stdout
              .toString()
              .split('\n')
              .where((line) => line.isNotEmpty)
              .map((line) => line.split(',').first.trim())
              .toSet()
              .toList()
            ..sort();
      return fonts;
    } catch (e) {
      return ['Arial', 'Helvetica', 'Times New Roman', 'Courier New'];
    }
  }

  Future<List<String>> _getWindowsFonts() async {
    try {
      final fontsDir = Directory(r'C:\Windows\Fonts');
      final fonts =
          (await fontsDir
                  .list()
                  .where(
                    (entity) =>
                        entity.path.endsWith('.ttf') ||
                        entity.path.endsWith('.otf'),
                  )
                  .map(
                    (entity) => tu.path.basenameWithoutExtension(entity.path),
                  )
                  .toSet())
              .toList()
            ..sort();
      return fonts;
    } catch (e) {
      return ['Arial', 'Helvetica', 'Times New Roman', 'Courier New'];
    }
  }

  Future<List<String>> _getLinuxFonts() async {
    try {
      final result = await Process.run('fc-list', [':family']);
      final fonts =
          result.stdout
              .toString()
              .split('\n')
              .where((line) => line.isNotEmpty)
              .map((line) => line.split(',').first.trim())
              .toSet()
              .toList()
            ..sort();
      return fonts;
    } catch (e) {
      return ['Arial', 'Helvetica', 'Times New Roman', 'Courier New'];
    }
  }

  Future<List<String>> _getMobileFont() async {
    try {
      List<String> fontNameList = [];
      final fontDir = await getFontDir();
      for (var fontFile in fontDir.listSync()) {
        final fontName = fontFile.path.split(separator).last;
        fontNameList.add(fontName);
      }
      return fontNameList;
    } catch (error, stackTrace) {
      getIDebugService().exception(error, stackTrace);
      throw Exception('failedToReadFontFiles'.tr);
    }
  }

  /// 获取字体目录
  Future<Directory> getFontDir() async {
    if (Platform.isWindows) {
      return Directory(r'C:\Windows\Fonts');
    }
    final Directory appWorkDir = Platform.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();
    final String fontDirPath = '${appWorkDir.path}${separator}fonts';
    final Directory fontDir = Directory(fontDirPath);
    if (!fontDir.existsSync()) {
      await fontDir.create(recursive: true);
    }
    return fontDir;
  }

  Future<void> readFont(String fontFilePath, String fontName) async {
    final fontFile = File(fontFilePath);
    final fontFileBytes = await fontFile.readAsBytes();
    final fontLoad = FontLoader(fontName);
    fontLoad.addFont(Future.value(ByteData.view(fontFileBytes.buffer)));
    await fontLoad.load();
  }
}
