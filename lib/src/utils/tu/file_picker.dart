import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:tao996/tao996.dart';

class FilePickerService implements IFilePickerService {
  const FilePickerService();

  @override
  Future<List<PlatformFile>?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      onFileLoading: onFileLoading,
      compressionQuality: compressionQuality,
      allowMultiple: allowMultiple,
      withData: withData,
      withReadStream: withReadStream,
      lockParentWindow: lockParentWindow,
      readSequential: readSequential,
    );
    return result?.files;
  }
  /// 选择文件，并返回它们的路径
  Future<List<String>> pickFilesPath({
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    final files = await pickFiles(
      allowMultiple: allowMultiple,
      type: PickerFileType.custom,
      // 开放常用的文件类型供用户选择
      allowedExtensions:
          allowedExtensions ??
          ['jpg', 'jpeg', 'png', 'mp4', 'pdf', 'doc', 'mp3', 'zip'],
    );
    if (files == null || files.isEmpty) {
      return [];
    }
    return files
        .where((f) => f.path != null && f.path!.isNotEmpty)
        .map((f) => f.path!)
        .toList();
  }

  /// 获取选择的文件，可以使用 FilepathUtil.getFileNames 来获取文件名
  @override
  Future<List<File>> quickPickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    String? initialDirectory,
    bool allowMultiple = false,
  }) async {
    final pickers = await FilePicker.platform.pickFiles(
      type: type,
      initialDirectory: initialDirectory,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );
    if (pickers != null) {
      return pickers.paths.map((path) => File(path!)).toList();
    }
    return [];
  }

  @override
  Future<String?> getDirectory() async {
    // 这会打开一个原生文件选择对话框，只允许用户选择目录，而不是文件。
    return await FilePicker.platform.getDirectoryPath();
  }

  @override
  Future<String?> pickAndRead({
    FileType type = FileType.any,
    String? initialDirectory,
    List<String>? allowedExtensions,
  }) async {
    try {
      // 调用文件选择器，只允许选择文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type, // 允许选择任何类型的文件
        allowMultiple: false, // 只允许选择单个文件
        initialDirectory: initialDirectory,
        allowedExtensions: allowedExtensions,
      );

      // 如果用户取消了选择，result 将为 null
      if (result == null) {
        return null;
      }

      // 获取用户选择的文件的路径
      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('无法获取所选文件的路径。');
      }

      // 创建文件对象并读取其内容
      final file = File(filePath);
      if (await file.exists()) {
        final keyContent = await file.readAsString();
        return keyContent;
      } else {
        throw Exception('所选文件不存在：$filePath');
      }
    } catch (e) {
      throw Exception('选择或读取文件时发生错误: $e');
    }
  }
}
