import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// https://pub.dev/packages/path_provider
/// windows 10+
abstract class IPathService {
  /// 获取临时目录（全平台支持）
  /// 存储临时、非必要的数据。
  ///
  /// 随时可能被操作系统清除 (例如，设备存储空间不足时)。应用退出或重启后数据不保证保留。适用于缓存图片、临时下载文件等。
  ///
  /// ```
  /// iOS/macOS: ~/Library/Caches/Temporary
  /// Android: /data/data/<package_name>/cache
  ///
  /// 适用场景：
  /// 网络图片缓存： 在下载图片时，先存入此目录，用完即删。
  /// 文件上传前的预处理： 例如，用户选择了一个文件，但在正式上传前，需要在此目录进行压缩或裁剪。
  /// 日志文件： 存储短期运行日志。
  /// ```
  Future<Directory> getTemporaryDirectoryPath();

  /// 获取应用目录（全平台支持）
  /// 存储用户生成的重要数据。
  ///
  /// ```
  /// iOS/macOS: ~/Documents
  /// Android: /data/data/<package_name>/files
  /// Windows: %USERPROFILE%\Documents\<app_name>
  /// ```
  /// 用于存储用户主动创建、修改或依赖的文件，例如：用户创建的文档、编辑的图片、数据库文件（如 SQLite 或 Hive）。
  /// 这些数据会随应用备份，并且不会被系统自动清理。
  Future<Directory> getApplicationDocumentsDirectoryPath();

  /// 获取下载目录（全平台支持）
  /// 用于存放对外共享的下载文件。
  /// 仅支持 桌面平台 (Windows/Linux/macOS)。移动端不支持或返回 null。用于将用户下载的文件放置在操作系统标准的下载文件夹中。
  Future<Directory?> getDownloadsDirectoryPath();

  /// 获取应用支持目录（全平台支持）
  /// 存储应用所需的支持文件和配置。
  ///
  /// 存储应用运行所需的非用户数据，例如：自定义字体、日志文件、应用配置、私有模型数据等。这些数据在应用更新时通常会保留。
  ///
  /// ```
  /// iOS/macOS: ~/Library/Application Support/<bundle_id>
  /// Android: /data/data/<package_name>/app_data
  /// 适用场景：
  /// 日志和崩溃报告： 应用的诊断日志和崩溃文件。
  /// 自定义资产/字体： 应用下载的用于渲染的自定义文件或模型。
  /// 应用特定的配置： 内部使用的、不希望用户轻易访问和修改的配置文件。
  /// ```
  Future<Directory> getApplicationSupportDirectoryPath();

  /// 获取缓存目录（全平台支持）
  /// 存储缓存文件，但比 Temporary 稳定。
  /// 存储应用可以重新下载或生成的缓存数据，例如：大图缓存、视频片段等。系统可以清理，但清理频率低于 Temporary。
  Future<Directory> getApplicationCacheDirectoryPath();

  /// 用户的家目录
  Future<String> homeDir();
}

class PathService implements IPathService {
  @override
  Future<Directory> getTemporaryDirectoryPath() async {
    return await getTemporaryDirectory();
  }

  @override
  Future<Directory> getApplicationDocumentsDirectoryPath() async {
    return await getApplicationDocumentsDirectory();
  }

  @override
  Future<Directory> getApplicationSupportDirectoryPath() async {
    return await getApplicationSupportDirectory();
  }

  @override
  Future<Directory> getApplicationCacheDirectoryPath() async {
    return await getApplicationCacheDirectory();
  }

  @override
  Future<Directory?> getDownloadsDirectoryPath() async {
    return await getDownloadsDirectory();
  }

  /// 获取用户的家目录
  @override
  Future<String> homeDir() async {
    // 1. 获取用户的家目录
    if (Platform.isWindows) {
      // Windows 上的家目录变量是 'USERPROFILE'
      return Platform.environment['USERPROFILE']!;
    } else if (Platform.isLinux || Platform.isMacOS) {
      // Linux 和 macOS 上的家目录变量是 'HOME'
      return Platform.environment['HOME']!;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // 在移动设备上，通常使用应用的文档目录作为存储空间
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }

    throw Exception('当前操作系统不支持获取用户主目录');
  }
}
