import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../tao996.dart';

/// 只用于移动端
class FontService {
  final ISettingsService _settingsService = getISettingsService();
  final IDebugService _debugService = getIDebugService();
  String get separator => tu.path.dirSeparator();

  Future<void> readThemeFont() async {
    try {
      final String themeFontName = _settingsService.themeFont;
      if (themeFontName != 'system') {
        for (final dir in await tu.font.getFontDirectories()) {
          await tu.font.readFont('${dir.path}$separator$themeFontName');
        }
      }
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failedToReadThemeFont'.tr);
    }
  }

  /// 删除字体文件
  Future<void> deleteFont(String fontName) async {
    if (fontName == 'system') {
      return;
    }
    for (final dir in await tu.font.getFontDirectories()) {
      final fontFile = File('${dir.path}$separator$fontName');

      if (fontFile.existsSync()) {
        await fontFile.delete();
      }
    }
  }

  /// 导入本地文件导入
  Future<bool> importFont() async {
    try {
      List<File> fontFileList = await getIFilePickerService().pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf', 'ttc'],
        allowMultiple: true,
      );
      if (fontFileList.isEmpty) {
        return false;
      }

      final fontFileDir = Directory((await tu.font.getFontDirPathes()).first);
      if (!fontFileDir.existsSync()) {
        await fontFileDir.create(recursive: true);
      }

      for (var fontFile in fontFileList) {
        final fontFileName = fontFile.path.split(separator).last;
        final newFontPath = '${fontFileDir.path}$separator$fontFileName';
        await fontFile.copy(newFontPath);
        // await fontFile.delete();
      }
      return true;
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failedToImportFonts'.tr);
    }
  }
}
