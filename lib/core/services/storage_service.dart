import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/logger_util.dart';

/// 本地存储服务
/// 提供SharedPreferences和Hive的统一存储接口
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  SharedPreferences? _prefs;
  Box? _userInfoBox;
  Box? _testSessionsBox;
  Box? _cacheBox;

  // SharedPreferences 键值定义
  static const String USER_INFO_KEY = 'user_info';
  static const String TEST_SESSIONS_KEY = 'test_sessions';
  static const String CURRENT_SESSION_KEY = 'current_session';
  static const String PRIVACY_CONSENT_KEY = 'privacy_consent';
  static const String SETTINGS_KEY = 'app_settings';

  // Hive Box 名称
  static const String USER_INFO_BOX = 'user_info_box';
  static const String TEST_SESSIONS_BOX = 'test_sessions_box';
  static const String CACHE_BOX = 'cache_box';

  /// 初始化存储服务
  Future<void> initialize() async {
    try {
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // 初始化Hive
      await Hive.initFlutter();

      // 打开Hive boxes
      _userInfoBox = await Hive.openBox(USER_INFO_BOX);
      _testSessionsBox = await Hive.openBox(TEST_SESSIONS_BOX);
      _cacheBox = await Hive.openBox(CACHE_BOX);

      LoggerUtil.info('StorageService initialized successfully');
    } catch (e) {
      LoggerUtil.error('Failed to initialize StorageService: $e');
      rethrow;
    }
  }

  /// 检查是否已初始化
  bool get isInitialized => _prefs != null && _userInfoBox != null;

  // ==================== SharedPreferences 方法 ====================

  /// 保存字符串值
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs?.setString(key, value) ?? false;
    } catch (e) {
      LoggerUtil.error('Failed to set string for key $key: $e');
      return false;
    }
  }

  /// 获取字符串值
  String? getString(String key) {
    try {
      return _prefs?.getString(key);
    } catch (e) {
      LoggerUtil.error('Failed to get string for key $key: $e');
      return null;
    }
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs?.setBool(key, value) ?? false;
    } catch (e) {
      LoggerUtil.error('Failed to set bool for key $key: $e');
      return false;
    }
  }

  /// 获取布尔值
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _prefs?.getBool(key) ?? defaultValue;
    } catch (e) {
      LoggerUtil.error('Failed to get bool for key $key: $e');
      return defaultValue;
    }
  }

  /// 保存整数值
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs?.setInt(key, value) ?? false;
    } catch (e) {
      LoggerUtil.error('Failed to set int for key $key: $e');
      return false;
    }
  }

  /// 获取整数值
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _prefs?.getInt(key) ?? defaultValue;
    } catch (e) {
      LoggerUtil.error('Failed to get int for key $key: $e');
      return defaultValue;
    }
  }

  /// 保存JSON对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      LoggerUtil.error('Failed to set JSON for key $key: $e');
      return false;
    }
  }

  /// 获取JSON对象
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      LoggerUtil.error('Failed to get JSON for key $key: $e');
      return null;
    }
  }

  /// 删除键值
  Future<bool> remove(String key) async {
    try {
      return await _prefs?.remove(key) ?? false;
    } catch (e) {
      LoggerUtil.error('Failed to remove key $key: $e');
      return false;
    }
  }

  /// 清除所有数据
  Future<bool> clear() async {
    try {
      return await _prefs?.clear() ?? false;
    } catch (e) {
      LoggerUtil.error('Failed to clear SharedPreferences: $e');
      return false;
    }
  }

  // ==================== Hive 方法 ====================

  /// 保存用户信息到Hive
  Future<void> saveUserInfoToHive(String key, dynamic userInfo) async {
    try {
      await _userInfoBox?.put(key, userInfo);
      LoggerUtil.info('User info saved to Hive with key: $key');
    } catch (e) {
      LoggerUtil.error('Failed to save user info to Hive: $e');
      rethrow;
    }
  }

  /// 从Hive获取用户信息
  dynamic getUserInfoFromHive(String key) {
    try {
      return _userInfoBox?.get(key);
    } catch (e) {
      LoggerUtil.error('Failed to get user info from Hive: $e');
      return null;
    }
  }

  /// 保存测试会话到Hive
  Future<void> saveTestSessionToHive(String key, dynamic session) async {
    try {
      await _testSessionsBox?.put(key, session);
      LoggerUtil.info('Test session saved to Hive with key: $key');
    } catch (e) {
      LoggerUtil.error('Failed to save test session to Hive: $e');
      rethrow;
    }
  }

  /// 从Hive获取测试会话
  dynamic getTestSessionFromHive(String key) {
    try {
      return _testSessionsBox?.get(key);
    } catch (e) {
      LoggerUtil.error('Failed to get test session from Hive: $e');
      return null;
    }
  }

  /// 保存缓存数据
  Future<void> saveCache(String key, dynamic data) async {
    try {
      await _cacheBox?.put(key, data);
    } catch (e) {
      LoggerUtil.error('Failed to save cache: $e');
      rethrow;
    }
  }

  /// 获取缓存数据
  T? getCache<T>(String key) {
    try {
      return _cacheBox?.get(key) as T?;
    } catch (e) {
      LoggerUtil.error('Failed to get cache: $e');
      return null;
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      await _cacheBox?.clear();
      LoggerUtil.info('Cache cleared');
    } catch (e) {
      LoggerUtil.error('Failed to clear cache: $e');
      rethrow;
    }
  }

  // ==================== 便捷方法 ====================

  /// 保存隐私同意状态
  Future<bool> setPrivacyConsent(bool consent) async {
    return await setBool(PRIVACY_CONSENT_KEY, consent);
  }

  /// 获取隐私同意状态
  bool getPrivacyConsent() {
    return getBool(PRIVACY_CONSENT_KEY);
  }

  /// 保存应用设置
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    return await setJson(SETTINGS_KEY, settings);
  }

  /// 获取应用设置
  Map<String, dynamic>? getAppSettings() {
    return getJson(SETTINGS_KEY);
  }

  /// 销毁存储服务
  Future<void> dispose() async {
    try {
      await _userInfoBox?.close();
      await _testSessionsBox?.close();
      await _cacheBox?.close();
      LoggerUtil.info('StorageService disposed');
    } catch (e) {
      LoggerUtil.error('Failed to dispose StorageService: $e');
    }
  }

  // 便捷方法
  Future<void> clearAll() async {
    await _prefs?.clear();
    await Hive.deleteFromDisk();
  }

  Future<bool> hasKey(String key) async {
    return _prefs?.containsKey(key) ?? false;
  }

  // 心理测试相关方法
  Future<void> saveUserInfo(dynamic userInfo) async {
    try {
      // 确保使用已初始化的box或重新打开
      Box userInfoBox;
      if (_userInfoBox != null && _userInfoBox!.isOpen) {
        userInfoBox = _userInfoBox!;
      } else {
        userInfoBox = await Hive.openBox('user_info');
      }

      // 直接存储对象，不需要转换为JSON
      await userInfoBox.put(userInfo.id, userInfo);
      LoggerUtil.info('User info saved successfully with id: ${userInfo.id}');
    } catch (e) {
      LoggerUtil.error('Failed to save user info: $e');
      rethrow;
    }
  }

  Future<dynamic> getUserInfo(String id) async {
    try {
      // 确保使用已初始化的box或重新打开
      Box userInfoBox;
      if (_userInfoBox != null && _userInfoBox!.isOpen) {
        userInfoBox = _userInfoBox!;
      } else {
        userInfoBox = await Hive.openBox('user_info');
      }

      final data = userInfoBox.get(id);
      LoggerUtil.info(
          'Retrieved user info for id: $id, found: ${data != null}');
      return data;
    } catch (e) {
      LoggerUtil.error('Failed to get user info: $e');
      return null;
    }
  }

  Future<void> saveTestSession(dynamic testSession) async {
    try {
      // 确保使用已初始化的box或重新打开
      Box sessionBox;
      if (_testSessionsBox != null && _testSessionsBox!.isOpen) {
        sessionBox = _testSessionsBox!;
      } else {
        sessionBox = await Hive.openBox('test_sessions');
      }

      // 直接存储对象，不需要转换为JSON
      await sessionBox.put(testSession.id, testSession);
      LoggerUtil.info(
          'Test session saved successfully with id: ${testSession.id}');
    } catch (e) {
      LoggerUtil.error('Failed to save test session: $e');
      rethrow;
    }
  }

  Future<dynamic> getTestSession(String id) async {
    try {
      // 确保使用已初始化的box或重新打开
      Box sessionBox;
      if (_testSessionsBox != null && _testSessionsBox!.isOpen) {
        sessionBox = _testSessionsBox!;
      } else {
        sessionBox = await Hive.openBox('test_sessions');
      }

      final data = sessionBox.get(id);
      LoggerUtil.info(
          'Retrieved test session for id: $id, found: ${data != null}');
      return data;
    } catch (e) {
      LoggerUtil.error('Failed to get test session: $e');
      return null;
    }
  }

  Future<void> saveTestResult(dynamic testResult) async {
    final resultBox = await Hive.openBox('test_results');
    await resultBox.put(testResult.id, testResult.toJson());
  }

  static Future<Map<String, dynamic>?> getTestSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('test_settings');
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      LoggerUtil.error('Failed to get test settings: $e');
      return null;
    }
  }

  static Future<void> saveTestSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings);
      await prefs.setString('test_settings', jsonString);
      LoggerUtil.info('Test settings saved');
    } catch (e) {
      LoggerUtil.error('Failed to save test settings: $e');
      rethrow;
    }
  }

  static Future<void> clearAllTestData() async {
    try {
      await Hive.deleteBoxFromDisk('user_info');
      await Hive.deleteBoxFromDisk('test_sessions');
      await Hive.deleteBoxFromDisk('test_results');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('test_settings');
      LoggerUtil.info('All test data cleared');
    } catch (e) {
      LoggerUtil.error('Failed to clear all test data: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> exportTestData() async {
    try {
      final userInfoBox = await Hive.openBox('user_info');
      final sessionBox = await Hive.openBox('test_sessions');
      final resultBox = await Hive.openBox('test_results');

      return {
        'userInfo': userInfoBox.toMap(),
        'testSessions': sessionBox.toMap(),
        'testResults': resultBox.toMap(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggerUtil.error('Failed to export test data: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllTestSessions() async {
    try {
      final sessionBox = await Hive.openBox('test_sessions');
      final sessions = <Map<String, dynamic>>[];

      for (final key in sessionBox.keys) {
        final session = sessionBox.get(key);
        if (session != null) {
          sessions.add(Map<String, dynamic>.from(session));
        }
      }

      // 按完成时间排序（最新的在前）
      sessions.sort((a, b) {
        final aTime =
            DateTime.tryParse(a['completedAt'] ?? '') ?? DateTime.now();
        final bTime =
            DateTime.tryParse(b['completedAt'] ?? '') ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      return sessions;
    } catch (e) {
      LoggerUtil.error('Failed to get all test sessions: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getTestResult(String id) async {
    try {
      final resultBox = await Hive.openBox('test_results');
      final result = resultBox.get(id);
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      LoggerUtil.error('Failed to get test result: $e');
      return null;
    }
  }

  static Future<void> deleteTestSession(String id) async {
    try {
      final sessionBox = await Hive.openBox('test_sessions');
      await sessionBox.delete(id);
      LoggerUtil.info('Test session deleted with id: $id');
    } catch (e) {
      LoggerUtil.error('Failed to delete test session: $e');
      rethrow;
    }
  }

  static Future<void> deleteTestResult(String id) async {
    try {
      final resultBox = await Hive.openBox('test_results');
      await resultBox.delete(id);
      LoggerUtil.info('Test result deleted with id: $id');
    } catch (e) {
      LoggerUtil.error('Failed to delete test result: $e');
      rethrow;
    }
  }

  /// 设置用户数据
  static Future<void> setUserData(
      String key, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(userData);
      await prefs.setString(key, jsonString);
      LoggerUtil.info('User data saved with key: $key');
    } catch (e) {
      LoggerUtil.error('Failed to set user data: $e');
      rethrow;
    }
  }

  /// 清除用户数据
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      LoggerUtil.info('User data cleared');
    } catch (e) {
      LoggerUtil.error('Failed to clear user data: $e');
      rethrow;
    }
  }
}
