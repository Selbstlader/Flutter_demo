# Flutter项目Supabase集成指南

## 1. 项目概述

本文档详细说明如何在现有Flutter项目中集成Supabase数据库服务。项目当前使用Hive和SharedPreferences进行本地存储，具有完整的网络层架构(ApiClient)。Supabase将作为云端数据库解决方案，提供实时数据同步、用户认证和数据存储功能。

## 2. 依赖配置

### 2.1 添加Supabase依赖

在`pubspec.yaml`文件的dependencies部分添加以下依赖：

```yaml
dependencies:
  # 现有依赖...
  
  # Supabase相关
  supabase_flutter: ^2.3.4
  supabase: ^2.2.2
```

### 2.2 更新依赖

运行以下命令更新项目依赖：

```bash
flutter pub get
```

## 3. Supabase配置

### 3.1 创建配置文件

在`lib/core/config/`目录下创建`supabase_config.dart`：

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // 表名常量
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String socialSecurityTable = 'social_security_records';
}
```

### 3.2 环境变量配置

在项目根目录创建`.env`文件（记得添加到`.gitignore`）：

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 4. Supabase服务实现

### 4.1 创建Supabase服务基类

在`lib/core/services/`目录下创建`supabase_service.dart`：

```dart
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
```

### 4.2 创建认证服务

在`lib/core/services/`目录下创建`supabase_auth_service.dart`：

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../utils/logger_util.dart';

class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  final _supabase = SupabaseService();

  /// 邮箱密码注册
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      LoggerUtil.d('用户注册成功: ${response.user?.email}');
      return response;
    } catch (e) {
      LoggerUtil.e('用户注册失败: $e');
      rethrow;
    }
  }

  /// 邮箱密码登录
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      LoggerUtil.d('用户登录成功: ${response.user?.email}');
      return response;
    } catch (e) {
      LoggerUtil.e('用户登录失败: $e');
      rethrow;
    }
  }

  /// 退出登录
  Future<void> signOut() async {
    try {
      await _supabase.client.auth.signOut();
      LoggerUtil.d('用户退出登录');
    } catch (e) {
      LoggerUtil.e('退出登录失败: $e');
      rethrow;
    }
  }

  /// 重置密码
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.client.auth.resetPasswordForEmail(email);
      LoggerUtil.d('密码重置邮件已发送: $email');
    } catch (e) {
      LoggerUtil.e('发送密码重置邮件失败: $e');
      rethrow;
    }
  }

  /// 更新用户信息
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
      LoggerUtil.d('用户信息更新成功');
      return response;
    } catch (e) {
      LoggerUtil.e('用户信息更新失败: $e');
      rethrow;
    }
  }
}
```

### 4.3 创建数据服务

在`lib/core/services/`目录下创建`supabase_data_service.dart`：

```dart
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
      var query = _supabase.client.from(table).select(columns);
      
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
```

## 5. 集成到现有架构

### 5.1 更新存储服务

修改`lib/core/services/storage_service.dart`，添加Supabase集成：

```dart
// 在StorageService类中添加以下方法

/// 同步本地数据到Supabase
static Future<void> syncToSupabase() async {
  try {
    final supabaseData = SupabaseDataService();
    
    // 获取本地用户数据
    final userData = _userBox.toMap();
    
    // 同步到Supabase
    if (userData.isNotEmpty) {
      await supabaseData.insert(
        table: SupabaseConfig.profilesTable,
        data: userData,
      );
    }
    
    LoggerUtil.d('数据同步到Supabase成功');
  } catch (e) {
    LoggerUtil.e('数据同步到Supabase失败: $e');
  }
}

/// 从Supabase同步数据到本地
static Future<void> syncFromSupabase() async {
  try {
    final supabaseData = SupabaseDataService();
    final supabaseAuth = SupabaseAuthService();
    
    if (supabaseAuth.isAuthenticated) {
      final userId = supabaseAuth.currentUser!.id;
      
      // 从Supabase获取用户数据
      final userData = await supabaseData.select(
        table: SupabaseConfig.profilesTable,
        where: 'user_id',
        whereValue: userId,
      );
      
      // 保存到本地
      if (userData.isNotEmpty) {
        final data = userData.first;
        for (final entry in data.entries) {
          await _userBox.put(entry.key, entry.value);
        }
      }
    }
    
    LoggerUtil.d('从Supabase同步数据成功');
  } catch (e) {
    LoggerUtil.e('从Supabase同步数据失败: $e');
  }
}
```

### 5.2 更新主应用初始化

修改`lib/main.dart`，添加Supabase初始化：

```dart
import 'package:flutter/material.dart';
import 'core/services/supabase_service.dart';
// 其他导入...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive
  await Hive.initFlutter();
  
  // 初始化存储服务
  await StorageService.init();
  
  // 初始化Supabase
  await SupabaseService.initialize();
  
  runApp(const MyApp());
}
```

