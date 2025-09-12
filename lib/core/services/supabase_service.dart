// Supabase相关导入 - 已注释，改用独立后端接口
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger_util.dart';
import '../utils/error_handler.dart';

// Supabase服务类 - 已注释，改用独立后端接口
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase客户端相关 - 已注释
  // SupabaseClient get client => Supabase.instance.client;
  // User? get currentUser => client.auth.currentUser;
  // bool get isAuthenticated => currentUser != null;

  /// 初始化Supabase - 已注释
  static Future<void> initialize() async {
    try {
      // await Supabase.initialize(
      //   url: SupabaseConfig.supabaseUrl,
      //   anonKey: SupabaseConfig.supabaseAnonKey,
      // );
      LoggerUtil.d('Supabase初始化已跳过，使用独立后端接口');
    } catch (e) {
      LoggerUtil.e('Supabase初始化失败: ${ErrorHandler.handleError(e, context: 'initSupabase')}');
      rethrow;
    }
  }

  /// 监听认证状态变化 - 已注释
  // Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// 获取当前会话 - 已注释
  // Session? get currentSession => client.auth.currentSession;
}