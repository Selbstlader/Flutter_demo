import 'dart:io';

/// 网络错误解析工具类
/// 统一处理各种网络错误，提供用户友好的错误信息
class NetworkErrorUtil {
  /// 解析网络错误并返回用户友好的错误信息
  static String parseError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('host lookup failed') || 
        errorStr.contains('api.deepseek.com') ||
        errorStr.contains('dns解析失败')) {
      return 'DNS解析失败，请检查网络连接或DNS设置';
    } else if (errorStr.contains('connection refused')) {
      return '连接被拒绝，请检查网络防火墙设置';
    } else if (errorStr.contains('timeout') || errorStr.contains('超时')) {
      return '连接超时，请检查网络状况';
    } else if (errorStr.contains('certificate') || 
               errorStr.contains('ssl') || 
               errorStr.contains('tls')) {
      return 'SSL证书验证失败，请检查系统时间和证书设置';
    } else if (errorStr.contains('socket')) {
      return '网络连接异常，请重试';
    } else if (error is SocketException) {
      if (error.message.contains('Failed host lookup')) {
        return 'DNS解析失败: 无法连接到服务器，请检查网络连接';
      } else {
        return '网络连接错误: ${error.message}';
      }
    } else if (error is HttpException) {
      return 'HTTP请求错误: ${error.message}';
    } else if (error is FormatException) {
      return '数据格式错误: ${error.message}';
    } else {
      return '网络请求失败: ${error.toString()}';
    }
  }
  
  /// 检查错误是否为网络相关错误
  static bool isNetworkError(dynamic error) {
    if (error is SocketException || error is HttpException) {
      return true;
    }
    
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('network') ||
           errorStr.contains('connection') ||
           errorStr.contains('timeout') ||
           errorStr.contains('dns') ||
           errorStr.contains('socket');
  }
  
  /// 检查错误是否需要重试
  static bool shouldRetry(dynamic error) {
    if (error is SocketException) {
      // DNS解析失败通常不需要立即重试
      if (error.message.contains('Failed host lookup')) {
        return false;
      }
      return true;
    }
    
    final errorStr = error.toString().toLowerCase();
    // 超时和连接错误可以重试
    return errorStr.contains('timeout') ||
           errorStr.contains('connection refused') ||
           errorStr.contains('socket');
  }
}