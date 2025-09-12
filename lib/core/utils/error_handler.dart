import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/logger_util.dart';

/// 统一错误处理工具类
/// 整合所有类型的错误处理逻辑，提供统一的错误处理接口
class ErrorHandler {
  /// 处理错误并返回用户友好的错误信息
  static String handleError(dynamic error, {String? context}) {
    String errorMessage;
    
    // 记录错误日志
    LoggerUtil.e('Error in ${context ?? 'unknown context'}: $error');
    
    if (error is DioException) {
      errorMessage = _handleDioError(error);
    } else if (error is SocketException) {
      errorMessage = _handleSocketError(error);
    } else if (error is HttpException) {
      errorMessage = _handleHttpError(error);
    } else if (error is FormatException) {
      errorMessage = _handleFormatError(error);
    } else if (error is TimeoutException) {
      errorMessage = _handleTimeoutError(error);
    } else if (error is String) {
      errorMessage = error;
    } else {
      errorMessage = _handleGenericError(error);
    }
    
    return _getUserFriendlyMessage(errorMessage);
  }
  
  /// 处理Dio网络请求错误
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络连接';
      case DioExceptionType.sendTimeout:
        return '请求发送超时，请稍后重试';
      case DioExceptionType.receiveTimeout:
        return '响应接收超时，请稍后重试';
      case DioExceptionType.badResponse:
        return _handleHttpStatusError(error.response?.statusCode, error.response?.data);
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badCertificate:
        return 'SSL证书验证失败，请检查系统时间和证书设置';
      case DioExceptionType.unknown:
      default:
        return '网络请求失败: ${error.message ?? '未知错误'}';
    }
  }
  
  /// 处理HTTP状态码错误
  static String _handleHttpStatusError(int? statusCode, dynamic responseData) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '权限不足，无法访问';
      case 404:
        return '请求的资源不存在';
      case 408:
        return '请求超时，请稍后重试';
      case 409:
        return '数据冲突，请刷新后重试';
      case 422:
        return '数据验证失败，请检查输入信息';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误，请稍后重试';
      case 502:
        return '网关错误，请稍后重试';
      case 503:
        return '服务暂时不可用，请稍后重试';
      case 504:
        return '网关超时，请稍后重试';
      default:
        return 'HTTP错误 ($statusCode): ${_extractErrorMessage(responseData)}';
    }
  }
  
  /// 从响应数据中提取错误信息
  static String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 
             responseData['error'] ?? 
             responseData['msg'] ?? 
             '服务器返回错误';
    } else if (responseData is String) {
      return responseData;
    } else {
      return '服务器返回未知错误';
    }
  }
  
  /// 处理Socket错误
  static String _handleSocketError(SocketException error) {
    if (error.message.contains('Failed host lookup')) {
      return 'DNS解析失败，请检查网络连接';
    } else if (error.message.contains('Connection refused')) {
      return '连接被拒绝，请检查网络设置';
    } else {
      return '网络连接错误: ${error.message}';
    }
  }
  
  /// 处理HTTP错误
  static String _handleHttpError(HttpException error) {
    return 'HTTP请求错误: ${error.message}';
  }
  
  /// 处理格式错误
  static String _handleFormatError(FormatException error) {
    return '数据格式错误: ${error.message}';
  }
  
  /// 处理超时错误
  static String _handleTimeoutError(TimeoutException error) {
    return '请求超时: ${error.message ?? '操作超时，请稍后重试'}';
  }
  
  /// 处理通用错误
  static String _handleGenericError(dynamic error) {
    return '发生未知错误: ${error.toString()}';
  }
  
  /// 获取用户友好的错误信息
  static String _getUserFriendlyMessage(String errorMessage) {
    final message = errorMessage.toLowerCase();
    
    // 认证相关错误
    if (message.contains('invalid login credentials') || 
        message.contains('邮箱或密码错误')) {
      return '登录失败，请检查您的邮箱和密码是否正确';
    }
    
    if (message.contains('email not confirmed') || 
        message.contains('邮箱未验证')) {
      return '请先验证您的邮箱地址，查看邮箱中的验证链接';
    }
    
    if (message.contains('user already registered') || 
        message.contains('该邮箱已被注册')) {
      return '该邮箱已被注册，请使用其他邮箱或尝试登录';
    }
    
    // 网络相关错误
    if (message.contains('network') || message.contains('网络')) {
      return '网络连接失败，请检查网络设置';
    }
    
    if (message.contains('timeout') || message.contains('超时')) {
      return '请求超时，请检查网络状况后重试';
    }
    
    if (message.contains('dns') || message.contains('host lookup')) {
      return 'DNS解析失败，请检查网络连接或DNS设置';
    }
    
    // 服务器相关错误
    if (message.contains('server') || message.contains('服务器')) {
      return '服务器暂时不可用，请稍后重试';
    }
    
    return errorMessage;
  }
  
  /// 检查错误是否为网络相关错误
  static bool isNetworkError(dynamic error) {
    if (error is SocketException || 
        error is HttpException || 
        error is TimeoutException) {
      return true;
    }
    
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.sendTimeout ||
             error.type == DioExceptionType.receiveTimeout ||
             error.type == DioExceptionType.connectionError;
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
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          // 5xx错误可以重试，4xx错误通常不需要重试
          final statusCode = error.response?.statusCode;
          return statusCode != null && statusCode >= 500;
        default:
          return false;
      }
    }
    
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('timeout') ||
           errorStr.contains('connection refused') ||
           errorStr.contains('socket');
  }
  
  /// 检查是否为认证错误
  static bool isAuthError(dynamic error) {
    if (error is DioException && error.response?.statusCode == 401) {
      return true;
    }
    
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('unauthorized') ||
           errorStr.contains('invalid login') ||
           errorStr.contains('authentication') ||
           errorStr.contains('token');
  }
}