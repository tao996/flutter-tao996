import 'dart:io';
import 'package:path/path.dart' as p;
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
}