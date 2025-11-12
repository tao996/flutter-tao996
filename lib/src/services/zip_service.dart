import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:tao996/tao996.dart';

class MyZipService {
  /// 压缩文件
  /// [zipFilePath] 压缩包名称, [password] 解压密码
  /// [workingDirectory] 工作目录，如果存在，则会与 [zipFilePath] 及 [filePaths]的各部分进行拼接
  static Future<void> encode(
    String zipFilePath,
    List<String> filePaths, {
    String? workingDirectory,
    String? password,
    String app = 'zip',
  }) async {
    final encoder = ZipFileEncoder(password: password);
    encoder.create(
      FilepathUtil.resolvePath(zipFilePath, dir: workingDirectory),
    );
    for (final filePath in filePaths) {
      final resolvedPath = FilepathUtil.resolvePath(
        filePath,
        dir: workingDirectory,
      );
      final t = FilepathUtil.getFileType(resolvedPath);
      if (t == FileSystemEntityType.file) {
        await encoder.addFile(File(resolvedPath));
      } else if (t == FileSystemEntityType.directory) {
        await encoder.addDirectory(
          Directory(resolvedPath),
          includeDirName: true, // 保存子目录
        );
      }
    }

    encoder.close();
  }

  /// 解压文件
  /// [zipFilePath] 压缩包名称, [password] 解压密码
  /// [destinationPath] 解压目录
  /// [workingDirectory] 工作目录，如果存在，则会与 [zipFilePath] 和 [destinationPath] 进行拼接
  static Future<void> decode(
    String zipFilePath,
    String destinationPath, {
    String? workingDirectory,
    String? password,
  }) async {
    zipFilePath = FilepathUtil.resolvePath(zipFilePath, dir: workingDirectory);
    destinationPath = FilepathUtil.resolvePath(
      destinationPath,
      dir: workingDirectory,
    );
    await extractFileToDisk(zipFilePath, destinationPath, password: password);
  }
}
