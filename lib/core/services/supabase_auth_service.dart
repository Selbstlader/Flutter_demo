import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../utils/logger_util.dart';

class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  final _supabase = SupabaseService();

  /// 邮箱密码注册
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      LoggerUtil.d('用户注册成功: ${response.user?.email}');
      return response;
    } catch (e) {
      LoggerUtil.e('用户注册失败: $e');
      rethrow;
    }
  }

  /// 邮箱密码登录
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      LoggerUtil.d('用户登录成功: ${response.user?.email}');
      return response;
    } catch (e) {
      LoggerUtil.e('用户登录失败: $e');
      rethrow;
    }
  }

  /// 退出登录
  Future<void> signOut() async {
    try {
      await _supabase.client.auth.signOut();
      LoggerUtil.d('用户退出登录');
    } catch (e) {
      LoggerUtil.e('退出登录失败: $e');
      rethrow;
    }
  }

  /// 重置密码
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.client.auth.resetPasswordForEmail(email);
      LoggerUtil.d('密码重置邮件已发送: $email');
    } catch (e) {
      LoggerUtil.e('发送密码重置邮件失败: $e');
      rethrow;
    }
  }

  /// 更新用户信息
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
      LoggerUtil.d('用户信息更新成功');
      return response;
    } catch (e) {
      LoggerUtil.e('用户信息更新失败: $e');
      rethrow;
    }
  }

  /// 获取当前用户
  User? get currentUser => _supabase.currentUser;

  /// 获取当前会话
  Session? get currentSession => _supabase.client.auth.currentSession;

  /// 检查是否已认证
  bool get isAuthenticated => _supabase.isAuthenticated;

  /// 重新发送邮箱确认邮件
  Future<void> resendEmailConfirmation(String email) async {
    try {
      await _supabase.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      LoggerUtil.d('邮箱确认邮件已重新发送: $email');
    } catch (e) {
      LoggerUtil.e('重新发送邮箱确认邮件失败: $e');
      rethrow;
    }
  }
}