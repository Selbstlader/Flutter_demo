import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger_util.dart';
import '../utils/error_handler.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? code;

  ApiResponse.success(this.data)
      : success = true,
        error = null,
        code = null;

  ApiResponse.error(this.error, {this.code})
      : success = false,
        data = null;
}

class ApiClient {
  static const String baseUrl = 'http://localhost:48080';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tenantIdKey = 'tenant_id';

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  String? _token;
  String? _refreshToken;
  int _tenantId = 1; // 默认租户ID

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
      // 配置validateStatus，让401状态码不抛出异常，而是正常返回响应
      validateStatus: (status) {
        return status != null && status >= 200 && status < 500;
      },
    ));
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加认证头
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        // 添加租户ID
        options.headers['tenant-id'] = _tenantId.toString();

        LoggerUtil.d('请求: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) async {
        LoggerUtil.d(
            '响应: ${response.statusCode} ${response.requestOptions.path}');

        // 处理401错误，尝试刷新token（仅在有refreshToken且不是登录/注册接口时）
        if (response.statusCode == 401 && _refreshToken != null) {
          final path = response.requestOptions.path;
          // 排除登录和注册接口，这些接口的401是正常的业务逻辑
          if (!path.contains('/auth/login') &&
              !path.contains('/auth/register')) {
            final refreshResult = await _refreshTokens();
            if (refreshResult) {
              // 重新发送原请求
              final cloneReq = await _dio.request(
                response.requestOptions.path,
                options: Options(
                  method: response.requestOptions.method,
                  headers: response.requestOptions.headers,
                ),
                data: response.requestOptions.data,
                queryParameters: response.requestOptions.queryParameters,
              );
              handler.resolve(cloneReq);
              return;
            } else {
              await clearTokens();
            }
          }
        }

        handler.next(response);
      },
      onError: (error, handler) async {
        LoggerUtil.e('请求错误: ${error.message}', error: error.error);
        handler.next(error);
      },
    ));
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
    _refreshToken = prefs.getString(refreshTokenKey);
    _tenantId = prefs.getInt(tenantIdKey) ?? 1;
  }

  Future<void> saveTokens(String token, String? refreshToken,
      {int? tenantId}) async {
    _token = token;
    _refreshToken = refreshToken;
    if (tenantId != null) {
      _tenantId = tenantId;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    if (refreshToken != null) {
      await prefs.setString(refreshTokenKey, refreshToken);
    }
    await prefs.setInt(tenantIdKey, _tenantId);
  }

  void setTenantId(int tenantId) {
    _tenantId = tenantId;
  }

  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
  }

  ApiResponse<T> _validateHeaders<T>() {
    if (_tenantId <= 0) {
      return ApiResponse.error('缺少租户标识(tenant-id)，请联系管理员', code: 400);
    }
    return ApiResponse.success(null);
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    bool skipTenantValidation = false,
  }) async {
    // 验证头部信息
    if (!skipTenantValidation) {
      final validation = _validateHeaders<T>();
      if (!validation.success) {
        return validation;
      }
    }

    try {
      final response = await _dio.get(endpoint);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
          '网络请求失败: ${ErrorHandler.handleError(e, context: 'ApiClient.get')}');
    } catch (e) {
      return ApiResponse.error(
          '网络请求失败: ${ErrorHandler.handleError(e, context: 'ApiClient.get')}');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data, {
    T Function(Map<String, dynamic>)? fromJson,
    bool skipTenantValidation = false,
  }) async {
    // 验证头部信息
    if (!skipTenantValidation) {
      final validation = _validateHeaders<T>();
      if (!validation.success) {
        return validation;
      }
    }

    try {
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
          '网络请求失败: ${ErrorHandler.handleError(e, context: 'ApiClient.post')}');
    } catch (e) {
      return ApiResponse.error(
          '网络请求失败: ${ErrorHandler.handleError(e, context: 'ApiClient.post')}');
    }
  }

  Future<ApiResponse<T>> _handleResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    final Map<String, dynamic> responseData = response.data;
    LoggerUtil.d('响应数据: ${response.statusCode} - ${responseData.toString()}');

    // 处理HTTP错误状态码（除了200和401，401也是后端正常响应）
    if (response.statusCode! < 200 ||
        (response.statusCode! >= 300 && response.statusCode != 401)) {
      final errorMsg =
          responseData['message'] ?? responseData['msg'] ?? '网络请求失败';
      return ApiResponse.error(errorMsg, code: response.statusCode);
    }

    // HTTP状态码200，按业务逻辑处理
    if (response.statusCode == 200) {
      // 适配新的后端返回格式：{success: true/false, data: xxx, message: xxx}
      if (responseData['success'] == true) {
        // 业务逻辑成功
        if (fromJson != null && responseData['data'] != null) {
          return ApiResponse.success(fromJson(responseData['data']));
        }
        return ApiResponse.success(responseData['data'] as T);
      } else {
        // 业务逻辑失败
        return ApiResponse.error(
          responseData['message'] ?? '请求失败',
          code: 0,
        );
      }
    } else if (response.statusCode == 401) {
      // 401状态码，直接返回后端提示信息
      // 适配新的后端返回格式：{success: false, message: "用户名或密码错误"}
      final errorMsg = responseData['message'] ?? '认证失败，请重新登录';
      return ApiResponse.error(errorMsg, code: 401);
    }

    // 其他情况的兜底处理
    return ApiResponse.error(
      responseData['message'] ?? '请求失败',
      code: response.statusCode,
    );
  }

  Future<bool> _refreshTokens() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/app-api/member/auth/refresh-token',
        queryParameters: {'refreshToken': _refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'tenant-id': _tenantId.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // 适配新的响应格式：{success: true, data: {...}}
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          await saveTokens(data['accessToken'], data['refreshToken']);
          return true;
        }
      }
    } on DioException catch (e) {
      LoggerUtil.e(
          '刷新token失败: ${ErrorHandler.handleError(e, context: 'ApiClient.refreshTokens')}');
    } catch (e) {
      LoggerUtil.e(
          '刷新token失败: ${ErrorHandler.handleError(e, context: 'ApiClient.refreshTokens')}');
    }
    return false;
  }

  // 流式响应支持
  Stream<String> postStream(
    String endpoint,
    Map<String, dynamic> data, {
    bool skipTenantValidation = false,
  }) async* {
    // 验证头部信息
    if (!skipTenantValidation) {
      final validation = _validateHeaders<void>();
      if (!validation.success) {
        yield 'error: ${validation.error}';
        return;
      }
    }

    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200) {
        await for (final chunk
            in response.data.stream.transform(utf8.decoder)) {
          yield chunk;
        }
      } else {
        yield 'error: 请求失败';
      }
    } on DioException catch (e) {
      yield 'error: 网络请求失败: ${ErrorHandler.handleError(e, context: 'ApiClient.postStream')}';
    } catch (e) {
      yield 'error: 网络请求失败: ${ErrorHandler.handleError(e, context: 'ApiClient.postStream')}';
    }
  }

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  int get tenantId => _tenantId;
}
