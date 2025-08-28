import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../../features/auth/services/auth_service.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  factory TokenRefreshService() => _instance;
  TokenRefreshService._internal();

  Timer? _refreshTimer;
  final AuthService _authService = AuthService();
  
  // 令牌刷新间隔（25分钟，令牌通常30分钟过期）
  static const Duration _refreshInterval = Duration(minutes: 25);

  void startTokenRefresh() {
    if (!ApiClient().isLoggedIn) return;
    
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) async {
      await _refreshToken();
    });
    
    if (kDebugMode) {
      print('Token refresh service started');
    }
  }

  void stopTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    
    if (kDebugMode) {
      print('Token refresh service stopped');
    }
  }

  Future<void> _refreshToken() async {
    try {
      if (!ApiClient().isLoggedIn) {
        stopTokenRefresh();
        return;
      }

      final response = await _authService.refreshToken();
      
      if (response.success && response.data != null) {
        final authResponse = response.data!;
        await ApiClient().saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );
        
        if (kDebugMode) {
          print('Token refreshed successfully');
        }
      } else {
        if (kDebugMode) {
          print('Token refresh failed: ${response.error}');
        }
        // 刷新失败，停止定时器
        stopTokenRefresh();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      stopTokenRefresh();
    }
  }

  void dispose() {
    stopTokenRefresh();
  }
}