import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// 认证状态类
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
    );
  }
}

// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initializeAuth();
  }

  // 初始化认证状态
  Future<void> _initializeAuth() async {
    await loadCurrentUser();
  }

  // 加载当前用户
  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _authService.getCurrentUser();
      
      if (result.success && result.data != null) {
        state = state.copyWith(
          user: result.data,
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          user: null,
          isLoading: false,
          isAuthenticated: false,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        user: null,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: null,
      );
    }
  }

  // 登录
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final request = LoginRequest(email: email, password: password);
      final result = await _authService.login(request);
      
      if (result.success && result.data != null) {
        // 获取当前用户信息
        final userResult = await _authService.getCurrentUser();
        if (userResult.success && userResult.data != null) {
          state = state.copyWith(
            user: userResult.data,
            isLoading: false,
            isAuthenticated: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: userResult.error ?? '获取用户信息失败',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? '登录失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 注册
  Future<void> register(String email, String password, String confirmPassword, String? nickname) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final request = RegisterRequest(
        email: email, 
        password: password, 
        confirmPassword: confirmPassword,
        nickname: nickname,
      );
      final result = await _authService.register(request);
      
      if (result.success && result.data != null) {
        // 注册成功后获取用户信息
        final userResult = await _authService.getCurrentUser();
        if (userResult.success && userResult.data != null) {
          state = state.copyWith(
            user: userResult.data,
            isLoading: false,
            isAuthenticated: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: '注册成功，但获取用户信息失败',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? '注册失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 登出
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _authService.logout();
      
      if (result.success) {
        state = state.copyWith(
          user: null,
          isLoading: false,
          isAuthenticated: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? '登出失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 更新个人资料
  Future<void> updateProfile({String? nickname, Map<String, dynamic>? metadata}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _authService.updateUser(
        nickname: nickname,
        metadata: metadata,
      );
      
      if (result.success && result.data != null) {
        state = state.copyWith(
          user: result.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? '更新个人资料失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 修改密码
  Future<void> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _authService.updatePassword(newPassword);
      
      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? '修改密码失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 清除错误信息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Riverpod Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// 便捷的状态访问器
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).errorMessage;
});