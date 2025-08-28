import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 安卓设备适配配置类
/// 专门处理安卓设备底部小白条和各种屏幕适配问题
class AndroidAdaptationConfig {
  // 私有构造函数，确保单例
  AndroidAdaptationConfig._();
  
  static final AndroidAdaptationConfig _instance = AndroidAdaptationConfig._();
  static AndroidAdaptationConfig get instance => _instance;
  
  // 配置常量
  static const double _minBottomPadding = 16.0;
  static const double _maxBottomPadding = 48.0;
  static const double _defaultNavigationBarHeight = 48.0;
  
  // 屏幕尺寸断点
  static const double _mobileBreakpoint = 600.0;
  static const double _tabletBreakpoint = 1200.0;
  
  // 安卓设备特定配置
  static const Map<String, Map<String, dynamic>> _androidDeviceConfigs = {
    // 主流安卓设备配置
    'default': {
      'bottomPadding': 24.0,
      'navigationBarHeight': 48.0,
      'statusBarHeight': 24.0,
      'cornerRadius': 12.0,
    },
    // 小米设备
    'xiaomi': {
      'bottomPadding': 20.0,
      'navigationBarHeight': 44.0,
      'statusBarHeight': 27.0,
      'cornerRadius': 16.0,
    },
    // 华为设备
    'huawei': {
      'bottomPadding': 22.0,
      'navigationBarHeight': 46.0,
      'statusBarHeight': 25.0,
      'cornerRadius': 14.0,
    },
    // OPPO设备
    'oppo': {
      'bottomPadding': 24.0,
      'navigationBarHeight': 48.0,
      'statusBarHeight': 26.0,
      'cornerRadius': 15.0,
    },
    // vivo设备
    'vivo': {
      'bottomPadding': 23.0,
      'navigationBarHeight': 47.0,
      'statusBarHeight': 25.0,
      'cornerRadius': 13.0,
    },
    // 三星设备
    'samsung': {
      'bottomPadding': 26.0,
      'navigationBarHeight': 50.0,
      'statusBarHeight': 28.0,
      'cornerRadius': 18.0,
    },
  };
  
  /// 初始化安卓适配配置
  static Future<void> initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _setupAndroidSystemUI();
      await _configureAndroidGestures();
    }
  }
  
  /// 设置安卓系统UI
  static Future<void> _setupAndroidSystemUI() async {
    // 启用边到边显示
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    
    // 设置系统UI样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
  
  /// 配置安卓手势导航
  static Future<void> _configureAndroidGestures() async {
    // 这里可以添加手势导航的特殊配置
    // 例如检测是否启用了手势导航等
  }
  
  /// 获取设备特定配置
  static Map<String, dynamic> getDeviceConfig(String? deviceBrand) {
    if (deviceBrand == null || !Platform.isAndroid) {
      return _androidDeviceConfigs['default']!;
    }
    
    final String brand = deviceBrand.toLowerCase();
    for (final String key in _androidDeviceConfigs.keys) {
      if (brand.contains(key)) {
        return _androidDeviceConfigs[key]!;
      }
    }
    
    return _androidDeviceConfigs['default']!;
  }
  
  /// 获取安全的底部间距
  static double getSafeBottomPadding(BuildContext context, {String? deviceBrand}) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double systemBottomPadding = mediaQuery.padding.bottom;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    
    // 如果键盘弹起，使用键盘高度
    if (keyboardHeight > 0) {
      return keyboardHeight;
    }
    
    // 如果有系统底部间距（导航栏），使用系统值
    if (systemBottomPadding > 0) {
      return systemBottomPadding;
    }
    
    // 否则使用设备特定配置
    final config = getDeviceConfig(deviceBrand);
    return config['bottomPadding']?.toDouble() ?? _minBottomPadding;
  }
  
  /// 获取导航栏高度
  static double getNavigationBarHeight(String? deviceBrand) {
    final config = getDeviceConfig(deviceBrand);
    return config['navigationBarHeight']?.toDouble() ?? _defaultNavigationBarHeight;
  }
  
  /// 获取状态栏高度
  static double getStatusBarHeight(BuildContext context, {String? deviceBrand}) {
    final double systemStatusBarHeight = MediaQuery.of(context).padding.top;
    
    if (systemStatusBarHeight > 0) {
      return systemStatusBarHeight;
    }
    
    final config = getDeviceConfig(deviceBrand);
    return config['statusBarHeight']?.toDouble() ?? 24.0;
  }
  
  /// 获取响应式圆角半径
  static double getResponsiveCornerRadius(BuildContext context, {String? deviceBrand}) {
    final config = getDeviceConfig(deviceBrand);
    final double baseRadius = config['cornerRadius']?.toDouble() ?? 12.0;
    
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > _tabletBreakpoint) {
      return baseRadius * 1.5;
    } else if (screenWidth > _mobileBreakpoint) {
      return baseRadius * 1.2;
    }
    
    return baseRadius;
  }
  
  /// 检查是否为全面屏设备
  static bool isFullScreenDevice(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double screenWidth = mediaQuery.size.width;
    final double aspectRatio = screenHeight / screenWidth;
    
    // 全面屏设备通常宽高比大于1.8
    return aspectRatio > 1.8;
  }
  
  /// 检查是否有物理导航键
  static bool hasPhysicalNavigationKeys(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.bottom == 0;
  }
  
  /// 获取适配后的页面内边距
  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    String? deviceBrand,
    bool includeTop = true,
    bool includeBottom = true,
    bool includeHorizontal = true,
  }) {
    final double topPadding = includeTop 
        ? getStatusBarHeight(context, deviceBrand: deviceBrand) 
        : 0;
    final double bottomPadding = includeBottom 
        ? getSafeBottomPadding(context, deviceBrand: deviceBrand) 
        : 0;
    final double horizontalPadding = includeHorizontal ? 16.0 : 0;
    
    return EdgeInsets.only(
      top: topPadding,
      bottom: bottomPadding,
      left: horizontalPadding,
      right: horizontalPadding,
    );
  }
  
  /// 获取响应式字体大小
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth / 375.0; // 以iPhone X为基准
    
    if (screenWidth > _tabletBreakpoint) {
      return baseFontSize * scaleFactor.clamp(1.0, 1.4);
    } else if (screenWidth > _mobileBreakpoint) {
      return baseFontSize * scaleFactor.clamp(0.9, 1.2);
    }
    
    return baseFontSize * scaleFactor.clamp(0.8, 1.1);
  }
  
  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > _tabletBreakpoint) {
      return baseSpacing * 1.5;
    } else if (screenWidth > _mobileBreakpoint) {
      return baseSpacing * 1.2;
    }
    
    return baseSpacing;
  }
  
  /// 创建适配的系统UI覆盖样式
  static SystemUiOverlayStyle createAdaptiveSystemUIStyle({
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
  }) {
    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor ?? Colors.transparent,
      statusBarIconBrightness: statusBarIconBrightness ?? Brightness.light,
      statusBarBrightness: statusBarIconBrightness == Brightness.light 
          ? Brightness.dark 
          : Brightness.light,
      systemNavigationBarColor: navigationBarColor ?? Colors.transparent,
      systemNavigationBarIconBrightness: navigationBarIconBrightness ?? Brightness.light,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }
}