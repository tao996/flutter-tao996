import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../tao996.dart';


abstract class IFontService {
  Future<List<String>> readAllFont();

  Future<void> readThemeFont();

  Future<void> deleteFont(String fontName);

  Future<bool> loadLocalFont();
}

class FontService implements IFontService {
  final ISettingsService _settingsService = getISettingsService();
  final IDebugService _debugService = getIDebugService();

  String _getDirSeparator() {
    return Platform.isWindows ? '\\' : '/';
  }

  Future<Directory> _getFontDir() async {
    final Directory appWorkDir =
        Platform.isAndroid
            ? await getApplicationDocumentsDirectory()
            : await getApplicationSupportDirectory();
    final String fontDirPath = '${appWorkDir.path}${_getDirSeparator()}fonts';
    final Directory fontDir = Directory(fontDirPath);
    if (!(await fontDir.exists())) {
      await fontDir.create(recursive: true);
    }
    return fontDir;
  }

  Future<void> _readFont(String fontFilePath, String fontName) async {
    final fontFile = File(fontFilePath);
    final fontFileBytes = await fontFile.readAsBytes();
    final fontLoad = FontLoader(fontName);
    fontLoad.addFont(Future.value(ByteData.view(fontFileBytes.buffer)));
    fontLoad.load();
  }

  @override
  Future<List<String>> readAllFont() async {
    try {
      List<String> fontNameList = [];
      final fontDir = await _getFontDir();
      for (var fontFile in fontDir.listSync()) {
        final fontName = fontFile.path.split(_getDirSeparator()).last;
        await _readFont(fontFile.path, fontName);
        fontNameList.add(fontName);
      }
      return fontNameList;
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failed to read font files'.tr);
    }
  }

  @override
  Future<void> readThemeFont() async {
    try {
      final String themeFontName = _settingsService.themeFont;
      if (themeFontName != 'system') {
        final fontFileDir = await _getFontDir();
        await _readFont(
          '${fontFileDir.path}${_getDirSeparator()}$themeFontName',
          themeFontName,
        );
      }
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failed to read theme font'.tr);
    }
  }

  @override
  Future<void> deleteFont(String fontName) async {
    if (fontName == 'system') {
      return;
    }
    final fontFileDir = await _getFontDir();
    final fontFile = File('${fontFileDir.path}${_getDirSeparator()}$fontName');
    try {
      if (await fontFile.exists()) {
        await fontFile.delete();
      }
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failed to delete font'.tr);
    }
  }

  @override
  Future<bool> loadLocalFont() async {
    try {
      final fontFilePicker = await getIFilePickerService().pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf', '.ttc', '.TTF', '.OTF', '.TTC'],
        allowMultiple: true,
      );
      if (fontFilePicker != null) {
        List<File> fontFileList =
            fontFilePicker.paths.map((path) => File(path!)).toList();
        final fontFileDir = await _getFontDir();
        for (var fontFile in fontFileList) {
          final fontFileName = fontFile.path.split(_getDirSeparator()).last;
          final newFontPath =
              '${fontFileDir.path}${_getDirSeparator()}$fontFileName';
          await fontFile.copy(newFontPath);
          // await fontFile.delete();
        }
        return true;
      }
      return true;
    } catch (error, stackTrace) {
      _debugService.exception(error, stackTrace);
      throw Exception('failed to import fonts'.tr);
    }
  }
}
