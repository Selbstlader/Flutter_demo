import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/amap_config.dart';
import '../network/api_client.dart';
import '../utils/logger_util.dart';

/// 高德地图服务类
class AmapService {
  // 私有构造函数
  AmapService._();
  
  static final AmapService _instance = AmapService._();
  static AmapService get instance => _instance;
  
  /// 初始化高德地图服务
  Future<void> init() async {
    try {
      LoggerUtil.d('初始化高德地图服务');
      
      // 检查并请求定位权限
      await _requestLocationPermission();
      
      LoggerUtil.d('高德地图服务初始化完成');
    } catch (e) {
      LoggerUtil.e('高德地图服务初始化失败', e);
      rethrow;
    }
  }
  
  /// 请求定位权限
  Future<bool> _requestLocationPermission() async {
    try {
      // 检查定位服务是否开启
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        LoggerUtil.w('定位服务未开启');
        return false;
      }
      
      // 检查定位权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          LoggerUtil.w('定位权限被拒绝');
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        LoggerUtil.w('定位权限被永久拒绝');
        return false;
      }
      
      LoggerUtil.d('定位权限获取成功');
      return true;
    } catch (e) {
      LoggerUtil.e('请求定位权限失败', e);
      return false;
    }
  }
  
  /// 获取当前位置
  Future<LocationResult> getCurrentLocation() async {
    try {
      LoggerUtil.d('开始获取当前位置');
      
      // 检查权限
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        throw Exception('定位权限不足');
      }
      
      Position? position;
      
      try {
        // 首先尝试获取最后已知位置
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          LoggerUtil.d('使用最后已知位置: ${position.latitude}, ${position.longitude}');
        }
      } catch (e) {
        LoggerUtil.w('获取最后已知位置失败: $e');
      }
      
      // 如果没有最后已知位置，或位置太旧，则获取当前位置
      if (position == null || 
          (DateTime.now().difference(position.timestamp ?? DateTime.now()).inMinutes > 10)) {
        try {
          // 使用更宽松的配置获取当前位置
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium, // 降低精度要求
            timeLimit: Duration(seconds: 15), // 缩短超时时间
          ).timeout(
            Duration(seconds: 20), // 额外的超时保护
            onTimeout: () {
              throw TimeoutException('定位超时，请检查GPS信号或网络连接', Duration(seconds: 20));
            },
          );
          
          LoggerUtil.d('当前位置获取成功: ${position.latitude}, ${position.longitude}');
        } catch (e) {
          LoggerUtil.e('获取当前位置失败，尝试使用低精度定位: $e');
          
          // 如果高精度定位失败，尝试低精度定位
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 10),
            ).timeout(
              Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException('低精度定位也超时，请检查设备定位设置', Duration(seconds: 15));
              },
            );
            LoggerUtil.d('低精度位置获取成功: ${position.latitude}, ${position.longitude}');
          } catch (lowAccuracyError) {
            LoggerUtil.e('低精度定位也失败: $lowAccuracyError');
            rethrow;
          }
        }
      }
      
      if (position == null) {
        throw Exception('无法获取位置信息');
      }
      
      // 调用高德逆地理编码API获取地址信息（添加超时保护）
      String address;
      try {
        address = await _getAddressFromCoordinates(
          position.latitude, 
          position.longitude,
        ).timeout(
          Duration(seconds: 10),
          onTimeout: () => '地址解析超时',
        );
      } catch (e) {
        LoggerUtil.w('地址解析失败，使用默认值: $e');
        address = '地址解析失败';
      }
      
      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    } catch (e) {
      LoggerUtil.e('获取当前位置失败', e);
      rethrow;
    }
  }
  
  /// 通过坐标获取地址信息（逆地理编码）
  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = '${AmapConfig.webServiceBaseUrl}/v3/geocode/regeo';
      final params = {
        'key': AmapConfig.currentApiKey,
        'location': '$lng,$lat',
        'poitype': '',
        'radius': '1000',
        'extensions': 'base',
        'batch': 'false',
        'roadlevel': '0',
      };
      
      LoggerUtil.d('逆地理编码请求URL: $url');
      LoggerUtil.d('请求参数: $params');
      LoggerUtil.d('使用API密钥: ${AmapConfig.currentApiKey}');
      
      final response = await ApiClient.get(url, queryParameters: params);
      
      LoggerUtil.d('响应状态码: ${response.statusCode}');
      LoggerUtil.d('响应数据: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == '1') {
          final regeocode = data['regeocode'];
          if (regeocode != null && regeocode['formatted_address'] != null) {
            final address = regeocode['formatted_address'] as String;
            LoggerUtil.d('地址解析成功: $address');
            return address;
          } else {
            LoggerUtil.w('regeocode数据为空或缺少formatted_address字段');
            LoggerUtil.w('regeocode内容: $regeocode');
          }
        } else {
          LoggerUtil.w('逆地理编码API返回错误状态: ${data['status']}');
          LoggerUtil.w('错误信息: ${data['info']}');
          LoggerUtil.w('错误代码: ${data['infocode']}');
        }
      } else {
        LoggerUtil.w('HTTP请求失败，状态码: ${response.statusCode}');
      }
      
      return '地址解析失败';
    } catch (e) {
      LoggerUtil.e('逆地理编码异常', e);
      return '地址解析失败: ${e.toString()}';
    }
  }
  
  /// 通过地址获取坐标信息（地理编码）
  Future<CoordinateResult?> getCoordinatesFromAddress(String address) async {
    try {
      LoggerUtil.d('开始地理编码: $address');
      
      final response = await ApiClient.get(
        '${AmapConfig.webServiceBaseUrl}/v3/geocode/geo',
        queryParameters: {
          'key': AmapConfig.currentApiKey,
          'address': address,
          'city': '',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == '1') {
          final geocodes = data['geocodes'] as List?;
          if (geocodes != null && geocodes.isNotEmpty) {
            final geocode = geocodes.first;
            final location = geocode['location'] as String;
            final coords = location.split(',');
            
            return CoordinateResult(
              latitude: double.parse(coords[1]),
              longitude: double.parse(coords[0]),
              address: geocode['formatted_address'] ?? address,
            );
          }
        } else {
          LoggerUtil.w('地理编码API返回错误: ${data['info']}');
        }
      }
      
      return null;
    } catch (e) {
      LoggerUtil.e('地理编码失败', e);
      return null;
    }
  }
  
  /// 搜索POI
  Future<List<PoiResult>> searchPoi(String keyword, {String? city}) async {
    try {
      LoggerUtil.d('开始POI搜索: $keyword');
      
      final response = await ApiClient.get(
        '${AmapConfig.webServiceBaseUrl}/v3/place/text',
        queryParameters: {
          'key': AmapConfig.currentApiKey,
          'keywords': keyword,
          'city': city ?? '',
          'offset': '20',
          'page': '1',
          'extensions': 'base',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == '1') {
          final pois = data['pois'] as List?;
          if (pois != null) {
            return pois.map((poi) => PoiResult.fromJson(poi)).toList();
          }
        } else {
          LoggerUtil.w('POI搜索API返回错误: ${data['info']}');
        }
      }
      
      return [];
    } catch (e) {
      LoggerUtil.e('POI搜索失败', e);
      return [];
    }
  }
}

/// 定位结果
class LocationResult {
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;
  final DateTime timestamp;
  
  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'accuracy': accuracy,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 坐标结果
class CoordinateResult {
  final double latitude;
  final double longitude;
  final String address;
  
  CoordinateResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };
}

/// POI搜索结果
class PoiResult {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? type;
  
  PoiResult({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.type,
  });
  
  factory PoiResult.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as String;
    final coords = location.split(',');
    
    return PoiResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      longitude: double.tryParse(coords[0]) ?? 0.0,
      latitude: double.tryParse(coords[1]) ?? 0.0,
      type: json['type'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'type': type,
  };
}