## 6. 数据模型定义

### 6.1 用户模型

在`lib/core/models/`目录下创建`user_model.dart`：

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

### 6.2 社保记录模型

在`lib/core/models/`目录下创建`social_security_model.dart`：

```dart
import 'package:json_annotation/json_annotation.dart';

part 'social_security_model.g.dart';

@JsonSerializable()
class SocialSecurityModel {
  final String id;
  final String userId;
  final String region;
  final double baseSalary;
  final double pensionPersonal;
  final double pensionCompany;
  final double medicalPersonal;
  final double medicalCompany;
  final double unemploymentPersonal;
  final double unemploymentCompany;
  final double housingFund;
  final DateTime calculatedAt;
  
  SocialSecurityModel({
    required this.id,
    required this.userId,
    required this.region,
    required this.baseSalary,
    required this.pensionPersonal,
    required this.pensionCompany,
    required this.medicalPersonal,
    required this.medicalCompany,
    required this.unemploymentPersonal,
    required this.unemploymentCompany,
    required this.housingFund,
    required this.calculatedAt,
  });
  
  factory SocialSecurityModel.fromJson(Map<String, dynamic> json) => _$SocialSecurityModelFromJson(json);
  Map<String, dynamic> toJson() => _$SocialSecurityModelToJson(this);
}
```

## 7. 数据库表结构

### 7.1 用户表(profiles)

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 启用RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 创建策略
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

### 7.2 社保记录表(social_security_records)

```sql
CREATE TABLE social_security_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  region TEXT NOT NULL,
  base_salary DECIMAL(10,2) NOT NULL,
  pension_personal DECIMAL(10,2) NOT NULL,
  pension_company DECIMAL(10,2) NOT NULL,
  medical_personal DECIMAL(10,2) NOT NULL,
  medical_company DECIMAL(10,2) NOT NULL,
  unemployment_personal DECIMAL(10,2) NOT NULL,
  unemployment_company DECIMAL(10,2) NOT NULL,
  housing_fund DECIMAL(10,2) NOT NULL,
  calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 启用RLS
ALTER TABLE social_security_records ENABLE ROW LEVEL SECURITY;

-- 创建策略
CREATE POLICY "Users can view own records" ON social_security_records
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own records" ON social_security_records
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own records" ON social_security_records
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own records" ON social_security_records
  FOR DELETE USING (auth.uid() = user_id);
```

## 8. 使用示例

### 8.1 用户认证

```dart
// 注册用户
final authService = SupabaseAuthService();
try {
  final response = await authService.signUpWithEmail(
    email: 'user@example.com',
    password: 'password123',
    data: {'name': '张三'},
  );
  print('注册成功: ${response.user?.email}');
} catch (e) {
  print('注册失败: $e');
}

// 登录用户
try {
  final response = await authService.signInWithEmail(
    email: 'user@example.com',
    password: 'password123',
  );
  print('登录成功: ${response.user?.email}');
} catch (e) {
  print('登录失败: $e');
}
```

### 8.2 数据操作

```dart
// 保存社保记录
final dataService = SupabaseDataService();
try {
  final result = await dataService.insert(
    table: SupabaseConfig.socialSecurityTable,
    data: {
      'user_id': SupabaseService().currentUser!.id,
      'region': '北京',
      'base_salary': 10000.00,
      'pension_personal': 800.00,
      'pension_company': 2000.00,
      // 其他字段...
    },
  );
  print('保存成功: $result');
} catch (e) {
  print('保存失败: $e');
}

// 查询用户的社保记录
try {
  final records = await dataService.select(
    table: SupabaseConfig.socialSecurityTable,
    where: 'user_id',
    whereValue: SupabaseService().currentUser!.id,
    orderBy: 'calculated_at',
    ascending: false,
  );
  print('查询到${records.length}条记录');
} catch (e) {
  print('查询失败: $e');
}
```

## 9. 最佳实践

### 9.1 错误处理

- 使用try-catch包装所有Supabase操作
- 实现统一的错误处理机制
- 提供用户友好的错误提示

### 9.2 性能优化

- 使用分页查询大量数据
- 实现本地缓存机制
- 合理使用实时订阅

### 9.3 安全考虑

- 启用行级安全(RLS)
- 验证用户输入
- 使用环境变量存储敏感信息

### 9.4 离线支持

- 实现本地数据缓存
- 网络恢复时自动同步
- 冲突解决策略

## 10. 总结

通过以上步骤，您已经成功将Supabase集成到Flutter项目中。Supabase提供了强大的实时数据库、用户认证和文件存储功能，与现有的本地存储方案形成了完整的数据管理体系。建议在开发过程中逐步迁移功能，确保系统的稳定性和可靠性。