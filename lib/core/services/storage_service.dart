import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../utils/logger_util.dart';

/// 本地存储服务类
class StorageService {
  // 私有构造函数，防止实例化
  StorageService._();

  static late Box _userBox;
  static late Box _cacheBox;
  static late SharedPreferences _prefs;

  /// 初始化存储服务
  static Future<void> init() async {
    try {
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // 初始化Hive boxes
      _userBox = await Hive.openBox(AppConstants.userBoxName);

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
}