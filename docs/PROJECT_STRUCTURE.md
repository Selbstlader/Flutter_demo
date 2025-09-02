# Flutter Demo 项目结构说明

## 📁 项目目录结构

```
flutter_demo/
├── 📄 README.md                              # 项目说明文档
├── 📄 PROJECT_STRUCTURE.md                   # 项目结构说明（本文件）
├── 📄 pubspec.yaml                          # 项目依赖配置
├── 📄 analysis_options.yaml                 # 代码分析配置
├── 📁 assets/                               # 资源文件目录
│   ├── 📁 data/                            # 数据文件
│   │   └── 📄 regions.json                 # 地区数据
│   └── 📁 icons/                           # 图标资源
│       └── 📄 app_icon.png                 # 应用图标
└── 📁 lib/                                 # 源代码目录
    ├── 📄 main.dart                         # 应用入口文件
    ├── 📁 core/                            # 核心模块
    │   ├── 📁 config/                       # 配置文件
    │   │   ├── 📄 android_adaptation_config.dart # 安卓适配配置
    │   │   ├── 📄 deepseek_config.dart      # DeepSeek配置
    │   │   └── 📄 supabase_config.dart      # Supabase配置
    │   ├── 📁 constants/                    # 常量定义
    │   │   └── 📄 app_constants.dart        # 应用常量
    │   ├── 📁 models/                       # 核心数据模型
    │   │   ├── 📄 social_security_model.dart# 社保模型
    │   │   ├── 📄 social_security_model.g.dart# 生成的序列化代码
    │   │   ├── 📄 user_model.dart           # 用户模型
    │   │   └── 📄 user_model.g.dart         # 生成的序列化代码
    │   ├── 📁 network/                      # 网络层
    │   │   └── 📄 api_client.dart          # API客户端封装
    │   ├── 📁 router/                       # 路由管理
    │   │   └── 📄 app_router.dart          # 路由配置
    │   ├── 📁 services/                     # 服务层
    │   │   ├── 📄 connectivity_service.dart # 网络连接服务
    │   │   ├── 📄 storage_service.dart      # 存储服务
    │   │   ├── 📄 supabase_auth_service.dart# Supabase认证服务
    │   │   ├── 📄 supabase_data_service.dart# Supabase数据服务
    │   │   ├── 📄 supabase_service.dart     # Supabase基础服务
    │   │   └── 📄 token_refresh_service.dart# 令牌刷新服务
    │   ├── 📁 theme/                        # 主题配置
    │   │   └── 📄 app_theme.dart           # 应用主题
    │   ├── 📁 utils/                        # 工具类
    │   │   ├── 📄 logger_util.dart         # 日志工具
    │   │   └── 📄 safe_area_utils.dart      # 安全区域工具
    │   └── 📁 widgets/                      # 通用组件
    │       ├── 📄 adaptive_form_container.dart# 自适应表单容器
    │       ├── 📄 common_text_field.dart    # 通用文本输入框
    │       ├── 📄 error_message_widget.dart # 错误消息组件
    │       ├── 📄 gradient_button.dart      # 渐变按钮
    │       └── 📄 safe_area_scaffold.dart   # 安全区域脚手架
    └── 📁 features/                         # 功能模块
        ├── 📁 splash/                       # 启动页模块
        │   └── 📁 presentation/
        │       └── 📁 pages/
        ├── 📁 auth/                         # 认证模块
        │   ├── 📁 domain/                   # 领域层
        │   │   └── 📁 services/             # 领域服务
        │   ├── 📁 models/                   # 数据模型
        │   │   └── 📄 user_model.dart       # 用户模型
        │   ├── 📁 presentation/             # 表现层
        │   │   └── 📁 pages/                # 页面
        │   ├── 📁 providers/                # 状态管理
        │   │   ├── 📄 auth_notifier.dart    # 认证通知器
        │   │   └── 📄 auth_provider.dart    # 认证状态管理
        │   ├── 📁 services/                 # 服务层
        │   │   └── 📄 auth_service.dart     # 认证服务
        │   └── 📁 utils/                    # 工具类
        │       └── 📄 auth_error_handler.dart# 认证错误处理
        ├── 📁 home/                         # 首页模块
        │   ├── 📁 data/                     # 数据层
        │   │   └── 📁 services/             # 数据服务
        │   ├── 📁 models/                   # 数据模型
        │   │   ├── 📄 chat_message.dart     # 聊天消息模型
        │   │   ├── 📄 chat_models.dart      # 聊天相关模型
        │   │   └── 📄 user_context.dart     # 用户上下文模型
        │   ├── 📁 presentation/             # 表现层
        │   │   ├── 📁 pages/                # 页面
        │   │   └── 📁 widgets/              # 组件
        │   └── 📁 services/                 # 服务层
        │       ├── 📄 chat_service.dart     # 聊天服务
        │       └── 📄 deepseek_service.dart # DeepSeek服务
        ├── 📁 recommendation/               # 推荐模块
        ├── 📁 search/                       # 搜索模块
        ├── 📁 settings/                     # 设置模块
        │   └── 📁 presentation/
        │       └── 📁 pages/
        └── 📁 test/                         # 测试模块
            └── 📁 presentation/
                └── 📁 pages/
```

