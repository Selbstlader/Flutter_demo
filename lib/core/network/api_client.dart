import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../utils/logger_util.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// API客户端封装类
class ApiClient {
  // 私有构造函数，防止实例化
  ApiClient._();

  static late Dio _dio;
  static CookieJar? _cookieJar;

  /// 初始化API客户端
  static void init() {
    // 创建Dio实例
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 初始化Cookie管理 (仅在非Web环境下)
    if (!kIsWeb) {
      final cookieJar = CookieJar();
      _cookieJar = cookieJar;
      _dio.interceptors.add(CookieManager(cookieJar));
    }

    // 添加拦截器
    _dio.interceptors.add(ErrorInterceptor());
    _dio.interceptors.add(LoggingInterceptor());

    LoggerUtil.d('API客户端初始化完成');
  }

  /// 获取Dio实例
  static Dio get dio => _dio;

  /// 获取CookieJar实例
  static CookieJar? get cookieJar => _cookieJar;

  /// GET请求
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      LoggerUtil.d('GET请求: $path');
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      LoggerUtil.e('GET请求失败: $path', e);
      rethrow;
    }
  }

  /// POST请求
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      LoggerUtil.d('POST请求: $path');
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      LoggerUtil.e('POST请求失败: $path', e);
      rethrow;
    }
  }

  /// PUT请求
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      LoggerUtil.d('PUT请求: $path');
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      LoggerUtil.e('PUT请求失败: $path', e);
      rethrow;
    }
  }

  /// DELETE请求
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      LoggerUtil.d('DELETE请求: $path');
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      LoggerUtil.e('DELETE请求失败: $path', e);
      rethrow;
    }
  }

  /// 上传文件
  static Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      LoggerUtil.d('文件上传: $path');
      final response = await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      LoggerUtil.e('文件上传失败: $path', e);
      rethrow;
    }
  }

  /// 下载文件
  static Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      LoggerUtil.d('文件下载: $urlPath -> $savePath');
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
      return response;
    } catch (e) {
      LoggerUtil.e('文件下载失败: $urlPath', e);
      rethrow;
    }
  }

  /// 清除所有Cookie
  static Future<void> clearCookies() async {
    try {
      if (!kIsWeb && _cookieJar != null) {
        await _cookieJar!.deleteAll();
        LoggerUtil.d('Cookie清除成功');
      }
    } catch (e) {
      LoggerUtil.e('Cookie清除失败', e);
    }
  }
}