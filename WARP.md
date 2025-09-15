# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## 项目概述

这是一个基于Flutter的AI智能助手应用，主要功能包括社保计算、养老金计算、心理健康测试和AI对话。采用现代化的分层架构设计，集成了完整的状态管理、网络请求和本地存储解决方案。

## 核心架构

### 分层架构
- **表现层 (lib/features/*/presentation/)**: UI页面、组件和状态管理
- **业务层 (lib/features/*/services/)**: 业务逻辑和数据处理
- **数据层 (lib/core/)**: 网络请求、存储服务和数据模型

### 核心模块
- **core/network/**: 基于Dio的网络请求封装，支持Token自动刷新和拦截器
- **core/services/**: 统一的存储服务（SharedPreferences + Hive）
- **core/router/**: 基于GoRouter的声明式路由管理
- **core/theme/**: 深色主题系统和UI样式定义
- **core/widgets/**: 通用UI组件库

## 常用开发命令

### 环境设置
```bash
# 安装依赖
flutter pub get

# 代码生成（必须运行，用于JSON序列化和Hive适配器）
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 开发和调试
```bash
# 运行开发版本
flutter run

# 热重载（在运行中）
r

# 热重启（在运行中）
R

# 清理构建缓存
flutter clean && flutter pub get
```

### 代码分析和测试
```bash
# 代码分析
flutter analyze

# 运行测试
flutter test

# 生成测试覆盖率
flutter test --coverage
```

### 构建发布版本
```bash
# Android APK
flutter build apk --release

# Android AAB（推荐用于Google Play）
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 代码生成相关
```bash
# 监听文件变化自动生成代码
flutter packages pub run build_runner watch

# 强制重新生成所有代码
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 关键技术栈

### 状态管理
- **flutter_riverpod**: 响应式状态管理，用于全局状态和依赖注入
- Provider位置: `lib/features/*/providers/`

### 网络请求
- **Dio**: HTTP客户端，配置了拦截器和自动Token刷新
- API客户端: `lib/core/network/api_client.dart`
- 基础URL: `http://localhost:48080`

### 本地存储
- **SharedPreferences**: 简单键值对存储
- **Hive**: 高性能NoSQL数据库，用于复杂数据结构
- 存储服务: `lib/core/services/storage_service.dart`

### 路由管理
- **GoRouter**: 声明式路由，支持嵌套路由和参数传递
- 路由配置: `lib/core/router/app_router.dart`

### UI框架
- **flutter_screenutil**: 屏幕适配解决方案
- **Material 3**: 现代化UI设计语言
- 深色主题为主要设计风格

## 项目结构说明

```
lib/
├── main.dart                    # 应用入口，初始化Hive和环境配置
├── core/                        # 核心模块
│   ├── config/                  # 配置文件（AI服务配置等）
│   ├── network/                 # 网络层（ApiClient封装）
│   ├── services/                # 核心服务（存储、认证等）
│   ├── router/                  # 路由配置
│   ├── theme/                   # 主题和样式定义
│   └── widgets/                 # 通用UI组件
└── features/                    # 功能模块
    ├── auth/                    # 认证模块
    ├── home/                    # 首页和计算功能
    ├── psychological_test/      # 心理健康测试
    └── settings/                # 设置页面
```

## 开发约定

### 命名规范
- 文件名: snake_case （如：`user_profile_page.dart`）
- 类名: PascalCase （如：`UserProfilePage`）
- 变量/方法: camelCase （如：`userName`）
- 常量: SCREAMING_SNAKE_CASE （如：`API_BASE_URL`）

### 代码组织
- 每个功能模块按照分层架构组织代码
- Provider和Notifier放在 `providers/` 目录
- 页面组件放在 `presentation/pages/` 目录
- 可复用组件放在 `presentation/widgets/` 目录
- 业务服务放在 `services/` 目录

### 状态管理模式
- 使用Riverpod的Provider进行依赖注入
- 复杂状态使用StateNotifier模式
- 页面级别状态优先使用局部Provider

## AI服务集成

项目集成了DeepSeek AI服务，相关配置：
- 配置文件: `lib/core/config/deepseek_config.dart`
- 聊天服务: `lib/features/home/services/deepseek_service.dart`
- API密钥通过环境变量 `.env` 文件管理

## 数据模型和序列化

项目使用 `json_annotation` 进行JSON序列化：
- 模型类需要使用 `@JsonSerializable()` 注解
- 生成序列化代码: `flutter packages pub run build_runner build`
- Hive模型需要使用 `@HiveType()` 和 `@HiveField()` 注解

## 常见开发任务

### 添加新页面
1. 在对应feature目录下创建页面文件
2. 在 `app_router.dart` 中添加路由配置
3. 如需状态管理，创建对应的Provider

### 添加新的API接口
1. 在 `api_client.dart` 中添加请求方法
2. 创建对应的数据模型类
3. 添加JSON序列化注解并生成代码

### 添加新的存储数据
1. 如果是简单数据，使用SharedPreferences通过StorageService
2. 如果是复杂对象，创建Hive模型并注册适配器
3. 在main.dart中注册新的Hive适配器

### 调试网络请求
- 网络请求日志通过LoggerUtil输出
- 可在ApiClient中添加详细的日志记录
- 使用Dio的拦截器查看请求/响应详情

## 环境配置

项目使用 `.env` 文件管理环境变量：
- DeepSeek API密钥
- 其他敏感配置信息
- 确保 `.env` 文件已添加到 `.gitignore`

## 性能优化建议

- 使用 `const` 构造函数优化UI重建
- 长列表使用 `ListView.builder`
- 图片使用 `cached_network_image` 进行缓存
- 合理使用Provider的select方法避免不必要的重建
- 大数据量存储优先使用Hive而非SharedPreferences