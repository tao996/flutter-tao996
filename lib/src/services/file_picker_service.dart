import 'dart:io';

import 'package:file_picker/file_picker.dart';

typedef PickerFileType = FileType;
typedef PickerPlatformFile = PlatformFile;

abstract class IFilePickerService {
  /// 选择文件，注意只有在 [withData] 或 [withReadStream] 有一个为 true 时，才会读取文件的内容；都为 false 时，只会获取到文件的元数据（如名称、路径）
  ///
  /// [dialogTitle] 设置文件选择模态窗口的标题。 仅在 windows/linux 下有效
  ///
  /// [initialDirectory] 指定文件选择对话框打开时的初始目录绝对路径。 windows/linux/macos 下有效
  ///
  /// [type] 定义允许用户选择的文件类型。例如：FileType.image (图片), FileType.video (视频), FileType.custom (自定义)。
  ///
  /// [allowedExtensions] 配合 FileType.custom 使用，指定允许的文件扩展名列表。例如：['pdf', 'svg', 'jpg']。注意： 传入的扩展名不带 .。
  ///
  /// [onFileLoading] 用于跟踪文件加载状态的回调函数。当文件来自云存储（如 Google Drive）需要时间缓存时非常有用。
  ///
  /// [compressionQuality] 指定压缩质量（0 到 100）。仅在 android/ios 下选择图片/视频时可能有效。降低图片/视频文件大小，减少内存占用。
  ///
  /// [allowMultiple] 是否允许用户一次选择多个文件。	批量上传、导入等场景。
  ///
  /// [withData] 如果设置为 true，选中的文件内容将立即作为 Uint8List 加载到内存中。	桌面端、Web 默认 true；iOS/Android 默认 false;
  /// 适用于小文件（如用户头像）的即时上传。警告： 移动端选择大文件或多文件时，易导致 OOM (内存溢出) 崩溃。
  /// ```
  /// // 获取字节数据，适用于小文件
  /// final result = await FilePicker.platform.pickFiles(withData: true);
  /// final bytes = result!.files.first.bytes; // 直接获取 Uint8List
  /// ```
  ///
  /// [withReadStream] 如果设置为 true，文件内容将作为 `Stream<List<int>>` 可用。仅支持 Android, iOS, Windows, Linux
  /// ```
  /// // 获取文件流，适用于大文件
  /// final result = await FilePicker.platform.pickFiles(withReadStream: true);
  /// final stream = result!.files.first.readStream; // 获取 Stream<List<int>>
  /// // ... 将 stream 用于上传或处理
  /// ```
  ///
  /// [lockParentWindow] 仅支持 windows, 如果设置为 true，文件选择窗口会锁定 Flutter 父窗口（像模态窗口一样）。确保用户必须处理文件选择对话框才能继续操作主应用。
  ///
  /// [readSequential] 确保在 Web 端导入文件时，保持文件选择的顺序。
  Future<List<PlatformFile>?> pickPlatformFile({
    String? dialogTitle,
    String? initialDirectory,
    PickerFileType type = PickerFileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  });

  Future<List<File>> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    String? initialDirectory,
    bool allowMultiple = false,
  });

  /// 调用原生文件选择器来选择一个目录
  Future<String?> getDirectory();

  /// 成功读取文件内容后返回 String，否则返回 null。
  Future<String?> getPickFileContent({
    FileType type = FileType.any,
    String? initialDirectory,
    List<String>? allowedExtensions,
  });
}
