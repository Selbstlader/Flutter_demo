import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 安全区域适配工具类
/// 专门处理安卓设备底部小白条（系统导航栏）的适配问题
class SafeAreaUtils {
  static const double _defaultBottomPadding = 16.0;
  static const double _androidNavigationBarHeight = 48.0;
  
  /// 获取底部安全区域高度
  static double getBottomSafeArea(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom;
    final double viewInsetBottom = mediaQuery.viewInsets.bottom;
    
    // 如果是安卓设备且有底部导航栏
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && bottomPadding > 0) {
      return bottomPadding;
    }
    
    // 如果键盘弹起，使用键盘高度
    if (viewInsetBottom > 0) {
      return viewInsetBottom;
    }
    
    return _defaultBottomPadding;
  }
  
  /// 获取顶部安全区域高度
  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  
  /// 获取左侧安全区域宽度
  static double getLeftSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.left;
  }
  
  /// 获取右侧安全区域宽度
  static double getRightSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.right;
  }
  
  /// 检查是否有底部导航栏
  static bool hasBottomNavigationBar(BuildContext context) {
    return MediaQuery.of(context).padding.bottom > 0;
  }
  
  /// 获取屏幕可用高度（排除系统UI）
  static double getAvailableHeight(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - 
           mediaQuery.padding.top - 
           mediaQuery.padding.bottom;
  }
  
  /// 获取屏幕可用宽度（排除系统UI）
  static double getAvailableWidth(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width - 
           mediaQuery.padding.left - 
           mediaQuery.padding.right;
  }
  
  /// 设置系统UI样式
  static void setSystemUIOverlayStyle({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Brightness? statusBarIconBrightness,
    Color? systemNavigationBarColor,
    Brightness? systemNavigationBarIconBrightness,
    bool? systemNavigationBarContrastEnforced,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarBrightness: statusBarBrightness ?? Brightness.dark,
        statusBarIconBrightness: statusBarIconBrightness ?? Brightness.light,
        systemNavigationBarColor: systemNavigationBarColor ?? Colors.black,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness ?? Brightness.light,
        systemNavigationBarContrastEnforced: systemNavigationBarContrastEnforced ?? false,
      ),
    );
  }
  
  /// 隐藏系统导航栏（全屏模式）
  static void hideSystemNavigationBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
  }
  
  /// 显示系统导航栏
  static void showSystemNavigationBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }
}

/// 响应式设计工具类
class ResponsiveUtils {
  /// 获取设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// 获取响应式值
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final DeviceType deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
  
  /// 获取响应式字体大小
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth / 375.0; // 以iPhone X为基准
    return baseFontSize * scaleFactor.clamp(0.8, 1.2);
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}