import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return _handleAuthException(error);
    } else if (error is PostgrestException) {
      return _handlePostgrestException(error);
    } else if (error is String) {
      return error;
    } else {
      return '发生未知错误，请稍后重试';
    }
  }

  /// 获取用户友好的错误提示
  static String getUserFriendlyMessage(dynamic error) {
    final message = getErrorMessage(error);
    
    // 为常见错误提供更友好的提示
    if (message.contains('邮箱或密码错误')) {
      return '登录失败，请检查您的邮箱和密码是否正确';
    }
    
    if (message.contains('邮箱未验证')) {
      return '请先验证您的邮箱地址，查看邮箱中的验证链接';
    }
    
    if (message.contains('该邮箱已被注册')) {
      return '该邮箱已被注册，请使用其他邮箱或尝试登录';
    }
    
    if (message.contains('网络连接失败')) {
      return '网络连接失败，请检查网络设置';
    }
    
    return message;
  }

  static String _handleAuthException(AuthException error) {
    final message = error.message.toLowerCase();
    
    // 登录相关错误
    if (message.contains('invalid login credentials') || 
        message.contains('invalid_credentials')) {
      return '邮箱或密码错误';
    }
    
    // 邮箱验证相关错误
    if (message.contains('email not confirmed') || 
        message.contains('email_not_confirmed')) {
      return '邮箱未验证，请检查您的邮箱';
    }
    
    if (message.contains('confirmation_token_invalid') || 
        message.contains('invalid confirmation token')) {
      return '邮箱验证链接无效或已过期';
    }
    
    if (message.contains('email_change_token_invalid') || 
        message.contains('invalid email change token')) {
      return '邮箱更改验证链接无效或已过期';
    }
    
    // 注册相关错误
    if (message.contains('user already registered') || 
        message.contains('email already registered') ||
        message.contains('user_already_exists')) {
      return '该邮箱已被注册';
    }
    
    if (message.contains('signup disabled') || 
        message.contains('signup_disabled')) {
      return '注册功能已禁用';
    }
    
    // 密码相关错误
    if (message.contains('weak password') || 
        message.contains('password_too_weak')) {
      return '密码强度不够，请使用更复杂的密码';
    }
    
    if (message.contains('password too short') || 
        message.contains('password_too_short')) {
      return '密码长度不能少于6位';
    }
    
    // 邮箱格式错误
    if (message.contains('invalid email') || 
        message.contains('invalid_email')) {
      return '邮箱格式不正确';
    }
    
    // 用户相关错误
    if (message.contains('user not found') || 
        message.contains('user_not_found')) {
      return '用户不存在';
    }
    
    // 会话相关错误
    if (message.contains('session not found') || 
        message.contains('session_not_found')) {
      return '会话已过期，请重新登录';
    }
    
    if (message.contains('refresh token not found') || 
        message.contains('refresh_token_not_found')) {
      return '登录状态已失效，请重新登录';
    }
    
    if (message.contains('invalid refresh token') || 
        message.contains('invalid_refresh_token')) {
      return '登录状态无效，请重新登录';
    }
    
    // 网络相关错误
    if (message.contains('network error') || 
        message.contains('network_error')) {
      return '网络连接失败，请检查网络设置';
    }
    
    if (message.contains('timeout') || 
        message.contains('request_timeout')) {
      return '请求超时，请稍后重试';
    }
    
    // 频率限制错误
    if (message.contains('too many requests') || 
        message.contains('rate_limit_exceeded')) {
      return '请求过于频繁，请稍后重试';
    }
    
    // 邮箱发送相关错误
    if (message.contains('email delivery failed') || 
        message.contains('email_delivery_failed')) {
      return '邮件发送失败，请检查邮箱地址是否正确';
    }
    
    if (message.contains('email rate limit exceeded') || 
        message.contains('email_rate_limit_exceeded')) {
      return '邮件发送过于频繁，请稍后重试';
    }
    
    // 默认处理
    return error.message.isNotEmpty ? error.message : '认证失败，请稍后重试';
  }

  static String _handlePostgrestException(PostgrestException error) {
    switch (error.code) {
      case '23505': // unique_violation
        return '该用户已存在';
      case '23503': // foreign_key_violation
        return '数据关联错误';
      case '23502': // not_null_violation
        return '必填字段不能为空';
      case '42501': // insufficient_privilege
        return '权限不足';
      default:
        return error.message.isNotEmpty ? error.message : '数据库操作失败';
    }
  }

  /// 添加重发邮件验证的错误处理
  static String getResendEmailErrorMessage(dynamic error) {
    final message = getErrorMessage(error);
    
    if (message.contains('email_rate_limit_exceeded') || 
        message.contains('邮件发送过于频繁')) {
      return '验证邮件发送过于频繁，请等待60秒后重试';
    }
    
    if (message.contains('email_delivery_failed') || 
        message.contains('邮件发送失败')) {
      return '验证邮件发送失败，请检查邮箱地址或稍后重试';
    }
    
    return message;
  }
  
  /// 检查是否为需要邮箱验证的错误
  static bool isEmailVerificationRequired(dynamic error) {
    final message = getErrorMessage(error).toLowerCase();
    return message.contains('email not confirmed') || 
           message.contains('邮箱未验证') ||
           message.contains('email_not_confirmed');
  }
  
  /// 检查是否为邮箱已注册的错误
  static bool isEmailAlreadyRegistered(dynamic error) {
    final message = getErrorMessage(error).toLowerCase();
    return message.contains('user already registered') || 
           message.contains('email already registered') ||
           message.contains('该邮箱已被注册') ||
           message.contains('user_already_exists');
  }
}