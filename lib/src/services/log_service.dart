import 'package:logger/logger.dart' as lib_logger; // 为了避免命名冲突

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
        printEmojis: false,
        dateTimeFormat: lib_logger.DateTimeFormat.onlyTimeAndSinceStart,
      ),
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
}