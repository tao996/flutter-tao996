import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../tao996.dart';

class FontService {
  final ISettingsService _settingsService = getISettingsService();
  final IDebugService _debugService = getIDebugService();
  String get separator => tu.path.dirSeparator();

  Future<void> readThemeFont() async {
    try {
      final String themeFontName = _settingsService.themeFont;
      if (themeFontName != 'system') {
        final fontFileDir = await tu.font.getFontDir();
        await tu.font.readFont(
          '${fontFileDir.path}$separator$themeFontName',
          themeFontName,
        );
      }
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failedToReadThemeFont'.tr);
    }
  }

  Future<void> deleteFont(String fontName) async {
    if (fontName == 'system') {
      return;
    }
    final fontFileDir = await tu.font.getFontDir();
    final fontFile = File('${fontFileDir.path}$separator$fontName');
    try {
      if (fontFile.existsSync()) {
        await fontFile.delete();
      }
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failedToDeleteFont'.tr);
    }
  }

  Future<bool> loadLocalFont() async {
    try {
      List<File> fontFileList = await getIFilePickerService().pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf', 'ttc'],
        allowMultiple: true,
      );
      if (fontFileList.isEmpty) {
        return false;
      }

      final fontFileDir = await tu.font.getFontDir();
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
