# Flutter Demo - 高度可扩展的基础项目架构

## 项目概述

这是一个基于Flutter框架构建的高度可扩展基础项目架构，采用分层架构设计，包含完整的状态管理、网络封装、动画组件等核心功能模块。

## 项目特性

- ✨ **分层架构设计** - 数据层/业务层/表现层清晰分离
- 🎯 **状态管理** - 使用Riverpod进行状态管理
- 🌐 **网络封装** - 基于Dio的完整API封装，支持拦截器和错误统一处理
- 🎨 **主题系统** - 支持浅色/深色/跟随系统主题切换
- 📱 **响应式设计** - 使用ScreenUtil适配不同屏幕尺寸
- 🚀 **路由管理** - 基于GoRouter的声明式路由管理
- 💾 **本地存储** - 多层次存储方案(SharedPreferences + Hive)
- 🎭 **动画组件** - 丰富的动画组件库
- 🔧 **工具类封装** - 完整的工具类和扩展方法
- 📝 **日志系统** - 完整的日志记录和调试支持

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── core/                              # 核心模块
│   ├── app.dart                       # 应用主组件
│   ├── constants/                     # 常量定义
│   │   └── app_constants.dart         # 应用常量
│   ├── network/                       # 网络层
│   │   ├── api_client.dart           # API客户端封装
│   │   ├── interceptors/             # 网络拦截器
│   │   │   ├── error_interceptor.dart# 错误处理拦截器
│   │   │   └── logging_interceptor.dart# 日志拦截器
│   │   ├── models/                   # 网络模型
│   │   │   ├── api_response.dart     # API响应基础模型
│   │   │   └── api_response.g.dart   # 生成的序列化代码
│   │   └── exceptions/               # 异常定义
│   │       └── api_exception.dart    # API异常类
│   ├── providers/                    # 全局状态提供者
│   │   └── theme_provider.dart       # 主题状态管理
│   ├── router/                       # 路由管理
│   │   └── app_router.dart          # 路由配置
│   ├── services/                     # 服务层
│   │   └── storage_service.dart     # 存储服务
│   ├── theme/                        # 主题配置
│   │   └── app_theme.dart           # 应用主题
│   ├── utils/                        # 工具类
│   │   └── logger_util.dart         # 日志工具
│   └── widgets/                      # 通用组件
│       └── animations/               # 动画组件
│           ├── fade_in_animation.dart# 淡入动画
│           └── slide_in_animation.dart# 滑入动画
└── features/                         # 功能模块
    ├── splash/                       # 启动页模块
    │   └── presentation/
    │       └── pages/
    │           └── splash_page.dart
    └── home/                         # 首页模块
        └── presentation/
            └── pages/
                └── home_page.dart
```

## 架构设计

### 分层架构

项目采用经典的三层架构设计：

1. **表现层 (Presentation Layer)**
   - 页面组件 (Pages)
   - 状态管理 (Providers)
   - UI组件 (Widgets)

2. **业务层 (Business Layer)**
   - 业务逻辑处理
   - 数据转换
   - 状态管理

3. **数据层 (Data Layer)**
   - 网络请求
   - 本地存储
   - 数据模型

### 核心模块说明

#### 1. 网络层 (Network Layer)
- **ApiClient**: 基于Dio的HTTP客户端封装
- **拦截器系统**: 认证、错误处理、日志记录
- **异常处理**: 统一的API异常处理机制
- **Cookie管理**: 自动化Cookie持久化

#### 2. 状态管理 (State Management)
- 使用Riverpod进行状态管理
- 支持全局状态和局部状态
- 响应式数据流

#### 3. 路由管理 (Router Management)
- 基于GoRouter的声明式路由
- 支持嵌套路由和路由守卫
- 类型安全的路由参数

#### 4. 存储系统 (Storage System)
- SharedPreferences: 简单键值对存储
- Hive: 高性能NoSQL数据库
- 分类存储: 用户数据、设置数据、缓存数据

#### 5. 主题系统 (Theme System)
- 支持浅色/深色主题
- 跟随系统主题设置
- 主题持久化存储

#### 6. 动画系统 (Animation System)
- 预制动画组件
- 可配置的动画参数
- 流畅的用户体验

## 快速开始

### 环境要求

- Flutter SDK: >=3.10.0
- Dart SDK: >=3.0.0

### 安装依赖

```bash
flutter pub get
```

### 代码生成

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 运行项目

```bash
flutter run
```

## 主要依赖

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

## 开发规范

### 命名规范
- 文件名: 小写+下划线 (snake_case)
- 类名: 大驼峰 (PascalCase)
- 变量名: 小驼峰 (camelCase)
- 常量名: 大写+下划线 (SCREAMING_SNAKE_CASE)

### 代码组织
- 按功能模块组织代码
- 遵循单一职责原则
- 保持代码简洁和可读性

### 注释规范
- 所有公共API必须添加文档注释
- 复杂业务逻辑添加行内注释
- 使用中文注释说明业务逻辑

## 扩展指南

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

## 性能优化

- 使用 `const` 构造函数减少重建
- 合理使用 `ListView.builder` 处理长列表
- 图片缓存和懒加载
- 网络请求缓存策略
- 状态管理优化

## 测试

项目支持多层次测试：

- 单元测试: 测试业务逻辑
- 组件测试: 测试UI组件
- 集成测试: 测试完整流程

## 部署

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License

## 更新日志

### v1.0.0
- 初始版本发布
- 完整的基础架构
- 核心功能模块实现

---

**注意**: 这是一个基础架构项目，可以根据具体业务需求进行扩展和定制。