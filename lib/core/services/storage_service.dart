import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../utils/logger_util.dart';
import '../models/user_model.dart';
import '../models/social_security_model.dart';
import 'supabase_service.dart';
import 'supabase_data_service.dart';
import 'supabase_auth_service.dart';

/// 本地存储服务类
class StorageService {
  // 私有构造函数，防止实例化
  StorageService._();

  static late Box _userBox;
  static late Box _settingsBox;
  static late Box _cacheBox;
  static late SharedPreferences _prefs;

  /// 初始化存储服务
  static Future<void> init() async {
    try {
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // 初始化Hive boxes
      _userBox = await Hive.openBox(AppConstants.userBoxName);
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
      _cacheBox = await Hive.openBox(AppConstants.cacheBoxName);
      
      LoggerUtil.d('存储服务初始化完成');
    } catch (e) {
      LoggerUtil.e('存储服务初始化失败: $e');
      rethrow;
    }
  }

  // ==================== SharedPreferences 操作 ====================
  
  /// 保存字符串
  static Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      LoggerUtil.d('保存字符串: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('保存字符串失败: $e');
      return false;
    }
  }

  /// 获取字符串
  static String? getString(String key) {
    try {
      final value = _prefs.getString(key);
      LoggerUtil.d('获取字符串: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取字符串失败: $e');
      return null;
    }
  }

  /// 保存整数
  static Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      LoggerUtil.d('保存整数: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('保存整数失败: $e');
      return false;
    }
  }

  /// 获取整数
  static int? getInt(String key) {
    try {
      final value = _prefs.getInt(key);
      LoggerUtil.d('获取整数: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取整数失败: $e');
      return null;
    }
  }

  /// 保存布尔值
  static Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      LoggerUtil.d('保存布尔值: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('保存布尔值失败: $e');
      return false;
    }
  }

  /// 获取布尔值
  static bool? getBool(String key) {
    try {
      final value = _prefs.getBool(key);
      LoggerUtil.d('获取布尔值: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取布尔值失败: $e');
      return null;
    }
  }

  /// 删除键值
  static Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      LoggerUtil.d('删除键值: $key');
      return result;
    } catch (e) {
      LoggerUtil.e('删除键值失败: $e');
      return false;
    }
  }

  // ==================== Hive 操作 ====================

  /// 保存用户数据
  static Future<void> setUserData(String key, dynamic value) async {
    try {
      await _userBox.put(key, value);
      LoggerUtil.d('保存用户数据: $key');
    } catch (e) {
      LoggerUtil.e('保存用户数据失败: $e');
    }
  }

  /// 获取用户数据
  static T? getUserData<T>(String key) {
    try {
      final value = _userBox.get(key) as T?;
      LoggerUtil.d('获取用户数据: $key');
      return value;
    } catch (e) {
      LoggerUtil.e('获取用户数据失败: $e');
      return null;
    }
  }

  /// 删除用户数据
  static Future<void> removeUserData(String key) async {
    try {
      await _userBox.delete(key);
      LoggerUtil.d('删除用户数据: $key');
    } catch (e) {
      LoggerUtil.e('删除用户数据失败: $e');
    }
  }

  /// 清空用户数据
  static Future<void> clearUserData() async {
    try {
      await _userBox.clear();
      LoggerUtil.d('清空用户数据');
    } catch (e) {
      LoggerUtil.e('清空用户数据失败: $e');
    }
  }

  /// 保存设置数据
  static Future<void> setSettingsData(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
      LoggerUtil.d('保存设置数据: $key');
    } catch (e) {
      LoggerUtil.e('保存设置数据失败: $e');
    }
  }

  /// 获取设置数据
  static T? getSettingsData<T>(String key) {
    try {
      final value = _settingsBox.get(key) as T?;
      LoggerUtil.d('获取设置数据: $key');
      return value;
    } catch (e) {
      LoggerUtil.e('获取设置数据失败: $e');
      return null;
    }
  }

  /// 保存缓存数据
  static Future<void> setCacheData(String key, dynamic value) async {
    try {
      await _cacheBox.put(key, value);
      LoggerUtil.d('保存缓存数据: $key');
    } catch (e) {
      LoggerUtil.e('保存缓存数据失败: $e');
    }
  }

  /// 获取缓存数据
  static T? getCacheData<T>(String key) {
    try {
      final value = _cacheBox.get(key) as T?;
      LoggerUtil.d('获取缓存数据: $key');
      return value;
    } catch (e) {
      LoggerUtil.e('获取缓存数据失败: $e');
      return null;
    }
  }

  /// 清空缓存数据
  static Future<void> clearCacheData() async {
    try {
      await _cacheBox.clear();
      LoggerUtil.d('清空缓存数据');
    } catch (e) {
      LoggerUtil.e('清空缓存数据失败: $e');
    }
  }

  // ==================== Supabase 同步功能 ====================

  /// 同步用户数据到Supabase
  static Future<bool> syncUserDataToSupabase(UserModel user) async {
    try {
      final dataService = SupabaseDataService();
      await dataService.insert(table: 'users', data: user.toJson());
      
      // 同时保存到本地
      await setUserData('current_user', user.toJson());
      
      LoggerUtil.d('用户数据同步到Supabase成功');
      return true;
    } catch (e) {
      LoggerUtil.e('用户数据同步到Supabase失败: $e');
      return false;
    }
  }

  /// 从Supabase获取用户数据
  static Future<UserModel?> getUserDataFromSupabase(String userId) async {
    try {
      final dataService = SupabaseDataService();
      final data = await dataService.select(table: 'users', where: 'id', whereValue: userId);
      
      if (data.isNotEmpty) {
        final user = UserModel.fromJson(data.first);
        
        // 同时保存到本地
        await setUserData('current_user', user.toJson());
        
        LoggerUtil.d('从Supabase获取用户数据成功');
        return user;
      }
      return null;
    } catch (e) {
      LoggerUtil.e('从Supabase获取用户数据失败: $e');
      return null;
    }
  }

  /// 同步社保数据到Supabase
  static Future<bool> syncSocialSecurityToSupabase(SocialSecurityModel socialSecurity) async {
    try {
      final dataService = SupabaseDataService();
      await dataService.insert(table: 'social_security', data: socialSecurity.toJson());
      
      // 同时保存到本地缓存
      await setCacheData('social_security_${socialSecurity.id}', socialSecurity.toJson());
      
      LoggerUtil.d('社保数据同步到Supabase成功');
      return true;
    } catch (e) {
      LoggerUtil.e('社保数据同步到Supabase失败: $e');
      return false;
    }
  }

  /// 从Supabase获取社保数据
  static Future<List<SocialSecurityModel>> getSocialSecurityFromSupabase(String userId) async {
    try {
      final dataService = SupabaseDataService();
      final data = await dataService.select(table: 'social_security', where: 'user_id', whereValue: userId);
      
      final socialSecurityList = data.map((item) => SocialSecurityModel.fromJson(item)).toList();
      
      // 同时保存到本地缓存
      for (final item in socialSecurityList) {
        await setCacheData('social_security_${item.id}', item.toJson());
      }
      
      LoggerUtil.d('从Supabase获取社保数据成功，共${socialSecurityList.length}条');
      return socialSecurityList;
    } catch (e) {
      LoggerUtil.e('从Supabase获取社保数据失败: $e');
      return [];
    }
  }

  /// 离线模式：获取本地缓存的用户数据
  static UserModel? getCachedUserData() {
    try {
      final userData = getUserData<Map<String, dynamic>>('current_user');
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      LoggerUtil.e('获取本地用户数据失败: $e');
      return null;
    }
  }

  /// 离线模式：获取本地缓存的社保数据
  static List<SocialSecurityModel> getCachedSocialSecurityData() {
    try {
      final List<SocialSecurityModel> socialSecurityList = [];
      
      // 遍历缓存box查找社保数据
      for (final key in _cacheBox.keys) {
        if (key.toString().startsWith('social_security_')) {
          final data = getCacheData<Map<String, dynamic>>(key);
          if (data != null) {
            socialSecurityList.add(SocialSecurityModel.fromJson(data));
          }
        }
      }
      
      LoggerUtil.d('获取本地社保数据成功，共${socialSecurityList.length}条');
      return socialSecurityList;
    } catch (e) {
      LoggerUtil.e('获取本地社保数据失败: $e');
      return [];
    }
  }

  /// 检查网络连接并决定数据源
  static Future<bool> isOnline() async {
    try {
      final authService = SupabaseAuthService();
      return authService.isAuthenticated;
    } catch (e) {
      LoggerUtil.e('检查网络连接失败: $e');
      return false;
    }
  }

  /// 智能数据获取：优先从Supabase获取，失败时使用本地缓存
  static Future<UserModel?> getSmartUserData(String userId) async {
    if (await isOnline()) {
      final onlineData = await getUserDataFromSupabase(userId);
      if (onlineData != null) {
        return onlineData;
      }
    }
    
    // 网络不可用或获取失败时，使用本地缓存
    return getCachedUserData();
  }

  /// 智能数据获取：优先从Supabase获取，失败时使用本地缓存
  static Future<List<SocialSecurityModel>> getSmartSocialSecurityData(String userId) async {
    if (await isOnline()) {
      final onlineData = await getSocialSecurityFromSupabase(userId);
      if (onlineData.isNotEmpty) {
        return onlineData;
      }
    }
    
    // 网络不可用或获取失败时，使用本地缓存
    return getCachedSocialSecurityData();
  }
}