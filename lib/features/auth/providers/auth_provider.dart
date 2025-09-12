import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import '../models/user_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_model.dart' as core_models;
import '../../../core/utils/error_handler.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _authService = AuthApiService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.isLoggedIn;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 转换User到UserModel
  core_models.UserModel _convertToUserModel(User user) {
    return core_models.UserModel(
      id: user.supabaseId ?? user.id.toString(),
      email: user.email ?? '',
      name: user.nickname ?? user.username,
      avatar: null,
      createdAt: user.createTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 转换UserModel到User
  User _convertFromUserModel(core_models.UserModel userModel) {
    return User(
      id: userModel.id.hashCode,
      username: userModel.name ?? userModel.email,
      nickname: userModel.name,
      createTime: userModel.createdAt,
      email: userModel.email,
      supabaseId: userModel.id,
    );
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = LoginRequest(email: email, password: password);
      final result = await _authService.loginWithValidation(request);

      if (result.success && result.data != null) {
        await loadCurrentUser();

        // 登录成功后同步用户数据到Supabase - 已注释，改用独立后端接口
        // 更新用户信息后同步到Supabase - 已注释，改用独立后端接口
        // if (_currentUser != null) {
        //   await StorageService.syncUserDataToSupabase(_convertToUserModel(_currentUser!));
        // }

        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? '登录失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('登录失败: ${ErrorHandler.handleError(e, context: 'login')}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String confirmPassword,
      {String? nickname}) async {
    _setLoading(true);
    _setError(null);

    // 验证密码确认
    if (password != confirmPassword) {
      _setError('密码确认不匹配');
      _setLoading(false);
      return false;
    }

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        nickname: nickname,
      );
      final result = await _authService.registerWithValidation(request);

      if (result.success && result.data != null) {
        // 注册成功后获取用户信息并同步到Supabase - 已注释，改用独立后端接口
        await loadCurrentUser();
        // if (_currentUser != null) {
        //   await StorageService.syncUserDataToSupabase(_convertToUserModel(_currentUser!));
        // }

        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? '注册失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('注册失败: ${ErrorHandler.handleError(e, context: 'register')}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.logoutWithCleanup();
      if (result.success) {
        _currentUser = null;
        // 登出时清空本地用户数据
        await StorageService.clearUserData();
      } else {
        _setError(result.error ?? '登出失败');
      }
      _setLoading(false);
    } catch (e) {
      _setError('登出失败: ${ErrorHandler.handleError(e, context: 'logout')}');
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    if (!_authService.isLoggedIn) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      final result = await _authService.getCurrentUserWithValidation();
      if (result.success && result.data != null) {
        _currentUser = result.data;

        // 尝试从Supabase获取最新的用户数据
        if (_currentUser?.supabaseId != null) {
          final cloudUserModel =
              await StorageService.getSmartUserData(_currentUser!.supabaseId!);
          if (cloudUserModel != null) {
            _currentUser = _convertFromUserModel(cloudUserModel);
          }
        }
      } else {
        // 如果无法从服务获取，尝试从本地缓存获取
        final cachedUserModel = StorageService.getCachedUserData();
        if (cachedUserModel != null) {
          _currentUser = _convertFromUserModel(cachedUserModel);
        } else if (result.error != null) {
          _setError(result.error);
        }
      }
    } catch (e) {
      // 发生异常时，尝试从本地缓存获取用户数据
      final cachedUserModel = StorageService.getCachedUserData();
      if (cachedUserModel != null) {
        _currentUser = _convertFromUserModel(cachedUserModel);
      } else {
        _setError('获取用户信息失败: ${ErrorHandler.handleError(e, context: 'loadCurrentUser')}');
      }
    }
    notifyListeners();
  }

  // 初始化方法，在应用启动时调用
  Future<void> initialize() async {
    _setLoading(true);
    await loadCurrentUser();
    _setLoading(false);
  }

  // 检查认证状态
  Future<bool> checkAuthStatus() async {
    try {
      if (_authService.isLoggedIn) {
        await loadCurrentUser();
        return _currentUser != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 重新发送邮箱确认邮件
  Future<bool> resendEmailConfirmation() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.resendEmailConfirmation();
      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? '发送确认邮件失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('发送确认邮件失败: ${ErrorHandler.handleError(e, context: 'resendEmailConfirmation')}');
      _setLoading(false);
      return false;
    }
  }

  // 重置密码
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.resetPassword(email);
      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? '发送重置密码邮件失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('发送重置密码邮件失败: ${ErrorHandler.handleError(e, context: 'resetPassword')}');
      _setLoading(false);
      return false;
    }
  }

  // 更新密码
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.updatePassword(newPassword);
      if (result.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? '更新密码失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('更新密码失败: ${ErrorHandler.handleError(e, context: 'updatePassword')}');
      _setLoading(false);
      return false;
    }
  }

  // 更新用户信息
  Future<bool> updateUser(
      {String? nickname, Map<String, dynamic>? metadata}) async {
    _setLoading(true);
    _setError(null);

    try {
      final result =
          await _authService.updateUser(nickname: nickname, metadata: metadata);
      if (result.success && result.data != null) {
        _currentUser = result.data;

        // 注册成功后同步用户数据到Supabase - 已注释，改用独立后端接口
        // if (_currentUser != null) {
        //   await StorageService.syncUserDataToSupabase(_convertToUserModel(_currentUser!));
        // }

        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? '更新用户信息失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('更新用户信息失败: ${ErrorHandler.handleError(e, context: 'updateUser')}');
      _setLoading(false);
      return false;
    }
  }

  // 刷新令牌
  Future<bool> refreshToken() async {
    try {
      final result = await _authService.refreshToken();
      if (result.success) {
        await loadCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 检查邮箱是否已确认
  bool get isEmailConfirmed {
    return _authService.isEmailConfirmed;
  }
}
