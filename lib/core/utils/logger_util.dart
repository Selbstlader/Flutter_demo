import 'package:logger/logger.dart';

/// 日志工具类
class LoggerUtil {
  // 私有构造函数，防止实例化
  LoggerUtil._();

  static Logger? _logger;

  /// 初始化日志工具
  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // 显示调用栈的方法数量
        errorMethodCount: 8, // 错误时显示的调用栈数量
        lineLength: 120, // 每行的长度
        colors: true, // 启用颜色
        printEmojis: true, // 启用表情符号
        printTime: false, // 显示时间
      ),
    );
  }

  /// 获取Logger实例，如果未初始化则自动初始化
  static Logger get logger {
    if (_logger == null) {
      init();
    }
    return _logger!;
  }

  /// 调试日志
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 致命错误日志
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 跟踪日志
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.t(message, error: error, stackTrace: stackTrace);
  }
}