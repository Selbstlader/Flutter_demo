import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// API响应基础模型
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  /// 响应码
  @JsonKey(name: 'code')
  final String? code;

  /// 响应消息
  @JsonKey(name: 'message')
  final String? message;

  /// 响应数据
  @JsonKey(name: 'data')
  final T? data;

  /// 是否成功
  @JsonKey(name: 'success')
  final bool? success;

  /// 时间戳
  @JsonKey(name: 'timestamp')
  final int? timestamp;

  const ApiResponse({
    this.code,
    this.message,
    this.data,
    this.success,
    this.timestamp,
  });

  /// 从JSON创建实例
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  /// 转换为JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// 是否请求成功
  bool get isSuccess => success == true || (code != null && code == '200');

  /// 获取错误消息
  String get errorMessage => message ?? '请求失败';

  /// 创建成功响应
  factory ApiResponse.success({
    T? data,
    String? message,
    String? code,
  }) {
    return ApiResponse<T>(
      code: code ?? '200',
      message: message ?? '请求成功',
      data: data,
      success: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 创建失败响应
  factory ApiResponse.error({
    String? code,
    String? message,
    T? data,
  }) {
    return ApiResponse<T>(
      code: code ?? '500',
      message: message ?? '请求失败',
      data: data,
      success: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{code: $code, message: $message, success: $success, data: $data}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponse &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          data == other.data &&
          success == other.success &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      code.hashCode ^
      message.hashCode ^
      data.hashCode ^
      success.hashCode ^
      timestamp.hashCode;
}