import 'dart:developer' as developer;

class LoggerUtil {
  static void info(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'INFO', level: 800);
  }

  static void error(String message, {String? tag, Object? error}) {
    developer.log(message, name: tag ?? 'ERROR', level: 1000, error: error);
  }

  static void warning(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'WARNING', level: 900);
  }

  static void debug(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'DEBUG', level: 500);
  }

  // 简短方法名别名
  static void e(String message, {String? tag, Object? error}) {
    LoggerUtil.error(message, tag: tag, error: error);
  }

  static void d(String message, {String? tag}) {
    debug(message, tag: tag);
  }

  static void w(String message, {String? tag}) {
    warning(message, tag: tag);
  }

  static void i(String message, {String? tag}) {
    info(message, tag: tag);
  }
}