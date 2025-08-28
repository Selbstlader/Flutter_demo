import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';
import '../utils/logger_util.dart';

class SupabaseDataService {
  static final SupabaseDataService _instance = SupabaseDataService._internal();
  factory SupabaseDataService() => _instance;
  SupabaseDataService._internal();

  final _supabase = SupabaseService();

  /// 插入数据
  Future<List<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _supabase.client
          .from(table)
          .insert(data)
          .select();
      LoggerUtil.d('数据插入成功: $table');
      return response;
    } catch (e) {
      LoggerUtil.e('数据插入失败: $e');
      rethrow;
    }
  }

  /// 查询数据
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    String? where,
    dynamic whereValue,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = _supabase.client.from(table).select(columns);
      
      if (where != null && whereValue != null) {
        query = query.eq(where, whereValue);
      }
      
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      LoggerUtil.d('数据查询成功: $table, 返回${response.length}条记录');
      return response;
    } catch (e) {
      LoggerUtil.e('数据查询失败: $e');
      rethrow;
    }
  }

  /// 更新数据
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required dynamic whereValue,
  }) async {
    try {
      final response = await _supabase.client
          .from(table)
          .update(data)
          .eq(where, whereValue)
          .select();
      LoggerUtil.d('数据更新成功: $table');
      return response;
    } catch (e) {
      LoggerUtil.e('数据更新失败: $e');
      rethrow;
    }
  }

  /// 删除数据
  Future<List<Map<String, dynamic>>> delete({
    required String table,
    required String where,
    required dynamic whereValue,
  }) async {
    try {
      final response = await _supabase.client
          .from(table)
          .delete()
          .eq(where, whereValue)
          .select();
      LoggerUtil.d('数据删除成功: $table');
      return response;
    } catch (e) {
      LoggerUtil.e('数据删除失败: $e');
      rethrow;
    }
  }

  /// 实时订阅
  RealtimeChannel subscribe({
    required String table,
    required Function(PostgresChangePayload) onData,
    PostgresChangeEvent event = PostgresChangeEvent.all,
  }) {
    try {
      final channel = _supabase.client
          .channel('public:$table')
          .onPostgresChanges(
            event: event,
            schema: 'public',
            table: table,
            callback: onData,
          )
          .subscribe();
      LoggerUtil.d('实时订阅成功: $table');
      return channel;
    } catch (e) {
      LoggerUtil.e('实时订阅失败: $e');
      rethrow;
    }
  }
}