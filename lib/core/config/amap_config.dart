import 'package:flutter/foundation.dart';

/// 高德地图API配置
class AmapConfig {
  // 私有构造函数
  AmapConfig._();

  /// Web端API密钥
  static const String webApiKey = '12d676c29a3edb382d4c372a4ff3d726';
  
  /// 安卓端API密钥
  static const String androidApiKey = '54bf9e42ffd01c2f42caa5056ee38d27';
  
  /// iOS端API密钥 (预留)
  static const String iosApiKey = '';
  
  /// 根据当前平台获取对应的API密钥
  /// 注意：Web服务API（逆地理编码等）统一使用webApiKey
  /// androidApiKey和iosApiKey仅用于原生地图SDK
  static String get currentApiKey {
    // 对于Web服务API调用，统一使用Web服务密钥
    return webApiKey;
  }
  
  /// 获取原生SDK使用的API密钥
  static String get nativeSdkApiKey {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidApiKey;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosApiKey;
    } else {
      return webApiKey;
    }
  }
  
  /// 高德地图Web服务API基础URL
  static const String webServiceBaseUrl = 'https://restapi.amap.com';
  
  /// 安全密钥 (用于Web端JSAPI)
  static const String securityJsCode = '';
  
  /// 定位服务配置
  static const Map<String, dynamic> locationConfig = {
    'accuracy': 'high', // 定位精度: high, medium, low
    'timeout': 30000, // 超时时间(毫秒)
    'interval': 2000, // 定位间隔(毫秒)
  };
  
  /// 地图显示配置
  static const Map<String, dynamic> mapConfig = {
    'zoomLevel': 15.0, // 默认缩放级别
    'showMyLocation': true, // 显示我的位置
    'showCompass': true, // 显示指南针
    'showScale': true, // 显示比例尺
  };
}