import 'package:dio/dio.dart';

import '../../utils/logger_util.dart';

/// 日志拦截器
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LoggerUtil.d('🚀 请求开始');
    LoggerUtil.d('请求方法: ${options.method}');
    LoggerUtil.d('请求URL: ${options.uri}');
    LoggerUtil.d('请求头: ${options.headers}');
    
    if (options.data != null) {
      LoggerUtil.d('请求数据: ${options.data}');
    }
    
    if (options.queryParameters.isNotEmpty) {
      LoggerUtil.d('查询参数: ${options.queryParameters}');
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerUtil.d('✅ 响应成功');
    LoggerUtil.d('状态码: ${response.statusCode}');
    LoggerUtil.d('响应头: ${response.headers}');
    LoggerUtil.d('响应数据: ${response.data}');
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerUtil.e('❌ 请求失败');
    LoggerUtil.e('错误类型: ${err.type}');
    LoggerUtil.e('错误消息: ${err.message}');
    
    if (err.response != null) {
      LoggerUtil.e('响应状态码: ${err.response?.statusCode}');
      LoggerUtil.e('响应数据: ${err.response?.data}');
    }
    
    super.onError(err, handler);
  }
}