import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger_util.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

/// 认证状态枚举
enum AuthStatus {
  /// 未知状态
  unknown,
  /// 已认证
  authenticated,
  /// 未认证
  unauthenticated,
  /// 认证中
  authenticating,
}

/// 认证状态类
class AuthState {
  /// 认证状态
  final AuthStatus status;
  
  /// 当前用户
  final UserModel? user;
  
  /// 错误信息
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  /// 复制并更新状态
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  /// 是否已认证
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// 是否未认证
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// 是否认证中
  bool get isAuthenticating => status == AuthStatus.authenticating;

  @override
  String toString() {
    return 'AuthState{status: $status, user: ${user?.username}, error: $error}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          error == other.error;

  @override
  int get hashCode => status.hashCode ^ user.hashCode ^ error.hashCode;
}

/// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// 检查认证状态
  Future<void> _checkAuthStatus() async {
    try {
      if (AuthService.isLoggedIn()) {
        final user = AuthService.getLocalUser();
        if (user != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
          );
          LoggerUtil.d('用户已登录: ${user.username}');
        } else {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      LoggerUtil.e('检查认证状态失败', e);
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// 登录
  Future<bool> login(String username, String password) async {
    try {
      state = state.copyWith(
        status: AuthStatus.authenticating,
        error: null,
      );

      final request = LoginRequest(
        username: username,
        password: password,
      );

      final authResponse = await AuthService.login(request);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );

      LoggerUtil.d('登录成功: ${authResponse.user.username}');
      return true;
    } catch (e) {
      LoggerUtil.e('登录失败', e);
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 注册
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      state = state.copyWith(
        status: AuthStatus.authenticating,
        error: null,
      );

      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      final authResponse = await AuthService.register(request);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );

      LoggerUtil.d('注册成功: ${authResponse.user.username}');
      return true;
    } catch (e) {
      LoggerUtil.e('注册失败', e);
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await AuthService.logout();
      
      state = const AuthState(status: AuthStatus.unauthenticated);
      
      LoggerUtil.d('退出登录成功');
    } catch (e) {
      LoggerUtil.e('退出登录失败', e);
      // 即使失败也要清除本地状态
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final user = await AuthService.getCurrentUser();
      
      state = state.copyWith(user: user);
      
      LoggerUtil.d('用户信息刷新成功: ${user.username}');
    } catch (e) {
      LoggerUtil.e('刷新用户信息失败', e);
      // 如果是认证错误，则退出登录
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        await logout();
      }
    }
  }

  /// 更新用户信息
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (!state.isAuthenticated) return false;

    try {
      final user = await AuthService.updateProfile(data);
      
      state = state.copyWith(user: user);
      
      LoggerUtil.d('用户信息更新成功: ${user.username}');
      return true;
    } catch (e) {
      LoggerUtil.e('更新用户信息失败', e);
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// 认证状态Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// 当前用户Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// 认证状态Provider
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status;
});

/// 是否已登录Provider
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});