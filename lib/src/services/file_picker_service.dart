import 'dart:io';

import 'package:file_picker/file_picker.dart';

abstract class IFilePickerService {
  /// 选择文件 [type] 文件类型, [allowedExtensions] 文件扩展名
  /// 示例1：选择字体文件 type:FileType.custom, allowedExtensions:['ttf', 'otf', '.ttc', '.TTF', '.OTF', '.TTC'],
  Future<FilePickerResult?> pickFiles({
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
  });

  Future<List<File>> quickPickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  });
}

class FilePickerService implements IFilePickerService {
  @override
  Future<FilePickerResult?> pickFiles({
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
    return await FilePicker.platform.pickFiles(
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
  }
  /// 获取选择的文件，可以使用 FilepathUtil.getFileNames 来获取文件名
  @override
  Future<List<File>> quickPickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    final pickers = await pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );
    if (pickers != null) {
      return pickers.paths.map((path) => File(path!)).toList();
    }
    return [];
  }
}
