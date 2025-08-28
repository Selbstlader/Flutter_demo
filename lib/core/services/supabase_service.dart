import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger_util.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// 初始化Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      LoggerUtil.d('Supabase初始化成功');
    } catch (e) {
      LoggerUtil.e('Supabase初始化失败: $e');
      rethrow;
    }
  }

  /// 监听认证状态变化
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// 获取当前会话
  Session? get currentSession => client.auth.currentSession;
}