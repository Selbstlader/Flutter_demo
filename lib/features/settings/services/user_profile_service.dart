import '../../../core/network/api_client.dart';
import '../../psychological_test/models/user_info.dart';
import '../../../core/utils/logger_util.dart';

/// 用户信息管理服务
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final ApiClient _apiClient = ApiClient();

  /// 获取用户信息
  Future<ApiResponse<UserInfo>> getUserProfile() async {
    try {
      LoggerUtil.info('开始获取用户信息');
      
      final response = await _apiClient.get<UserInfo>(
        '/auth/profile',
        fromJson: (json) => UserInfo.fromJson(json),
      );
      
      if (response.success && response.data != null) {
        LoggerUtil.info('获取用户信息成功');
        return response;
      } else {
        LoggerUtil.error('获取用户信息失败: ${response.error}');
        return ApiResponse.error(response.error ?? '获取用户信息失败');
      }
    } catch (e) {
      LoggerUtil.error('获取用户信息异常: $e');
      return ApiResponse.error('获取用户信息异常: $e');
    }
  }

  /// 更新用户信息
  Future<ApiResponse<UserInfo>> updateUserProfile(UserInfo userInfo) async {
    try {
      LoggerUtil.info('开始更新用户信息');
      
      // 构建请求数据，匹配API文档格式
      final requestData = {
        'age': userInfo.age,
        'gender': userInfo.gender,
        'occupation': userInfo.occupation,
        'education': userInfo.education,
        'maritalStatus': userInfo.maritalStatus,
        'livingCondition': userInfo.livingCondition,
        'graduationStatus': userInfo.graduationStatus,
        if (userInfo.email != null) 'email': userInfo.email,
        if (userInfo.phone != null) 'phone': userInfo.phone,
        if (userInfo.concerns != null) 'concerns': userInfo.concerns,
        if (userInfo.previousExperience != null) 'previousExperience': userInfo.previousExperience,
      };
      
      final response = await _apiClient.post<UserInfo>(
        '/auth/profile',
        requestData,
        fromJson: (json) => UserInfo.fromJson(json),
      );
      
      if (response.success) {
        LoggerUtil.info('更新用户信息成功');
        return response;
      } else {
        LoggerUtil.error('更新用户信息失败: ${response.error}');
        return ApiResponse.error(response.error ?? '更新用户信息失败');
      }
    } catch (e) {
      LoggerUtil.error('更新用户信息异常: $e');
      return ApiResponse.error('更新用户信息异常: $e');
    }
  }

  /// 验证用户信息完整性
  bool validateUserInfo(UserInfo userInfo) {
    return userInfo.isValid;
  }

  /// 格式化用户信息用于显示
  Map<String, String> formatUserInfoForDisplay(UserInfo userInfo) {
    return {
      '姓名': userInfo.id, // 这里可能需要根据实际情况调整
      '年龄': '${userInfo.age}岁',
      '性别': userInfo.gender,
      '职业': userInfo.occupation,
      '教育程度': userInfo.education,
      '婚姻状况': userInfo.maritalStatus,
      '居住情况': userInfo.livingCondition,
      '毕业状态': userInfo.graduationStatus,
      if (userInfo.email != null) '邮箱': userInfo.email!,
      if (userInfo.phone != null) '电话': userInfo.phone!,
      if (userInfo.concerns != null && userInfo.concerns!.isNotEmpty)
        '关注问题': userInfo.concerns!.join('、'),
      if (userInfo.previousExperience != null)
        '相关经历': userInfo.previousExperience!,
    };
  }
}