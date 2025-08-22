import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/logger_util.dart';

/// 设备信息模型
class DeviceInfo {
  /// 设备ID
  final String deviceId;
  
  /// 设备名称
  final String deviceName;
  
  /// 设备型号
  final String deviceModel;
  
  /// 系统版本
  final String systemVersion;
  
  /// 平台类型
  final String platform;
  
  /// 是否为物理设备
  final bool isPhysicalDevice;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.systemVersion,
    required this.platform,
    required this.isPhysicalDevice,
  });

  @override
  String toString() {
    return 'DeviceInfo{deviceId: $deviceId, deviceName: $deviceName, '
        'deviceModel: $deviceModel, systemVersion: $systemVersion, '
        'platform: $platform, isPhysicalDevice: $isPhysicalDevice}';
  }
}

/// 应用信息模型
class AppInfo {
  /// 应用名称
  final String appName;
  
  /// 包名
  final String packageName;
  
  /// 版本号
  final String version;
  
  /// 构建号
  final String buildNumber;

  const AppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  @override
  String toString() {
    return 'AppInfo{appName: $appName, packageName: $packageName, '
        'version: $version, buildNumber: $buildNumber}';
  }
}

/// 设备服务
class DeviceService {
  // 私有构造函数，防止实例化
  DeviceService._();

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static DeviceInfo? _cachedDeviceInfo;
  static AppInfo? _cachedAppInfo;

  /// 获取设备信息
  static Future<DeviceInfo> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    try {
      DeviceInfo deviceInfo;

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceInfo = DeviceInfo(
          deviceId: androidInfo.id,
          deviceName: androidInfo.device,
          deviceModel: androidInfo.model,
          systemVersion: 'Android ${androidInfo.version.release}',
          platform: 'Android',
          isPhysicalDevice: androidInfo.isPhysicalDevice,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceInfo = DeviceInfo(
          deviceId: iosInfo.identifierForVendor ?? 'unknown',
          deviceName: iosInfo.name,
          deviceModel: iosInfo.model,
          systemVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
          platform: 'iOS',
          isPhysicalDevice: iosInfo.isPhysicalDevice,
        );
      } else {
        // 其他平台的默认信息
        deviceInfo = const DeviceInfo(
          deviceId: 'unknown',
          deviceName: 'unknown',
          deviceModel: 'unknown',
          systemVersion: 'unknown',
          platform: 'unknown',
          isPhysicalDevice: true,
        );
      }

      _cachedDeviceInfo = deviceInfo;
      LoggerUtil.d('设备信息获取成功: $deviceInfo');
      return deviceInfo;
    } catch (e) {
      LoggerUtil.e('获取设备信息失败', e);
      rethrow;
    }
  }

  /// 获取应用信息
  static Future<AppInfo> getAppInfo() async {
    if (_cachedAppInfo != null) {
      return _cachedAppInfo!;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      final appInfo = AppInfo(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );

      _cachedAppInfo = appInfo;
      LoggerUtil.d('应用信息获取成功: $appInfo');
      return appInfo;
    } catch (e) {
      LoggerUtil.e('获取应用信息失败', e);
      rethrow;
    }
  }

  /// 获取设备ID
  static Future<String> getDeviceId() async {
    final deviceInfo = await getDeviceInfo();
    return deviceInfo.deviceId;
  }

  /// 获取设备型号
  static Future<String> getDeviceModel() async {
    final deviceInfo = await getDeviceInfo();
    return deviceInfo.deviceModel;
  }

  /// 获取系统版本
  static Future<String> getSystemVersion() async {
    final deviceInfo = await getDeviceInfo();
    return deviceInfo.systemVersion;
  }

  /// 获取应用版本
  static Future<String> getAppVersion() async {
    final appInfo = await getAppInfo();
    return appInfo.version;
  }

  /// 获取构建号
  static Future<String> getBuildNumber() async {
    final appInfo = await getAppInfo();
    return appInfo.buildNumber;
  }

  /// 是否为Android平台
  static bool get isAndroid => Platform.isAndroid;

  /// 是否为iOS平台
  static bool get isIOS => Platform.isIOS;

  /// 是否为移动平台
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// 是否为桌面平台
  static bool get isDesktop => 
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// 是否为Web平台
  static bool get isWeb => identical(0, 0.0);

  /// 清除缓存
  static void clearCache() {
    _cachedDeviceInfo = null;
    _cachedAppInfo = null;
    LoggerUtil.d('设备服务缓存已清除');
  }
}