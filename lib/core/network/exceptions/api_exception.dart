/// API异常类
class ApiException implements Exception {
  /// 错误码
  final String code;

  /// 错误消息
  final String message;

  /// HTTP状态码
  final int statusCode;

  /// 额外数据
  final dynamic data;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  const ApiException({
    required this.code,
    required this.message,
    required this.statusCode,
    this.data,
    this.stackTrace,
  });

  /// 网络连接异常
  factory ApiException.networkError({String? message}) {
    return ApiException(
      code: 'NETWORK_ERROR',
      message: message ?? '网络连接异常，请检查网络设置',
      statusCode: -1,
    );
  }

  /// 请求超时异常
  factory ApiException.timeout({String? message}) {
    return ApiException(
      code: 'TIMEOUT',
      message: message ?? '请求超时，请稍后重试',
      statusCode: -1,
    );
  }

  /// 服务器异常
  factory ApiException.serverError({
    String? code,
    String? message,
    int? statusCode,
    dynamic data,
  }) {
    return ApiException(
      code: code ?? 'SERVER_ERROR',
      message: message ?? '服务器异常',
      statusCode: statusCode ?? 500,
      data: data,
    );
  }

  /// 认证异常
  factory ApiException.unauthorized({String? message}) {
    return ApiException(
      code: 'UNAUTHORIZED',
      message: message ?? '未授权，请重新登录',
      statusCode: 401,
    );
  }

  /// 禁止访问异常
  factory ApiException.forbidden({String? message}) {
    return ApiException(
      code: 'FORBIDDEN',
      message: message ?? '禁止访问',
      statusCode: 403,
    );
  }

  /// 资源不存在异常
  factory ApiException.notFound({String? message}) {
    return ApiException(
      code: 'NOT_FOUND',
      message: message ?? '请求的资源不存在',
      statusCode: 404,
    );
  }

  /// 参数错误异常
  factory ApiException.badRequest({String? message, dynamic data}) {
    return ApiException(
      code: 'BAD_REQUEST',
      message: message ?? '请求参数错误',
      statusCode: 400,
      data: data,
    );
  }

  /// 业务逻辑异常
  factory ApiException.businessError({
    required String code,
    required String message,
    dynamic data,
  }) {
    return ApiException(
      code: code,
      message: message,
      statusCode: 200,
      data: data,
    );
  }

  /// 未知异常
  factory ApiException.unknown({String? message, dynamic data}) {
    return ApiException(
      code: 'UNKNOWN_ERROR',
      message: message ?? '未知错误',
      statusCode: -1,
      data: data,
    );
  }

  /// 是否为网络错误
  bool get isNetworkError => statusCode == -1;

  /// 是否为服务器错误
  bool get isServerError => statusCode >= 500;

  /// 是否为客户端错误
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// 是否为认证错误
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  @override
  String toString() {
    return 'ApiException{code: $code, message: $message, statusCode: $statusCode, data: $data}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiException &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          statusCode == other.statusCode &&
          data == other.data;

  @override
  int get hashCode =>
      code.hashCode ^ message.hashCode ^ statusCode.hashCode ^ data.hashCode;
}