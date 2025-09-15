import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../psychological_test/models/user_info.dart';
import '../services/user_profile_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger_util.dart';
import '../../auth/services/auth_api_service.dart';

/// 用户信息状态类
class UserProfileState {
  final UserInfo? userInfo;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final bool hasChanges;

  const UserProfileState({
    this.userInfo,
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.hasChanges = false,
  });

  UserProfileState copyWith({
    UserInfo? userInfo,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    bool? hasChanges,
  }) {
    return UserProfileState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  /// 清除错误信息
  UserProfileState clearError() {
    return copyWith(errorMessage: null);
  }
}

/// 用户信息状态管理器
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileService _userProfileService;
  final StorageService _storageService;
  final AuthApiService _authService;

  UserProfileNotifier(this._userProfileService, this._storageService, this._authService)
      : super(const UserProfileState()) {
    _loadUserProfile();
  }

  /// 加载用户信息
  Future<void> _loadUserProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // 首先尝试从本地存储加载
      final localUserInfo = await _loadFromLocalStorage();
      if (localUserInfo != null) {
        state = state.copyWith(
          userInfo: localUserInfo,
          isLoading: false,
        );
        LoggerUtil.info('从本地存储加载用户信息成功');
      }
      
      // 然后尝试从服务器获取最新数据
      await refreshFromServer();
    } catch (e) {
      LoggerUtil.error('加载用户信息失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载用户信息失败: $e',
      );
    }
  }

  /// 从本地存储加载用户信息
  Future<UserInfo?> _loadFromLocalStorage() async {
    try {
      // 尝试从SharedPreferences获取用户信息
      final userInfoJson = _storageService.getString(StorageService.USER_INFO_KEY);
      if (userInfoJson != null) {
        final Map<String, dynamic> userInfoMap = json.decode(userInfoJson);
        return UserInfo.fromJson(userInfoMap);
      }
    } catch (e) {
      LoggerUtil.error('从本地存储加载用户信息失败: $e');
    }
    return null;
  }

  /// 从服务器刷新用户信息
  Future<void> refreshFromServer() async {
    // 检查登录状态
    if (!_authService.isLoggedIn) {
      LoggerUtil.info('用户未登录，跳过服务器数据获取');
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final response = await _userProfileService.getUserProfile();
      if (response.success && response.data != null) {
        state = state.copyWith(
          userInfo: response.data,
          isLoading: false,
          errorMessage: null,
        );
        
        // 同步到本地存储
        await _storageService.saveUserInfo(response.data!);
        LoggerUtil.info('从服务器刷新用户信息成功');
      } else {
        // 如果服务器获取失败，但本地有数据，则保持本地数据
        if (state.userInfo == null) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.error ?? '获取用户信息失败',
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      LoggerUtil.error('从服务器刷新用户信息失败: $e');
      // 如果本地没有数据，则显示错误
      if (state.userInfo == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '网络连接失败，请检查网络设置',
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// 更新用户信息
  Future<bool> updateUserInfo(UserInfo userInfo) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // 先保存到本地存储（SharedPreferences）
      await _storageService.setString(
        StorageService.USER_INFO_KEY, 
        json.encode(userInfo.toJson())
      );
      
      // 同时保存到Hive（如果需要）
      await _storageService.saveUserInfo(userInfo);
      
      // 更新本地状态
      state = state.copyWith(
        userInfo: userInfo,
        hasChanges: false,
      );
      
      // 检查登录状态，决定是否同步到服务器
      if (_authService.isLoggedIn) {
        // 已登录，尝试同步到服务器
        final response = await _userProfileService.updateUserProfile(userInfo);
        if (response.success) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: null,
          );
          LoggerUtil.info('用户信息更新并同步到服务器成功');
          return true;
        } else {
          // 服务器更新失败，但本地已保存
          state = state.copyWith(
            isLoading: false,
            errorMessage: '服务器同步失败，数据已保存到本地: ${response.error}',
          );
          return true; // 本地保存成功就算成功
        }
      } else {
        // 未登录，仅保存到本地
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        LoggerUtil.info('用户信息已保存到本地（未登录状态）');
        return true;
      }
    } catch (e) {
      LoggerUtil.error('更新用户信息失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '更新用户信息失败: $e',
      );
      return false;
    }
  }

  /// 开始编辑模式
  void startEditing() {
    state = state.copyWith(isEditing: true);
  }

  /// 取消编辑模式
  void cancelEditing() {
    state = state.copyWith(isEditing: false, hasChanges: false);
  }

  /// 标记有变更
  void markAsChanged() {
    state = state.copyWith(hasChanges: true);
  }

  /// 清除错误信息
  void clearError() {
    state = state.clearError();
  }

  /// 重新加载用户信息
  Future<void> reload() async {
    await _loadUserProfile();
  }
}

// Riverpod Providers
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final userProfileService = ref.watch(userProfileServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final authService = ref.watch(authApiServiceProvider);
  return UserProfileNotifier(userProfileService, storageService, authService);
});

// 便捷的状态访问器
final currentUserInfoProvider = Provider<UserInfo?>((ref) {
  return ref.watch(userProfileNotifierProvider).userInfo;
});

final isUserProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileNotifierProvider).isLoading;
});

final isUserProfileEditingProvider = Provider<bool>((ref) {
  return ref.watch(userProfileNotifierProvider).isEditing;
});

final userProfileErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProfileNotifierProvider).errorMessage;
});

final hasUserProfileChangesProvider = Provider<bool>((ref) {
  return ref.watch(userProfileNotifierProvider).hasChanges;
});