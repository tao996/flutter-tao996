import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:tao996/tao996.dart';

class FilepathUtil {
  const FilepathUtil();

  /// 标准化用户输入的文件或目录路径，并统一使用 '/' 作为分隔符。
  String normalize(String userPath) {
    // 如果输入为空，直接返回空字符串
    if (userPath.isEmpty) {
      return '';
    }
    // 2. 使用 path 库的 normalize 方法
    // normalize 会自动：
    //    - 解析路径中的 . 和 ..
    //    - 移除多余的 / (如 //)
    //    - 根据当前操作系统自动使用正确的路径分隔符（/ 或 \）
    final normalizedPath = p.normalize(userPath);
    if (normalizedPath.startsWith('\\') || isWindowsPath(normalizedPath)) {
      return normalizedPath.replaceAll(r'\', '/');
    }

    return normalizedPath;
  }

  bool isWindowsPath(String path) {
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

  /// 分割符，On Mac and Linux, this is /. On Windows, it's \.
  String separator() {
    return p.posix.separator;
  }

  String dirSeparator() {
    return Platform.isWindows ? '\\' : '/';
  }

  /// 将路径按分隔符进行分割
  /// ```
  /// p.split('path/to/foo'); // -> 'path', 'to', 'foo'
  /// p.split('path/../foo'); // -> 'path', '..', 'foo'
  /// // Unix
  /// p.split('/path/to/foo'); // -> '/', 'path', 'to', 'foo'
  ///
  /// // Windows
  /// p.split(r'C:\path\to\foo'); // -> 'C:\', 'path', 'to', 'foo'
  /// p.split(r'\\server\share\path\to\foo');
  /// // -> r'\\server\share', 'foo', 'bar', 'baz'
  ///
  /// // Browser
  /// p.split('https://dart.dev/path/to/foo');
  ///   // -> 'https://dart.dev', 'path', 'to', 'foo'
  /// ```
  List<String> split(String path) {
    return p.split(path);
  }

  /// 使用 path.posix.joinAll 来拼接路径，确保使用 '/' 分隔符;
  /// 注意，如果 [parts] 内部成员包含了 \\ ，并不会自动替换为 /
  String posixJoinAll(Iterable<String> parts) {
    return p.posix.joinAll(parts);
  }

  String joinAll(Iterable<String> parts) {
    return p.joinAll(parts);
  }

  /// 强制使用 POSIX（Portable Operating System Interface，可移植操作系统接口）路径风格，无论代码运行在哪个平台上
  /// 分隔符： 永远使用正斜杠 / 作为路径分隔符。
  /// 核心目标： 统一性/标准化。 适用于需要一个统一的、平台无关的路径表示的场景。注意：如果你在 Windows 上使用 p.posix.join() 生成了一个路径，并试图用 File(path) 去访问它，它可能会因为分隔符错误而失败
  /// 1. URL 或网络路径
  /// 2. 处理 zip/tar 文件内部路径
  /// 3. 配置文件或跨平台数据模型（某个路径作为 json 文件中的值出现）
  /// 4. 已知平台是 POSIX 平台
  /// ```
  /// context.join('path', 'to', 'foo'); // -> 'path/to/foo'
  /// context.join('path/', 'to', 'foo'); // -> 'path/to/foo'
  /// 某部分是绝对路径，则忽略其他所有部件
  /// context.join('path', '/to', 'foo'); // -> '/to/foo'
  /// ```
  String posixJoin(
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

  /// 使用 当前代码运行所在平台 的路径风格和分隔符来连接路径片段
  /// 注意，会对结果进行 normalize 处理
  /// 几乎所有涉及到 本地文件系统操作 的场景都应该使用 p.join()
  /// ```
  /// p.join('path', 'to', 'foo'); // -> 'path/to/foo'
  /// p.join('path/', 'to', 'foo'); // -> 'path/to/foo'
  /// 如果某个部件是绝对路径，则忽略其他所有部件
  /// p.join('path', '/to', 'foo'); // -> '/to/foo'
  /// ```
  String join(
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
    return normalize(
      p.join(
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

  /// 获取路径类型，可以使用 FileSystemEntityType.file 来进行比较
  FileSystemEntityType getFileType(String path) {
    return FileSystemEntity.typeSync(path);
  }

  /// 获取相对路径
  /// ```
  /// // Given current directory is /root/path:
  /// p.relative('/root/path/a/b.dart'); // -> 'a/b.dart'
  /// p.relative('/root/other.dart'); // -> '../other.dart'
  /// // 手动指定根目录
  /// p.relative('/root/path/a/b.dart', from: '/root/path'); // -> 'a/b.dart'
  /// p.relative('/root/other.dart', from: '/root/path');    // -> '../other.dart'
  /// // Windows
  /// p.relative(r'D:\other', from: r'C:\home'); // -> 'D:\other'
  /// // URL
  /// p.relative('https://dart.dev', from: 'https://pub.dev');  // -> 'https://dart.dev'
  /// ```
  String relative(String path, {required String from}) {
    return p.relative(path, from: from);
  }

  /// 获取文件或目录所在的目录
  /// ```
  /// p.dirname('path/to/foo.dart'); // -> 'path/to'
  /// p.dirname('path/to');          // -> 'path'
  /// p.dirname('path/to/');         // -> 'path'
  /// p.dirname('/');                // -> '/' (posix)
  /// p.dirname('c:\');              // -> 'c:\' (windows)
  /// p.dirname('foo');              // -> '.'
  /// p.dirname('');                 // -> '.'
  /// ```
  String dirname(String filePath) {
    File file = File(filePath);
    return p.dirname(file.path);
  }

  /// 获取文件名+扩展名
  /// ```
  /// p.basename('path/to/foo.dart'); // -> 'foo.dart'
  /// p.basename('path/to');          // -> 'to'
  /// p.basename('path/to/'); // -> 'to'
  /// ```
  String basename(String filePath) {
    File file = File(filePath);
    return p.basename(file.path);
  }

  /// 获取文件名
  /// ```
  /// p.basenameWithoutExtension('path/to/foo.dart'); // -> 'foo'
  /// p.basenameWithoutExtension('path/to/foo.dart/'); // -> 'foo'
  /// ```
  String basenameWithoutExtension(String filePath) {
    File file = File(filePath);
    return p.basenameWithoutExtension(file.path);
  }

  /// 获取扩展名
  /// ```
  /// p.extension('path/to/foo.dart');    // -> '.dart'
  /// p.extension('path/to/foo');         // -> ''
  /// p.extension('path.to/foo');         // -> ''
  /// p.extension('path/to/foo.dart.js'); // -> '.js'
  /// p.extension('foo.bar.dart.js', 2);   // -> '.dart.js
  /// p.extension('foo.bar.dart.js', 3);   // -> '.bar.dart.js'
  /// p.extension('foo.bar.dart.js', 10);  // -> '.bar.dart.js'
  /// p.extension('path/to/foo.bar.dart.js', 2);  // -> '.dart.js
  /// ```
  String extension(String filePath) {
    File file = File(filePath);
    return p.extension(file.path);
  }

  /// 获取文件路径，去除扩展名
  /// ```
  /// p.withoutExtension('path/to/foo.dart'); // -> 'path/to/foo
  /// ```
  String withoutExtension(String filePath) {
    File file = File(filePath);
    return p.withoutExtension(file.path);
  }

  /// 是否为一个绝对地址
  bool isAbsolute(String path) {
    return p.isAbsolute(path);
  }

  String absolute(
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
  ]) {
    return p.absolute(
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
    );
  }

  /// 如果 [filepath] 是一个绝对路径，则直接返回 [filepath]，否则检查 [dir]；
  /// 如果 [dir] 是一个目录，则将 [dir] 与 [filepath] 组合为文件路径返回；
  /// 如果 [dir] 不是一个目录，抛出异常；
  /// 注意：会对结果进行 normalize 处理
  String resolvePath(String filepath, {String? dir}) {
    if (filepath.isEmpty) {
      if (dir != null && dir.isNotEmpty) {
        return resolvePath(dir);
      }
      throw Exception('请提供有效的文件路径');
    }
    // 检查 filepath 是否为绝对路径
    if (isAbsolute(filepath)) {
      return normalize(filepath);
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

  /// 获取文件路径
  /// ```
  /// // POSIX
  /// p.fromUri('file:///path/to/foo') // -> '/path/to/foo'
  ///
  /// // Windows
  /// p.fromUri('file:///C:/path/to/foo') // -> r'C:\path\to\foo'
  ///
  /// // URL
  /// p.fromUri('https://dart.dev/path/to/foo') // -> 'https://dart.dev/path/to/foo'
  ///
  /// // 相对路径会被直接返回
  /// p.fromUri('path/to/foo'); // -> 'path/to/foo'
  /// ```
  String fromUri(Object? uri) {
    return p.fromUri(uri);
  }

  /// 获取当前脚本目录（应用所在目录）
  String scriptDir() {
    return p.dirname(Platform.script.toFilePath());
  }

  /// 获取字符串的文件名列表
  List<String> getFileNames(List<File> files) {
    return files.map((file) => file.path.split(dirSeparator()).last).toList();
  }

  /// 根据文件路径推断 MIME 类型
  String? getMimeTypeFromPath(String filePath) {
    // 1. 获取文件扩展名 (例如 'jpg')
    final extension = p.extension(filePath);

    if (extension.isEmpty) {
      return null;
    }

    // 2. 使用 mime 库根据扩展名查找类型
    // 注意：lookupMimeType 可能会返回 null
    final mimeType = lookupMimeType(filePath);

    return mimeType;
  }

  /// 判断给定的地址是网络地址还是本地文件路径。
  ResourceLocation determineLocation(String address) {
    try {
      if (address.startsWith('assets/')) {
        return ResourceLocation.assets;
      } else if (isWindowsPath(address) || isAbsolute(address)) {
        return ResourceLocation.local;
      }
      // 1. 尝试解析地址为 Uri 对象
      final uri = Uri.parse(address);

      // 2. 检查协议 (Scheme)
      final scheme = uri.scheme.toLowerCase();

      // 2.1. 判断为网络地址
      if (scheme.startsWith('http') ||
          scheme.startsWith('https') ||
          scheme.startsWith('ftp') ||
          scheme.startsWith('ws')) {
        return ResourceLocation.network;
      }

      // 2.2. 判断为本地文件地址
      // 'file' 协议明确表示本地文件
      if (scheme == 'file') {
        return ResourceLocation.local;
      }

      // 3. 处理无协议的本地路径 (常见于dart:io的File构造函数)
      // 如果没有明确的协议，且路径不为空，我们倾向于将其视为本地路径
      if (scheme.isEmpty && uri.path.isNotEmpty) {
        // 进一步检查路径是否以文件系统的分隔符开头 (e.g., /或C:\)
        // 注意：对于不明确的相对路径，这个判断可能不完美，但通常足够
        if (uri.path.startsWith('/') ||
            (uri.path.length > 1 && uri.path[1] == ':')) {
          return ResourceLocation.local;
        }
      }

      return ResourceLocation.unknown;
    } on FormatException {
      // 如果 Uri.parse 失败（地址格式完全错误），我们假设它是本地文件路径，
      // 因为很多本地路径在没有协议时，parse() 不会报错，但这里是针对格式错误的情况。
      // 对于一个格式完全错误的字符串，最好是返回 unknown。
      return ResourceLocation.unknown;
    }
  }

  /// 检查文件或者目录是否存在
  bool exists(String path) {
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }
}