## 🏗️ 架构设计

### 分层架构
项目采用经典的三层架构设计：

1. **表现层 (Presentation Layer)**
   - 📱 页面组件 (Pages)
   - 🎯 状态管理 (Providers)
   - 🧩 UI组件 (Widgets)

2. **业务层 (Business Layer)**
   - 🔄 业务逻辑处理
   - 🔀 数据转换
   - 📊 状态管理

3. **数据层 (Data Layer)**
   - 🌐 网络请求
   - 💾 本地存储
   - 📋 数据模型

### 核心模块详解

#### 🌐 网络层 (Network Layer)
- **ApiClient**: 基于Dio的HTTP客户端封装
- **拦截器系统**: 认证、错误处理、日志记录
- **异常处理**: 统一的API异常处理机制
- **Cookie管理**: 自动化Cookie持久化

#### 🎯 状态管理 (State Management)
- 使用Riverpod进行状态管理
- 支持全局状态和局部状态
- 响应式数据流

#### 🧭 路由管理 (Router Management)
- 基于GoRouter的声明式路由
- 支持嵌套路由和路由守卫
- 类型安全的路由参数

#### 💾 存储系统 (Storage System)
- **SharedPreferences**: 简单键值对存储
- **Hive**: 高性能NoSQL数据库
- **分类存储**: 用户数据、设置数据、缓存数据

#### 🎨 主题系统 (Theme System)
- 支持浅色/深色主题
- 跟随系统主题设置
- 主题持久化存储

#### ✨ 动画系统 (Animation System)
- 预制动画组件
- 可配置的动画参数
- 流畅的用户体验

## 📦 主要依赖

### 核心依赖
- `flutter_riverpod`: 状态管理
- `go_router`: 路由管理
- `dio`: 网络请求
- `hive`: 本地数据库
- `shared_preferences`: 键值对存储

### UI相关
- `flutter_screenutil`: 屏幕适配
- `cached_network_image`: 图片缓存
- `lottie`: 动画支持

### 工具类
- `logger`: 日志记录
- `connectivity_plus`: 网络状态检测
- `device_info_plus`: 设备信息
- `package_info_plus`: 应用信息

## 🚀 快速开始

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 代码生成
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. 运行项目
```bash
flutter run
```

## 📝 开发规范

### 命名规范
- **文件名**: 小写+下划线 (snake_case)
- **类名**: 大驼峰 (PascalCase)
- **变量名**: 小驼峰 (camelCase)
- **常量名**: 大写+下划线 (SCREAMING_SNAKE_CASE)

### 代码组织
- 按功能模块组织代码
- 遵循单一职责原则
- 保持代码简洁和可读性

### 注释规范
- 所有公共API必须添加文档注释
- 复杂业务逻辑添加行内注释
- 使用中文注释说明业务逻辑

## 🔧 扩展指南

### 添加新功能模块
1. 在 `lib/features/` 下创建新的功能目录
2. 按照分层架构组织代码结构
3. 在路由配置中添加新的路由
4. 更新相关的状态管理

### 添加新的API接口
1. 在相应的service中定义接口方法
2. 创建对应的数据模型
3. 添加必要的异常处理
4. 编写单元测试

### 自定义主题
1. 修改 `app_theme.dart` 中的主题配置
2. 添加新的颜色和样式定义
3. 确保浅色和深色主题的一致性

## 📊 项目统计

- **总文件数**: 40+ 个Dart文件
- **代码行数**: 3000+ 行
- **功能模块**: 5个主要模块
- **核心组件**: 20+ 个可复用组件
- **状态管理**: 完整的Riverpod集成
- **网络层**: 完整的API封装和错误处理
- **存储层**: 多层次存储方案
- **动画系统**: 丰富的动画组件库

## 🎯 项目特色

✅ **完整的分层架构设计**  
✅ **现代化的状态管理方案**  
✅ **强大的网络层封装**  
✅ **灵活的主题系统**  
✅ **丰富的动画组件**  
✅ **完善的错误处理机制**  
✅ **类型安全的路由管理**  
✅ **多层次的存储方案**  
✅ **响应式设计支持**  
✅ **完整的开发文档**  

这个Flutter基础项目架构为您提供了一个坚实的开发基础，可以快速开始任何Flutter应用的开发工作！