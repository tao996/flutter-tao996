import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FilepathUtil {
  /// 标准化用户输入的文件或目录路径。
  /// 该函数能处理不同操作系统（如 Windows 的 \）的路径分隔符，
  /// 并移除多余的 . 和 ..，返回一个在当前系统上有效的、规范化的路径。
  static String normalizeUserPath(String userPath) {
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

  /// 路径拼接，并需要提供 '/' 或者 '\'
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
    return p.join(
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

  static FileSystemEntityType checkPathType(String path) {
    // 使用 typeSync() 获取路径的类型
    return FileSystemEntity.typeSync(path);
  }
  /// 获取文件或目录所在的目录
  static String dirname(String filePath) {
    File file = File(filePath);
    return p.dirname(file.path);
  }
}
