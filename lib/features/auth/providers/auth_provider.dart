import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/network/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> login(String mobile, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = LoginRequest(mobile: mobile, password: password);
      final response = await _authService.login(request);

      if (response.success && response.data != null) {
        final loginResponse = response.data!;
        await ApiClient().saveTokens(
          loginResponse.accessToken,
          loginResponse.refreshToken,
        );
        // 登录成功后需要获取用户详细信息
        await loadCurrentUser();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? '登录失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('登录失败: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String username, String password, String confirmPassword, String? nickname) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = RegisterRequest(
        username: username,
        password: password,
        confirmPassword: confirmPassword,
        nickname: nickname,
      );
      final response = await _authService.register(request);

      if (response.success && response.data != null) {
        final registerResponse = response.data!;
        // 注册成功后，创建用户对象
        _user = User(
          id: registerResponse.id,
          username: registerResponse.username ?? username, // 如果接口返回null，使用注册时的用户名
          nickname: registerResponse.nickname,
          createTime: registerResponse.createTime,
        );
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? '注册失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('注册失败: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _user = null;
      _setError(null);
    } catch (e) {
      _setError('退出登录失败: $e');
    }
    
    _setLoading(false);
  }

  Future<void> loadCurrentUser() async {
    if (!_authService.isLoggedIn) return;

    _setLoading(true);
    
    try {
      final response = await _authService.getCurrentUser();
      if (response.success && response.data != null) {
        _user = response.data!;
        _setError(null);
      } else {
        // 获取用户信息失败时，不自动退出登录，而是创建一个临时用户对象
        _user = User(
          id: 0,
          username: '用户',
          nickname: '用户',
          createTime: DateTime.now(),
        );
        _setError(null);
      }
    } catch (e) {
      // 获取用户信息失败时，不自动退出登录，而是创建一个临时用户对象
      _user = User(
        id: 0,
        username: '用户',
        nickname: '用户',
        createTime: DateTime.now(),
      );
      _setError(null);
    }
    
    _setLoading(false);
  }

  void clearError() {
    _setError(null);
  }
}