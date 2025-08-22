import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/api_response.dart';
import '../../../../core/network/exceptions/api_exception.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/logger_util.dart';
import '../models/user_model.dart';

/// 登录请求模型
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

/// 注册请求模型
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? phone;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    if (phone != null) 'phone': phone,
  };
}

/// 认证响应模型
class AuthResponse {
  final UserModel user;
  final String token;
  final String? refreshToken;

  const AuthResponse({
    required this.user,
    required this.token,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
    );
  }
}

/// 认证服务
class AuthService {
  // 私有构造函数，防止实例化
  AuthService._();

  /// 登录
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      LoggerUtil.d('开始登录: ${request.username}');
      
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw ApiException.serverError(message: '登录响应数据为空');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw ApiException.businessError(
          code: apiResponse.code ?? 'LOGIN_FAILED',
          message: apiResponse.message ?? '登录失败',
          data: apiResponse.data,
        );
      }

      final authResponse = AuthResponse.fromJson(apiResponse.data!);
      
      // 保存认证信息
      await _saveAuthInfo(authResponse);
      
      LoggerUtil.d('登录成功: ${authResponse.user.username}');
      return authResponse;
    } catch (e) {
      LoggerUtil.e('登录失败', e);
      rethrow;
    }
  }

  /// 注册
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      LoggerUtil.d('开始注册: ${request.username}');
      
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw ApiException.serverError(message: '注册响应数据为空');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw ApiException.businessError(
          code: apiResponse.code ?? 'REGISTER_FAILED',
          message: apiResponse.message ?? '注册失败',
          data: apiResponse.data,
        );
      }

      final authResponse = AuthResponse.fromJson(apiResponse.data!);
      
      // 保存认证信息
      await _saveAuthInfo(authResponse);
      
      LoggerUtil.d('注册成功: ${authResponse.user.username}');
      return authResponse;
    } catch (e) {
      LoggerUtil.e('注册失败', e);
      rethrow;
    }
  }

  /// 退出登录
  static Future<void> logout() async {
    try {
      LoggerUtil.d('开始退出登录');
      
      // 调用退出登录API
      await ApiClient.post('/auth/logout');
      
      // 清除本地认证信息
      await _clearAuthInfo();
      
      LoggerUtil.d('退出登录成功');
    } catch (e) {
      LoggerUtil.e('退出登录失败', e);
      // 即使API调用失败，也要清除本地信息
      await _clearAuthInfo();
    }
  }

  /// 刷新Token
  static Future<String> refreshToken() async {
    try {
      final refreshToken = StorageService.getString('refresh_token');
      if (refreshToken == null) {
        throw ApiException.unauthorized(message: 'Refresh token不存在');
      }

      LoggerUtil.d('开始刷新Token');
      
      final response = await ApiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.data == null) {
        throw ApiException.serverError(message: '刷新Token响应数据为空');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw ApiException.businessError(
          code: apiResponse.code ?? 'REFRESH_FAILED',
          message: apiResponse.message ?? '刷新Token失败',
        );
      }

      final newToken = apiResponse.data!['token'] as String;
      
      // 保存新的Token
      await StorageService.setString(AppConstants.userTokenKey, newToken);
      
      LoggerUtil.d('Token刷新成功');
      return newToken;
    } catch (e) {
      LoggerUtil.e('Token刷新失败', e);
      rethrow;
    }
  }

  /// 获取当前用户信息
  static Future<UserModel> getCurrentUser() async {
    try {
      LoggerUtil.d('获取当前用户信息');
      
      final response = await ApiClient.get<Map<String, dynamic>>('/auth/me');

      if (response.data == null) {
        throw ApiException.serverError(message: '获取用户信息响应数据为空');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw ApiException.businessError(
          code: apiResponse.code ?? 'GET_USER_FAILED',
          message: apiResponse.message ?? '获取用户信息失败',
        );
      }

      final user = UserModel.fromJson(apiResponse.data!);
      
      // 更新本地用户信息
      await StorageService.setUserData(
        AppConstants.userInfoKey,
        user.toJson(),
      );
      
      LoggerUtil.d('获取用户信息成功: ${user.username}');
      return user;
    } catch (e) {
      LoggerUtil.e('获取用户信息失败', e);
      rethrow;
    }
  }

  /// 更新用户信息
  static Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      LoggerUtil.d('更新用户信息');
      
      final response = await ApiClient.put<Map<String, dynamic>>(
        '/auth/profile',
        data: data,
      );

      if (response.data == null) {
        throw ApiException.serverError(message: '更新用户信息响应数据为空');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw ApiException.businessError(
          code: apiResponse.code ?? 'UPDATE_PROFILE_FAILED',
          message: apiResponse.message ?? '更新用户信息失败',
        );
      }

      final user = UserModel.fromJson(apiResponse.data!);
      
      // 更新本地用户信息
      await StorageService.setUserData(
        AppConstants.userInfoKey,
        user.toJson(),
      );
      
      LoggerUtil.d('更新用户信息成功: ${user.username}');
      return user;
    } catch (e) {
      LoggerUtil.e('更新用户信息失败', e);
      rethrow;
    }
  }

  /// 检查是否已登录
  static bool isLoggedIn() {
    final token = StorageService.getString(AppConstants.userTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// 获取本地用户信息
  static UserModel? getLocalUser() {
    final userJson = StorageService.getUserData<Map<String, dynamic>>(
      AppConstants.userInfoKey,
    );
    
    if (userJson != null) {
      try {
        return UserModel.fromJson(userJson);
      } catch (e) {
        LoggerUtil.e('解析本地用户信息失败', e);
        return null;
      }
    }
    
    return null;
  }

  /// 保存认证信息
  static Future<void> _saveAuthInfo(AuthResponse authResponse) async {
    // 保存Token
    await StorageService.setString(
      AppConstants.userTokenKey,
      authResponse.token,
    );
    
    // 保存Refresh Token
    if (authResponse.refreshToken != null) {
      await StorageService.setString(
        'refresh_token',
        authResponse.refreshToken!,
      );
    }
    
    // 保存用户信息
    await StorageService.setUserData(
      AppConstants.userInfoKey,
      authResponse.user.toJson(),
    );
  }

  /// 清除认证信息
  static Future<void> _clearAuthInfo() async {
    await StorageService.remove(AppConstants.userTokenKey);
    await StorageService.remove('refresh_token');
    await StorageService.removeUserData(AppConstants.userInfoKey);
    
    // 清除所有Cookie
    await ApiClient.clearCookies();
  }
}