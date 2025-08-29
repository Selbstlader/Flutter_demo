import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'network/api_client.dart';
import 'services/connectivity_service.dart';
import 'services/storage_service.dart';
import 'services/amap_service.dart';
import 'utils/logger_util.dart';

/// 应用初始化器
class AppInitializer {
  // 私有构造函数，防止实例化
  AppInitializer._();

  /// 初始化应用
  static Future<void> initialize() async {
    try {
      LoggerUtil.d('开始初始化应用...');

      // 1. 初始化Flutter绑定
      await _initializeFlutterBinding();

      // 2. 初始化日志系统
      _initializeLogger();

      // 3. 初始化本地存储
      await _initializeStorage();

      // 4. 初始化网络客户端
      _initializeNetworkClient();

      // 5. 初始化连接监听
      await _initializeConnectivity();

      // 6. 初始化高德地图服务
      await _initializeAmapService();

      // 7. 设置系统UI样式
      await _setupSystemUI();

      LoggerUtil.d('应用初始化完成');
    } catch (e, stackTrace) {
      LoggerUtil.e('应用初始化失败', e, stackTrace);
      rethrow;
    }
  }

  /// 初始化Flutter绑定
  static Future<void> _initializeFlutterBinding() async {
    // 确保Flutter绑定已初始化
    WidgetsFlutterBinding.ensureInitialized();
    
    // 设置错误处理
    FlutterError.onError = (FlutterErrorDetails details) {
      LoggerUtil.e('Flutter错误', details.exception, details.stack);
      
      // 在调试模式下显示错误
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // 设置平台异常处理
    PlatformDispatcher.instance.onError = (error, stack) {
      LoggerUtil.e('平台异常', error, stack);
      return true;
    };

    LoggerUtil.d('Flutter绑定初始化完成');
  }

  /// 初始化日志系统
  static void _initializeLogger() {
    LoggerUtil.init();
    LoggerUtil.d('日志系统初始化完成');
  }

  /// 初始化本地存储
  static Future<void> _initializeStorage() async {
    // 初始化Hive
    await Hive.initFlutter();
    
    // 初始化存储服务
    await StorageService.init();
    
    LoggerUtil.d('本地存储初始化完成');
  }

  /// 初始化网络客户端
  static void _initializeNetworkClient() {
    ApiClient.init();
    LoggerUtil.d('网络客户端初始化完成');
  }

  /// 初始化连接监听
  static Future<void> _initializeConnectivity() async {
    await ConnectivityService.init();
    LoggerUtil.d('连接监听初始化完成');
  }

  /// 初始化高德地图服务
  static Future<void> _initializeAmapService() async {
    await AmapService.instance.init();
    LoggerUtil.d('高德地图服务初始化完成');
  }

  /// 设置系统UI样式
  static Future<void> _setupSystemUI() async {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 设置支持的屏幕方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    LoggerUtil.d('系统UI样式设置完成');
  }

  /// 清理资源
  static Future<void> dispose() async {
    try {
      LoggerUtil.d('开始清理应用资源...');

      // 清理连接监听
      ConnectivityService.dispose();

      // 清理网络客户端
      await ApiClient.clearCookies();

      LoggerUtil.d('应用资源清理完成');
    } catch (e) {
      LoggerUtil.e('清理应用资源失败', e);
    }
  }
}