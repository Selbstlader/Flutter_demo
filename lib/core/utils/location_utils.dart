import 'dart:async';
import '../services/amap_service.dart';
import '../utils/logger_util.dart';

/// 定位工具类
/// 提供简洁的定位API供项目使用
class LocationUtils {
  // 私有构造函数，防止实例化
  LocationUtils._();

  /// 获取当前位置
  /// 
  /// 返回包含经纬度、地址和精度信息的LocationResult对象
  /// 如果定位失败，会抛出异常
  /// 
  /// 使用示例：
  /// ```dart
  /// try {
  ///   final location = await LocationUtils.getCurrentLocation();
  ///   print('当前位置: ${location.address}');
  /// } catch (e) {
  ///   print('定位失败: $e');
  /// }
  /// ```
  static Future<LocationResult> getCurrentLocation() async {
    try {
      LoggerUtil.d('LocationUtils: 开始获取当前位置');
      final result = await AmapService.instance.getCurrentLocation();
      LoggerUtil.d('LocationUtils: 定位成功 - ${result.address}');
      return result;
    } catch (e) {
      LoggerUtil.e('LocationUtils: 定位失败', e);
      rethrow;
    }
  }

  /// 检查定位权限
  /// 
  /// 返回true表示有定位权限，false表示没有权限
  /// 通过尝试获取位置来间接检查权限状态
  static Future<bool> checkLocationPermission() async {
    try {
      LoggerUtil.d('LocationUtils: 检查定位权限');
      await getCurrentLocation();
      LoggerUtil.d('LocationUtils: 权限检查结果 - true');
      return true;
    } catch (e) {
      LoggerUtil.e('LocationUtils: 权限检查失败', e);
      return false;
    }
  }

  /// 获取位置信息的简化版本
  /// 
  /// 只返回地址字符串，如果定位失败返回null
  /// 适用于不需要详细位置信息的场景
  static Future<String?> getLocationAddress() async {
    try {
      final result = await getCurrentLocation();
      return result.address;
    } catch (e) {
      LoggerUtil.w('LocationUtils: 获取地址失败', e);
      return null;
    }
  }

  /// 获取经纬度坐标
  /// 
  /// 返回Map包含'latitude'和'longitude'键
  /// 如果定位失败返回null
  static Future<Map<String, double>?> getCoordinates() async {
    try {
      final result = await getCurrentLocation();
      return {
        'latitude': result.latitude,
        'longitude': result.longitude,
      };
    } catch (e) {
      LoggerUtil.w('LocationUtils: 获取坐标失败', e);
      return null;
    }
  }

  /// 格式化位置信息为可读字符串
  /// 
  /// 返回格式："地址 (纬度, 经度) 精度: X米"
  static Future<String?> getFormattedLocation() async {
    try {
      final result = await getCurrentLocation();
      return '${result.address} (${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}) 精度: ${result.accuracy.toStringAsFixed(1)}米';
    } catch (e) {
      LoggerUtil.w('LocationUtils: 格式化位置信息失败', e);
      return null;
    }
  }
}