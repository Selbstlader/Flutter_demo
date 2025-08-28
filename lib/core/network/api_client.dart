import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  ApiClient._internal();

  String? _token;
  String? _refreshToken;
  int _tenantId = 1; // 默认租户ID

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
    _refreshToken = prefs.getString(refreshTokenKey);
    _tenantId = prefs.getInt(tenantIdKey) ?? 1;
  }

  Future<void> saveTokens(String token, String refreshToken, {int? tenantId}) async {
    _token = token;
    _refreshToken = refreshToken;
    if (tenantId != null) {
      _tenantId = tenantId;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(refreshTokenKey, refreshToken);
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

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'tenant-id': _tenantId.toString(),
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
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
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('网络请求失败: $e');
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
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('网络请求失败: $e');
    }
  }

  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // 处理400错误，特别是租户相关错误
    if (response.statusCode == 400) {
      final errorMsg = responseData['msg'] ?? '请求参数错误';
      if (errorMsg.contains('tenant') || errorMsg.contains('租户')) {
        return ApiResponse.error('租户标识错误或缺失，请检查tenant-id参数', code: 400);
      }
      return ApiResponse.error(errorMsg, code: 400);
    }

    if (response.statusCode == 401 && _refreshToken != null) {
      // Token过期，尝试刷新
      final refreshResult = await _refreshTokens();
      if (refreshResult) {
        // 重新发送原请求
        return _retryRequest<T>(response.request!, fromJson);
      } else {
        await clearTokens();
        return ApiResponse.error('登录已过期，请重新登录', code: 401);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData['code'] == 0) {
        if (fromJson != null && responseData['data'] != null) {
          return ApiResponse.success(fromJson(responseData['data']));
        }
        return ApiResponse.success(responseData['data'] as T);
      } else {
        return ApiResponse.error(
          responseData['msg'] ?? '请求失败',
          code: responseData['code'],
        );
      }
    } else {
      return ApiResponse.error(
        responseData['msg'] ?? '请求失败',
        code: responseData['code'] ?? response.statusCode,
      );
    }
  }

  Future<bool> _refreshTokens() async {
    if (_refreshToken == null) return false;

    try {
      // 刷新token时也需要包含tenant-id
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'tenant-id': _tenantId.toString(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/app-api/member/auth/refresh-token?refreshToken=$_refreshToken'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 0 && responseData['data'] != null) {
          final data = responseData['data'];
          await saveTokens(data['accessToken'], data['refreshToken']);
          return true;
        }
      }
    } catch (e) {
      print('刷新token失败: $e');
    }
    return false;
  }

  Future<ApiResponse<T>> _retryRequest<T>(
    http.BaseRequest originalRequest,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    if (originalRequest is http.Request) {
      final newRequest = http.Request(originalRequest.method, originalRequest.url);
      newRequest.headers.addAll(_headers);
      newRequest.body = originalRequest.body;
      
      final response = await http.Response.fromStream(
        await newRequest.send(),
      );
      return _handleResponse<T>(response, fromJson);
    }
    return ApiResponse.error('重试请求失败');
  }

  bool get isLoggedIn => _token != null;
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
      final request = http.Request('POST', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(_headers);
      request.body = jsonEncode(data);

      final response = await request.send();
      
      if (response.statusCode == 200) {
        await for (final chunk in response.stream.transform(utf8.decoder)) {
          yield chunk;
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        yield 'error: ${responseData['msg'] ?? '请求失败'}';
      }
    } catch (e) {
      yield 'error: 网络请求失败: $e';
    }
  }

  // bool get isLoggedIn => _token != null;
  String? get token => _token;
  int get tenantId => _tenantId;
}
