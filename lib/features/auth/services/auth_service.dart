import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart' as app_models;
import '../utils/auth_error_handler.dart';
import '../domain/services/validation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseAuthService _supabaseAuthService = SupabaseAuthService();

  Future<AuthResult<app_models.LoginResponse>> login(app_models.LoginRequest request) async {
    try {
      // 验证邮箱格式
      if (!ValidationService.isValidEmail(request.email)) {
        return AuthResult.error('请输入有效的邮箱地址');
      }

      // 验证密码
      final passwordError = ValidationService.validatePassword(request.password);
      if (passwordError != null) {
        return AuthResult.error(passwordError);
      }

      final authResponse = await _supabaseAuthService.signInWithEmail(
        email: request.email,
        password: request.password,
      );

      if (authResponse.user != null) {
        final user = authResponse.user!;
        
        // 检查邮箱是否已确认
        if (user.emailConfirmedAt == null) {
          // 邮箱未确认，但允许登录，只是给出提示
          // 可以根据业务需求决定是否阻止登录
        }

        final loginResponse = app_models.LoginResponse(
          userId: user.id.hashCode,
          accessToken: authResponse.session?.accessToken ?? '',
          refreshToken: authResponse.session?.refreshToken ?? '',
        );

        // 存储用户信息到本地
        await StorageService.setUserData('current_user', app_models.User(
          id: user.id.hashCode,
          username: user.email ?? request.email,
          nickname: user.userMetadata?['nickname'],
          createTime: DateTime.parse(user.createdAt),
          email: user.email ?? request.email,
          supabaseId: user.id,
        ).toJson());

        return AuthResult.success(loginResponse);
      } else {
        return AuthResult.error('登录失败：用户信息为空');
      }
    } catch (e) {
      final errorMessage = AuthErrorHandler.getUserFriendlyMessage(e);
      return AuthResult.error(errorMessage);
    }
  }

  Future<AuthResult<app_models.RegisterResponse>> register(app_models.RegisterRequest request) async {
    try {
      // 验证邮箱格式
      if (!ValidationService.isValidEmail(request.email)) {
        return AuthResult.error('请输入有效的邮箱地址');
      }

      // 验证密码
      final passwordError = ValidationService.validatePassword(request.password);
      if (passwordError != null) {
        return AuthResult.error(passwordError);
      }

      // 验证确认密码
      if (request.password != request.confirmPassword) {
        return AuthResult.error('两次输入的密码不一致');
      }

      final authResponse = await _supabaseAuthService.signUpWithEmail(
        email: request.email,
        password: request.password,
        data: {
          'nickname': request.nickname,
        },
      );

      if (authResponse.user != null) {
        final user = authResponse.user!;
        final registerResponse = app_models.RegisterResponse(
          id: authResponse.user!.id.hashCode,
          username: request.email,
          nickname: request.nickname,
          createTime: DateTime.now(),
        );

        return AuthResult.success(registerResponse);
      } else {
        return AuthResult.error('注册失败：用户信息为空');
      }
    } catch (e) {
      final errorMessage = AuthErrorHandler.getUserFriendlyMessage(e);
      return AuthResult.error(errorMessage);
    }
  }

  Future<AuthResult<app_models.User>> getCurrentUser() async {
    try {
      final currentUser = _supabaseAuthService.currentUser;
      if (currentUser != null) {
        final user = app_models.User(
          id: currentUser.id.hashCode,
          username: currentUser.email ?? '',
          nickname: currentUser.userMetadata?['nickname'],
          createTime: DateTime.parse(currentUser.createdAt),
          email: currentUser.email ?? '',
          supabaseId: currentUser.id,
        );
        return AuthResult.success(user);
      } else {
        return AuthResult.error('用户未登录');
      }
    } catch (e) {
      return AuthResult.error(AuthErrorHandler.getErrorMessage(e));
    }
  }

  Future<AuthResult<void>> logout() async {
    try {
      await _supabaseAuthService.signOut();
      await StorageService.clearUserData();
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.error(AuthErrorHandler.getErrorMessage(e));
    }
  }

  bool get isLoggedIn => _supabaseAuthService.isAuthenticated;

  Future<AuthResult<String>> refreshToken() async {
    try {
      final session = _supabaseAuthService.currentSession;
      if (session != null) {
        // Supabase会自动刷新token，我们只需要返回当前的access token
        return AuthResult.success(session.accessToken);
      } else {
        return AuthResult.error('没有有效的会话');
      }
    } catch (e) {
      return AuthResult.error(AuthErrorHandler.getErrorMessage(e));
    }
  }

  /// 检查当前用户邮箱是否已确认
  bool get isEmailConfirmed {
    final user = _supabaseAuthService.currentUser;
    return user?.emailConfirmedAt != null;
  }

  /// 重新发送邮箱确认邮件
  Future<AuthResult<void>> resendEmailConfirmation() async {
    try {
      final user = _supabaseAuthService.currentUser;
      if (user?.email == null) {
        return AuthResult.error('用户未登录或邮箱信息不存在');
      }

      await _supabaseAuthService.resendEmailConfirmation(user!.email!);
      return AuthResult.success(null);
    } catch (e) {
      final errorMessage = AuthErrorHandler.getResendEmailErrorMessage(e);
      return AuthResult.error(errorMessage);
    }
  }

  /// 发送密码重置邮件
  Future<AuthResult<void>> resetPassword(String email) async {
    try {
      if (!ValidationService.isValidEmail(email)) {
        return AuthResult.error('请输入有效的邮箱地址');
      }

      await _supabaseAuthService.resetPassword(email);
      return AuthResult.success(null);
    } catch (e) {
      final errorMessage = AuthErrorHandler.getUserFriendlyMessage(e);
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

      await _supabaseAuthService.updateUser(password: newPassword);
      return AuthResult.success(null);
    } catch (e) {
      final errorMessage = AuthErrorHandler.getUserFriendlyMessage(e);
      return AuthResult.error(errorMessage);
    }
  }

  /// 更新用户信息
  Future<AuthResult<app_models.User>> updateUser({
    String? nickname,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (nickname != null) {
        updateData['nickname'] = nickname;
      }
      if (metadata != null) {
        updateData.addAll(metadata);
      }

      final response = await _supabaseAuthService.updateUser(data: updateData);
      if (response.user != null) {
        final user = app_models.User.fromSupabaseUser(response.user!);
        
        // 更新本地存储的用户信息
        await StorageService.setUserData('current_user', user.toJson());
        
        return AuthResult.success(user);
      } else {
        return AuthResult.error('更新用户信息失败');
      }
    } catch (e) {
      final errorMessage = AuthErrorHandler.getUserFriendlyMessage(e);
      return AuthResult.error(errorMessage);
    }
  }
}

// 统一的认证结果类
class AuthResult<T> {
  final bool success;
  final T? data;
  final String? error;

  AuthResult.success(this.data) : success = true, error = null;
  AuthResult.error(this.error) : success = false, data = null;
}