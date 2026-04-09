import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tao996/tao996.dart';

class FontUtil {
  const FontUtil();

  Future<List<String>> loadFonts() async {
    try {
      List<String> fontNameList = [];
      for (final dir in await getFontDirectories()) {
        for (var fontFile in dir.listSync()) {
          final fontName = fontFile.path.toLowerCase();
          if (fontName.endsWith('.ttf') ||
              fontName.endsWith('.otf') ||
              fontName.endsWith('.ttc')) {
            fontNameList.add(tu.path.getBasenameWithoutExtension(fontName));
          }
        }
      }
      return fontNameList;
    } catch (error, stackTrace) {
      getIDebugService().exception(error, stackTrace);
      throw Exception('failedToReadFontFiles'.tr);
    }
  }

  /// 获取字体目录，注意，没有检查目录是否存在
  Future<List<String>> getFontDirPathes() async {
    if (Platform.isWindows) {
      return [
        '${Platform.environment['windir']}/fonts/',
        '${Platform.environment['USERPROFILE']}/AppData/Local/Microsoft/Windows/Fonts/',
      ];
    }
    if (Platform.isMacOS) {
      return [
        '/Library/Fonts/',
        '/System/Library/Fonts/',
        '${Platform.environment['HOME']}/Library/Fonts/',
      ];
    }
    if (Platform.isLinux) {
      return [
        '/usr/share/fonts/',
        '/usr/local/share/fonts/',
        '${Platform.environment['HOME']}/.local/share/fonts/',
      ];
    }
    final Directory appWorkDir = Platform.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();
    final String fontDirPath = '${appWorkDir.path}${separator}fonts';
    return [fontDirPath];
  }

  /// 获取字体存在的目录
  Future<List<Directory>> getFontDirectories() async {
    final List<Directory> dirs = [];
    for (final dirPath in await getFontDirPathes()) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        dirs.add(dir);
      }
    }
    return dirs;
  }

  /// 是否成功加载了文件
  /// [fontFilePath] 字体文件路径, [fontName] 字体名称
  Future<bool> readFont(String fontFilePath, {String? fontName}) async {
    final fontFile = File(fontFilePath);
    if (!fontFile.existsSync()) {
      return false;
    }
    final fontFileBytes = await fontFile.readAsBytes();
    fontName ??= tu.path.getBasenameWithoutExtension(fontFilePath);
    final fontLoad = FontLoader(fontName);
    fontLoad.addFont(Future.value(ByteData.view(fontFileBytes.buffer)));
    await fontLoad.load();
    return true;
  }
}
