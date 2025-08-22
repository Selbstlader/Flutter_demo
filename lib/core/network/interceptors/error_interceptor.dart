import 'package:dio/dio.dart';

import '../../utils/logger_util.dart';
import '../models/api_response.dart';
import '../exceptions/api_exception.dart';

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerUtil.e('网络请求错误', err);
    
    ApiException apiException;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        apiException = ApiException(
          code: 'CONNECTION_TIMEOUT',
          message: '连接超时，请检查网络连接',
          statusCode: -1,
        );
        break;
        
      case DioExceptionType.sendTimeout:
        apiException = ApiException(
          code: 'SEND_TIMEOUT',
          message: '请求超时，请稍后重试',
          statusCode: -1,
        );
        break;
        
      case DioExceptionType.receiveTimeout:
        apiException = ApiException(
          code: 'RECEIVE_TIMEOUT',
          message: '响应超时，请稍后重试',
          statusCode: -1,
        );
        break;
        
      case DioExceptionType.badResponse:
        apiException = _handleResponseError(err);
        break;
        
      case DioExceptionType.cancel:
        apiException = ApiException(
          code: 'REQUEST_CANCELLED',
          message: '请求已取消',
          statusCode: -1,
        );
        break;
        
      case DioExceptionType.unknown:
        apiException = ApiException(
          code: 'NETWORK_ERROR',
          message: '网络连接异常，请检查网络设置',
          statusCode: -1,
        );
        break;
        
      default:
        apiException = ApiException(
          code: 'UNKNOWN_ERROR',
          message: '未知错误，请稍后重试',
          statusCode: -1,
        );
    }
    
    // 将DioException转换为自定义的ApiException
    final customError = DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      type: err.type,
      response: err.response,
    );
    
    super.onError(customError, handler);
  }

  /// 处理响应错误
  ApiException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode ?? -1;
    final responseData = err.response?.data;
    
    String message;
    String code;
    
    // 尝试从响应中解析错误信息
    if (responseData is Map<String, dynamic>) {
      final apiResponse = ApiResponse<dynamic>.fromJson(responseData, (json) => json);
      message = apiResponse.message ?? _getDefaultErrorMessage(statusCode);
      code = apiResponse.code ?? statusCode.toString();
    } else {
      message = _getDefaultErrorMessage(statusCode);
      code = statusCode.toString();
    }
    
    return ApiException(
      code: code,
      message: message,
      statusCode: statusCode,
      data: responseData,
    );
  }

  /// 获取默认错误消息
  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '禁止访问';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不允许';
      case 408:
        return '请求超时';
      case 409:
        return '请求冲突';
      case 422:
        return '请求参数验证失败';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        return '网络请求失败 ($statusCode)';
    }
  }
}