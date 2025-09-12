import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger_util.dart';
import '../utils/error_handler.dart';

/// 网络连接状态枚举
enum ConnectivityStatus {
  /// 已连接
  connected,
  /// 未连接
  disconnected,
  /// 未知状态
  unknown,
}

/// 网络连接服务
class ConnectivityService {
  // 私有构造函数，防止实例化
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<ConnectivityResult>? _subscription;
  static final StreamController<ConnectivityStatus> _controller = 
      StreamController<ConnectivityStatus>.broadcast();

  /// 网络状态流
  static Stream<ConnectivityStatus> get statusStream => _controller.stream;

  /// 初始化网络监听
  static Future<void> init() async {
    try {
      // 获取初始网络状态
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      // 监听网络状态变化
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateStatus,
        onError: (error) {
          LoggerUtil.e('网络状态监听错误', error: error);
          _controller.add(ConnectivityStatus.unknown);
        },
      );

      LoggerUtil.d('网络连接服务初始化完成');
    } catch (e) {
      LoggerUtil.e('网络连接服务初始化失败: ${ErrorHandler.handleError(e, context: 'initConnectivity')}');
    }
  }

  /// 更新网络状态
  static void _updateStatus(ConnectivityResult result) {
    ConnectivityStatus status;
    
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        status = ConnectivityStatus.connected;
        LoggerUtil.d('网络已连接: $result');
        break;
      case ConnectivityResult.none:
        status = ConnectivityStatus.disconnected;
        LoggerUtil.w('网络已断开');
        break;
      default:
        status = ConnectivityStatus.unknown;
        LoggerUtil.w('网络状态未知: $result');
    }

    _controller.add(status);
  }

  /// 检查当前网络状态
  static Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          return ConnectivityStatus.connected;
        case ConnectivityResult.none:
          return ConnectivityStatus.disconnected;
        default:
          return ConnectivityStatus.unknown;
      }
    } catch (e) {
      LoggerUtil.e('检查网络状态失败: ${ErrorHandler.handleError(e, context: 'checkConnectivity')}');
      return ConnectivityStatus.unknown;
    }
  }

  /// 是否已连接网络
  static Future<bool> get isConnected async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.connected;
  }

  /// 销毁服务
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller.close();
    LoggerUtil.d('网络连接服务已销毁');
  }
}

/// 网络连接状态Provider
final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  return ConnectivityService.statusStream;
});

/// 网络连接状态Notifier
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.unknown) {
    _init();
  }

  Future<void> _init() async {
    state = await ConnectivityService.checkConnectivity();
    
    ConnectivityService.statusStream.listen((status) {
      state = status;
    });
  }

  /// 刷新网络状态
  Future<void> refresh() async {
    state = await ConnectivityService.checkConnectivity();
  }
}

/// 网络连接状态Notifier Provider
final connectivityNotifierProvider = 
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});