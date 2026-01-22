import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tao996/tao996.dart';
import 'package:crypto/crypto.dart';

class FileUtil implements IFilePickerService {
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
  Future<void> saveImageToGallery({
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

  /// 保存文件到相册
  Future<void> saveFileToGallery(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
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

  /// 文件是否
  bool exists(String filePath) {
    return File(filePath).existsSync();
  }

  /// 异步计算给定文件的 MD5 哈希值
  /// 返回一个 32 字符的十六进制字符串
  Future<String> fileMd5(String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
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

  @override
  Future<List<PlatformFile>?> pickPlatformFile({
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

  /// 选择文件，并返回它们的路径 [suggestExtensions] 常见的文件类型
  Future<List<String>> pickFilesPath({
    bool allowMultiple = true,
    List<String>? allowedExtensions,
    bool suggestExtensions = true,
  }) async {
    if (allowedExtensions == null && suggestExtensions) {
      allowedExtensions = [
        'jpg',
        'jpeg',
        'png',
        'mp4',
        'pdf',
        'doc',
        'mp3',
        'zip',
      ];
    }
    final files = await pickFiles(
      allowMultiple: allowMultiple,
      type: PickerFileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (files.isEmpty) {
      return [];
    }
    return files.where((f) => f.path.isNotEmpty).map((f) => f.path).toList();
  }

  /// 返回第1个选择文件的路径
  Future<String?> pickFirstPath({List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      return result.files.single.path!;
    }
    return null;
  }

  /// 获取选择的文件，可以使用 FilepathUtil.getFileNames 来获取文件名
  @override
  Future<List<File>> pickFiles({
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
  Future<String?> getPickFileContent({
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
      if (file.existsSync()) {
        final keyContent = await file.readAsString();
        return keyContent;
      } else {
        throw Exception('所选文件不存在：$filePath');
      }
    } catch (e) {
      throw Exception('选择或读取文件时发生错误: $e');
    }
  }

  /// 从相册中选择多份文件
  Future<List<XFile>?> pickXFilesFromGallery({
    ImagePickerMultipleSource source = ImagePickerMultipleSource.image,
  }) async {
    final picker = ImagePicker();
    switch (source) {
      case ImagePickerMultipleSource.image:
        return await picker.pickMultiImage();
      case ImagePickerMultipleSource.medio:
        return await picker.pickMultipleMedia();
      case ImagePickerMultipleSource.video:
        return await picker.pickMultiVideo();
    }
  }

  /// 选择多份资源（默认图片），并返回路径
  Future<List<String>> pickXFilePathFromGallery({
    ImagePickerMultipleSource source = ImagePickerMultipleSource.image,
  }) async {
    final files = await pickXFilesFromGallery(source: source);
    if (files == null || files.isEmpty) {
      return [];
    }
    return files.map((f) => f.path).toList();
  }

  /// 选择/拍摄一个图片或视频；
  /// 可以通过 `File(pickedFile.path)` 将结果转为一个 File 对象
  Future<XFile?> take({
    ImagePickerSource source = ImagePickerSource.gallery,
  }) async {
    final picker = ImagePicker();
    switch (source) {
      case ImagePickerSource.camera:
        return await picker.pickImage(source: ImageSource.camera);
      case ImagePickerSource.gallery:
        return await picker.pickImage(source: ImageSource.gallery);
      case ImagePickerSource.galleryVideo:
        return await picker.pickVideo(source: ImageSource.gallery);
      case ImagePickerSource.cameraVideo:
        return await picker.pickVideo(source: ImageSource.camera);
      case ImagePickerSource.media:
        return await picker.pickMedia();
    }
  }

  /// 返回选择/拍摄图片或视频的路径
  Future<String?> taskPath({
    ImagePickerSource source = ImagePickerSource.gallery,
  }) async {
    final file = await take(source: source);
    if (file != null) {
      return file.path;
    }
    return null;
  }
}
