import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../../../core/utils/logger_util.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/storage_service.dart';
import '../domain/services/validation_service.dart';

/// 认证服务类
/// 负责处理所有认证相关的业务逻辑和HTTP请求
class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal();

  final ApiClient _apiClient = ApiClient();

  /// 用户登录
  ///
  /// 请求参数:
  /// - username: 用户名(邮箱)
  /// - password: 密码
  ///
  /// 返回: LoginResponse 或 错误信息
  Future<ApiResponse<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      LoggerUtil.d('开始用户登录请求: $username');

      final response = await _apiClient.post<LoginResponse>(
        '/auth/login',
        {
          'username': username,
          'password': password,
        },
        fromJson: (json) => LoginResponse.fromJson(json),
        skipTenantValidation: true, // 登录接口不需要租户验证
      );
      LoggerUtil.d('登录响应: ${response.success ? '成功' : '失败 - ${response.error}'}');
      if (response.success && response.data != null) {
        LoggerUtil.d('用户登录成功: ${response.data!.userId}');
        // 保存token到ApiClient
        await _apiClient.saveTokens(
          response.data!.accessToken,
          response.data!.refreshToken,
        );
      } else {
        LoggerUtil.e('用户登录失败: ${response.error}');
      }

      return response;
    } catch (e) {
      LoggerUtil.e('登录请求异常: ${ErrorHandler.handleError(e, context: 'AuthApiService.login')}');
      return ApiResponse.error('登录请求失败: ${ErrorHandler.handleError(e, context: 'AuthApiService.login')}');
    }
  }

  /// 用户注册
  ///
  /// 请求参数:
  /// - username: 用户名(邮箱)
  /// - password: 密码
  ///
  /// 返回: RegisterResponse 或 错误信息
  Future<ApiResponse<RegisterResponse>> register({
    required String username,
    required String password,
  }) async {
    try {
      LoggerUtil.d('开始用户注册请求: $username');

      final response = await _apiClient.post<RegisterResponse>(
        '/auth/register',
        {
          'username': username,
          'password': password,
        },
        fromJson: (json) => RegisterResponse.fromJson(json),
        skipTenantValidation: true, // 注册接口不需要租户验证
      );

      if (response.success) {
        LoggerUtil.d('用户注册成功: ${response.data?.id}');
      } else {
        LoggerUtil.e('用户注册失败: ${response.error}');
      }

      return response;
    } catch (e) {
      LoggerUtil.e('注册请求异常: ${ErrorHandler.handleError(e, context: 'AuthApiService.register')}');
      return ApiResponse.error('注册请求失败: ${ErrorHandler.handleError(e, context: 'AuthApiService.register')}');
    }
  }

  /// 获取用户信息
  ///
  /// 需要认证token
  /// 返回: User 或 错误信息
  Future<ApiResponse<User>> getProfile() async {
    try {
      LoggerUtil.d('开始获取用户信息请求');

      final response = await _apiClient.get<User>(
        '/auth/profile',
        fromJson: (json) => User.fromJson(json),
        skipTenantValidation: true, // 用户信息接口不需要租户验证
      );

      if (response.success) {
        LoggerUtil.d('获取用户信息成功: ${response.data?.id}');
      } else {
        LoggerUtil.e('获取用户信息失败: ${response.error}');
      }

      return response;
    } catch (e) {
      LoggerUtil.e('获取用户信息请求异常: ${ErrorHandler.handleError(e, context: 'AuthApiService.getProfile')}');
      return ApiResponse.error('获取用户信息失败: ${ErrorHandler.handleError(e, context: 'AuthApiService.getProfile')}');
    }
  }

  /// 退出登录
  /// 清除本地token
  Future<void> logout() async {
    try {
      LoggerUtil.d('用户退出登录');
      await _apiClient.clearTokens();
    } catch (e) {
      LoggerUtil.e('退出登录异常: ${ErrorHandler.handleError(e, context: 'AuthApiService.logout')}');
    }
  }

  /// 检查是否已登录
  bool get isLoggedIn => _apiClient.isLoggedIn;

  /// 获取当前token
  String? get currentToken => _apiClient.token;

  /// 用户登录（业务逻辑版本）
  Future<AuthResult<LoginResponse>> loginWithValidation(
      LoginRequest request) async {
    try {
      // 验证密码
      final passwordError =
          ValidationService.validatePassword(request.password);
      if (passwordError != null) {
        return AuthResult.error(passwordError);
      }

      // 调用API进行登录
      final apiResponse = await login(
        username: request.email,
        password: request.password,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final loginResponse = apiResponse.data!;

        // 存储用户信息到本地
        final userData = {
          'userId': loginResponse.userId,
          'email': request.email,
          'accessToken': loginResponse.accessToken,
          'refreshToken': loginResponse.refreshToken,
          // 添加用户详细信息
          if (loginResponse.user != null) ...{
            'username': loginResponse.user!.username,
            'nickname': loginResponse.user!.nickname,
            'createTime': loginResponse.user!.createTime?.toIso8601String(),
          },
        };
        await StorageService.setUserData('current_user', userData);

        return AuthResult.success(loginResponse);
      } else {
        return AuthResult.error(apiResponse.error ?? '登录失败');
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e, context: 'login');
      return AuthResult.error(errorMessage);
    }
  }

  /// 用户注册（业务逻辑版本）
  Future<AuthResult<RegisterResponse>> registerWithValidation(
      RegisterRequest request) async {
    try {
      // 验证密码
      final passwordError =
          ValidationService.validatePassword(request.password);
      if (passwordError != null) {
        return AuthResult.error(passwordError);
      }

      // 验证确认密码
      if (request.password != request.confirmPassword) {
        return AuthResult.error('两次输入的密码不一致');
      }

      // 调用API进行注册
      final apiResponse = await register(
        username: request.email,
        password: request.password,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final registerResponse = apiResponse.data!;

        // 存储注册成功的用户信息到本地
        final userData = {
          'userId': registerResponse.id,
          'username': registerResponse.username,
          'nickname': registerResponse.nickname,
          'createTime': registerResponse.createTime?.toIso8601String(),
          // 添加用户详细信息
          if (registerResponse.user != null) ...{
            'email': registerResponse.user!.email,
            'supabaseId': registerResponse.user!.supabaseId,
          },
        };
        await StorageService.setUserData('registered_user', userData);

        return AuthResult.success(registerResponse);
      } else {
        return AuthResult.error(apiResponse.error ?? '注册失败');
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e, context: 'register');
      return AuthResult.error(errorMessage);
    }
  }

  /// 获取当前用户（业务逻辑版本）
  Future<AuthResult<User>> getCurrentUserWithValidation() async {
    try {
      if (!isLoggedIn) {
        return AuthResult.error('用户未登录');
      }

      // 调用API获取用户信息
      final apiResponse = await getProfile();

      if (apiResponse.success && apiResponse.data != null) {
        return AuthResult.success(apiResponse.data!);
      } else {
        return AuthResult.error(apiResponse.error ?? '获取用户信息失败');
      }
    } catch (e) {
      return AuthResult.error(ErrorHandler.handleError(e, context: 'getCurrentUser'));
    }
  }

  /// 退出登录（业务逻辑版本）
  Future<AuthResult<void>> logoutWithCleanup() async {
    try {
      // 调用API服务退出登录
      await logout();

      // 清除本地存储的用户数据
      await StorageService.clearUserData();

      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.error(ErrorHandler.handleError(e, context: 'logout'));
    }
  }

  /// 刷新Token
  Future<AuthResult<String>> refreshToken() async {
    try {
      final currentToken = this.currentToken;
      if (currentToken != null) {
        // 返回当前的access token，刷新逻辑由ApiClient自动处理
        return AuthResult.success(currentToken);
      } else {
        return AuthResult.error('没有有效的会话');
      }
    } catch (e) {
      return AuthResult.error(ErrorHandler.handleError(e, context: 'refreshToken'));
    }
  }

  /// 检查当前用户邮箱是否已确认
  bool get isEmailConfirmed {
    // 独立后端接口暂不支持邮箱确认状态检查，默认返回true
    return true;
  }

  /// 重新发送邮箱确认邮件
  Future<AuthResult<void>> resendEmailConfirmation() async {
    try {
      // 临时返回错误，需要替换为独立后端接口调用
      return AuthResult.error('Supabase已禁用，请使用独立后端接口');
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e, context: 'resendEmailConfirmation');
      return AuthResult.error(errorMessage);
    }
  }

  /// 发送密码重置邮件
  Future<AuthResult<void>> resetPassword(String email) async {
    try {
      if (!ValidationService.isValidEmail(email)) {
        return AuthResult.error('请输入有效的邮箱地址');
      }

      // 临时返回错误，需要替换为独立后端接口调用
      return AuthResult.error('Supabase已禁用，请使用独立后端接口');
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e, context: 'resetPassword');
      return AuthResult.error(errorMessage);
    }
  }

  /// 更新用户密码
  Future<AuthResult<void>> updatePassword(String newPassword) async {
    try {
      final passwordError = ValidationService.validatePassword(newPassword);
      if (passwordError != null) {
        return AuthResult.error(passwordError);
      }

      // 临时返回错误，需要替换为独立后端接口调用
      return AuthResult.error('Supabase已禁用，请使用独立后端接口');
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e, context: 'updatePassword');
      return AuthResult.error(errorMessage);
    }
  }

  /// 更新用户信息
  Future<AuthResult<User>> updateUser({
    String? nickname,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 临时返回错误，需要替换为独立后端接口调用
      return AuthResult.error('Supabase已禁用，请使用独立后端接口');
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e, context: 'updateUser');
      return AuthResult.error(errorMessage);
    }
  }
}

// 统一的认证结果类
class AuthResult<T> {
  final bool success;
  final T? data;
  final String? error;

  AuthResult.success(this.data)
      : success = true,
        error = null;
  AuthResult.error(this.error)
      : success = false,
        data = null;
}
