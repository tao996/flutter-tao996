import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as lib_logger;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // 为了避免命名冲突

abstract class ILogService {
  void i(dynamic message);
  void d(dynamic message);
  void w(dynamic message);
  void e(dynamic message);
}

class LogService implements ILogService {
  late lib_logger.Logger _logger;

  LogService() {
    _logger = lib_logger.Logger(
      printer: lib_logger.PrettyPrinter(
        colors: true,
        printEmojis: true,
        dateTimeFormat: lib_logger.DateTimeFormat.onlyTimeAndSinceStart,
        methodCount: 0, // 减少不必要的堆栈打印
      ),
      output: lib_logger.MultiOutput([
        if (kDebugMode) lib_logger.ConsoleOutput(), // 输出到控制台

        RotatingFileLogOutput(maxFileSize: 1024 * 1024, maxBackupFiles: 5),
      ]),
    );
  }

  @override
  void i(dynamic message) {
    _logger.i(message);
  }

  @override
  void d(dynamic message) {
    _logger.d(message);
  }

  @override
  void w(dynamic message) {
    _logger.w(message);
  }

  @override
  void e(dynamic message) {
    _logger.e(message);
  }

  // 一键分享日志
  static Future<void> shareLogFiles() async {
    final dir = await getApplicationSupportDirectory();
    final logDirPath = p.join(dir.path, 'logs');
    final logDir = Directory(logDirPath);

    if (logDir.existsSync()) {
      // 获取目录下所有的 .txt 日志文件
      final files = logDir
          .listSync()
          .where((file) => file.path.endsWith('.txt'))
          .map((file) => XFile(file.path))
          .toList();

      if (files.isNotEmpty) {
        // 🎯 调起系统分享面板（微信、邮件、隔空投送等）
        final params = ShareParams(files: files, text: '应用运行日志反馈');

        await SharePlus.instance.share(params);
      }
    }
  }
}

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 捕获 Flutter 框架内的错误 (如 Widget 构建错误)
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e("Flutter 框架错误: ${details.exception}", stackTrace: details.stack);
  };

  // 2. 捕获异步错误 (如 未处理的 Future 异常)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logger.e("全局异步错误: $error", stackTrace: stack);
    return true;
  };

  runApp(const MyApp());
}

工业级替代方案：Sentry 或 Firebase Crashlytics
如果你正在开发一个中大型应用，手动维护日志文件会非常痛苦（处理日志滚动、多线程写入冲突、堆栈符号化解析等）。
void logError(String message, dynamic e, StackTrace s) {
  logger.e(message, error: e, stackTrace: s); // 本地存一份
  Sentry.captureException(e, stackTrace: s);    // 自动发给开发人员
}

// 💡 初始化方法
final logger = Logger(
  printer: PrettyPrinter(methodCount: 2, lineLength: 80),
  output: MultiOutput([
    ConsoleOutput(),
    RotatingFileLogOutput(maxFileSize: 1024 * 1024, maxBackupFiles: 5), // 1MB 滚动，保留 5 份
  ]),
);
*/
class RotatingFileLogOutput extends lib_logger.LogOutput {
  final int maxFileSize; // 单个文件最大字节数
  final int maxBackupFiles; // 最大备份文件数
  String? _logDirPath;

  RotatingFileLogOutput({
    this.maxFileSize = 2 * 1024 * 1024, // 默认 2MB
    this.maxBackupFiles = 3, // 默认保留 3 个旧备份
  });

  @override
  void output(lib_logger.OutputEvent event) async {
    try {
      await _writeToLog(event.lines.join('\n'));
    } catch (e) {
      // 这里的错误通常无法记录，建议简单打印
      print("写入日志文件失败: $e");
    }
  }

  Future<void> _writeToLog(String content) async {
    if (_logDirPath == null) {
      final dir = await getApplicationSupportDirectory();
      _logDirPath = p.join(dir.path, 'logs');
      final directory = Directory(_logDirPath!);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
    }

    final logFile = File(p.join(_logDirPath!, 'current_log.txt'));

    // 1. 检查文件大小并执行滚动逻辑
    if (logFile.existsSync() && logFile.lengthSync() > maxFileSize) {
      await _rotateLogs();
    }

    // 2. 写入内容
    await logFile.writeAsString(
      '$content\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  // 滚动逻辑：log.2 -> log.3; log.1 -> log.2; current -> log.1
  Future<void> _rotateLogs() async {
    for (var i = maxBackupFiles - 1; i >= 1; i--) {
      final oldFile = File(p.join(_logDirPath!, 'app_log.$i.txt'));
      if (oldFile.existsSync()) {
        final newPath = p.join(_logDirPath!, 'app_log.${i + 1}.txt');
        await oldFile.rename(newPath);
      }
    }

    final currentFile = File(p.join(_logDirPath!, 'current_log.txt'));
    if (currentFile.existsSync()) {
      await currentFile.rename(p.join(_logDirPath!, 'app_log.1.txt'));
    }
  }
}
