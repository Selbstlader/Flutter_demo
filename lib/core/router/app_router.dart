import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// 路由配置类
class AppRouter {
  // 私有构造函数，防止实例化
  AppRouter._();

  /// 路由配置
  static final GoRouter _router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    debugLogDiagnostics: true,
    routes: [
      // 启动页
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // 主页
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
    
    // 错误页面处理
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面未找到: ${state.error}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
    
    // 路由重定向逻辑
    redirect: (context, state) {
      // 这里可以添加登录状态检查等逻辑
      // 例如：如果用户未登录且不在登录页，则重定向到登录页
      return null; // 暂时不做重定向
    },
  );

  /// 获取路由实例
  static GoRouter get router => _router;
}

/// 路由Provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// 路由扩展方法
extension AppRouterExtension on BuildContext {
  /// 导航到指定路由
  void pushNamed(String name, {Map<String, String>? pathParameters, Object? extra}) {
    GoRouter.of(this).pushNamed(name, pathParameters: pathParameters ?? {}, extra: extra);
  }

  /// 替换当前路由
  void goNamed(String name, {Map<String, String>? pathParameters, Object? extra}) {
    GoRouter.of(this).goNamed(name, pathParameters: pathParameters ?? {}, extra: extra);
  }

  /// 返回上一页
  void pop([Object? result]) {
    GoRouter.of(this).pop(result);
  }

  /// 清空路由栈并导航到指定路由
  void goAndClearStack(String location) {
    while (GoRouter.of(this).canPop()) {
      GoRouter.of(this).pop();
    }
    GoRouter.of(this).go(location);
  }
}