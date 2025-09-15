import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FilepathUtil {
  /// 警告：你只能在本地系统中使用本方法，（如果你的路径需要指向远程服务器，则不能使用它）
  /// 标准化用户输入的文件或目录路径。
  /// 该函数能处理不同操作系统（如 Windows 的 \）的路径分隔符，
  /// 并移除多余的 . 和 ..，返回一个在当前系统上有效的、规范化的路径。
  static String normalizeLocalPath(String userPath) {
    // 如果输入为空，直接返回空字符串
    if (userPath.isEmpty) {
      return '';
    }

    // 1. 将 Windows 的路径分隔符 '\' 替换为 '/'
    // 这是为了在处理 . 和 .. 时，能统一格式。
    // 注意：我们只在 Windows 平台上进行此操作，因为其他系统上 \ 是一个合法字符。
    String tempPath = userPath;
    if (Platform.isWindows) {
      tempPath = tempPath.replaceAll(r'\', '/');
    }

    // 2. 使用 path 库的 normalize 方法
    // normalize 会自动：
    //    - 解析路径中的 . 和 ..
    //    - 移除多余的 / (如 //)
    //    - 根据当前操作系统自动使用正确的路径分隔符（/ 或 \）
    final normalizedPath = p.normalize(tempPath);

    return normalizedPath;
  }

  String toPosixPath(List<String> pathSegments) {
    // 使用 p.posix.joinAll() 来连接路径，并确保使用 '/' 作为分隔符。
    return p.posix.joinAll(pathSegments);
  }

  /// 标准化用户输入的文件或目录路径，并统一使用 '/' 作为分隔符。
  static String normalizeToPosixPath(String userPath) {
    // 如果输入为空，直接返回空字符串
    if (userPath.isEmpty) {
      return '';
    }
    final normalizedPath = p.normalize(userPath);
    if (normalizedPath.startsWith('\\') || isWindowsPath(normalizedPath)) {
      return normalizedPath.replaceAll(r'\', '/');
    }

    return normalizedPath;
  }

  static bool isWindowsPath(String path) {
    if (path.isEmpty) {
      return false;
    }

    // 使用正则表达式检查路径格式
    // 1. 检查盘符开头，例如：C:\Users\
    // 2. 检查 UNC 路径，例如：\\Server\Share\
    // 3. 检查相对或绝对路径，例如：\Users\ 或 path\to\file
    // 注意：这个正则表达式是一个近似判断，无法覆盖所有边缘情况
    final RegExp windowsPathRegex = RegExp(
      r'^([a-zA-Z]:\\|\\\\|[a-zA-Z0-9_\-.]+[\\/])',
      caseSensitive: false,
    );

    return windowsPathRegex.hasMatch(path);
  }

  static String separator() {
    return p.posix.separator;
  }

  /// 获取用户的家目录
  static Future<String> homeDir() async {
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

  /// 成功读取文件内容后返回 String，否则返回 null。
  static Future<String?> pick({
    FileType type = FileType.any,
    bool allowMultiple = false,
  }) async {
    try {
      // 调用文件选择器，只允许选择文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type, // 允许选择任何类型的文件
        allowMultiple: allowMultiple, // 只允许选择单个文件
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

  /// 使用 path.posix.joinAll 来拼接路径，确保使用 '/' 分隔符;
  /// 注意，如果 [parts] 内部成员包含了 \\ ，并不会自动替换为 /
  static String joinAll(Iterable<String> parts) {
    return p.posix.joinAll(parts);
  }

  static List<String> split(String path) {
    return p.split(path);
  }

  static String joinAllPosixPath(Iterable<String> parts) {
    return normalizeToPosixPath(p.posix.joinAll(parts));
  }

  static String joinPosixPath(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
    String? part7,
    String? part8,
    String? part9,
    String? part10,
    String? part11,
    String? part12,
    String? part13,
    String? part14,
    String? part15,
    String? part16,
  ]) {
    return normalizeToPosixPath(
      p.posix.join(
        part1,
        part2,
        part3,
        part4,
        part5,
        part6,
        part7,
        part8,
        part9,
        part10,
        part11,
        part12,
        part13,
        part14,
        part15,
        part16,
      ),
    );
  }

  /// 注意，如果 [parts] 内部成员包含了 \\ ，并不会自动替换为 /
  static String join(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
    String? part7,
    String? part8,
    String? part9,
    String? part10,
    String? part11,
    String? part12,
    String? part13,
    String? part14,
    String? part15,
    String? part16,
  ]) {
    return p.posix.join(
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8,
      part9,
      part10,
      part11,
      part12,
      part13,
      part14,
      part15,
      part16,
    );
  }

  /// 获取路径类型，可以使用 FileSystemEntityType.file 来进行比较
  static FileSystemEntityType getFileType(String path) {
    return FileSystemEntity.typeSync(path);
  }

  static String relative(String path, String from) {
    return p.relative(path, from: from);
  }

  /// 获取文件或目录所在的目录
  static String dirname(String filePath) {
    File file = File(filePath);
    return p.dirname(file.path);
  }

  static String basename(String filePath) {
    File file = File(filePath);
    return p.basename(file.path);
  }

  static bool isAbsolute(String path) {
    return p.isAbsolute(path);
  }

  /// 如果 [filepath] 是一个绝对路径，则直接返回 [filepath]，否则检查 [dir]
  /// 如果 [dir] 是一个目录，则将 [dir] 与 [filepath] 组合为文件路径返回
  /// 如果 [dir] 不是一个目录，抛出异常
  static String resolvePath(String filepath, {String? dir}) {
    if (filepath.isEmpty) {
      if (dir != null && dir.isNotEmpty) {
        return resolvePath(dir);
      }
      throw Exception('请提供有效的文件路径');
    }
    // 检查 filepath 是否为绝对路径
    if (isAbsolute(filepath)) {
      return filepath;
    }
    if (dir == null || dir.isEmpty) {
      throw Exception('$filepath 不是一个绝对路径，请提供有效的目录路径以拼接路径');
    }
    // 检查 dir 是否为目录
    if (isAbsolute(dir)) {
      // 将 dir 与 filepath 组合
      return join(dir, filepath);
    } else {
      throw Exception('提供的目录路径 "$dir" 无效或不是一个目录');
    }
  }

  static String fromUri(Object? uri) {
    return p.fromUri(uri);
  }

  /// 获取当前脚本目录
  static String scriptDir() {
    return p.dirname(Platform.script.toFilePath());
  }
}
