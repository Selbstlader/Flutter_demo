import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';
import '../../services/storage_service.dart';
import '../../utils/logger_util.dart';

/// 认证拦截器
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 获取存储的token
    final token = StorageService.getString(AppConstants.userTokenKey);
    
    if (token != null && token.isNotEmpty) {
      // 添加Authorization头
      options.headers['Authorization'] = 'Bearer $token';
      LoggerUtil.d('添加认证头: Bearer $token');
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查响应中是否包含新的token
    final newToken = response.headers.value('authorization') ?? 
                     response.headers.value('Authorization');
    
    if (newToken != null && newToken.isNotEmpty) {
      // 更新存储的token
      StorageService.setString(AppConstants.userTokenKey, newToken);
      LoggerUtil.d('更新认证token: $newToken');
    }
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 处理认证错误
    if (err.response?.statusCode == 401) {
      LoggerUtil.w('认证失败，清除token');
      // 清除无效的token
      StorageService.remove(AppConstants.userTokenKey);
      // 这里可以触发重新登录逻辑
      _handleAuthError();
    }
    
    super.onError(err, handler);
  }

  /// 处理认证错误
  void _handleAuthError() {
    // 可以在这里发送事件通知应用重新登录
    // 例如使用EventBus或者其他状态管理方案
    LoggerUtil.w('用户认证失效，需要重新登录');
  }
}