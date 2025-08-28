import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/modern_login_page.dart';
import '../../features/auth/presentation/pages/modern_register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/home/presentation/pages/calculation_result_page.dart';
import '../../features/home/presentation/pages/pension_result_page.dart';
import '../../features/home/presentation/pages/ai_chat_page.dart';

class AppRouter {
  // 路由路径常量
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String aiChat = '/ai-chat';

  static const String settings = '/settings';
  static const String calculationResult = '/calculation-result';
  static const String pensionResult = '/pension-result';

  // GoRouter实例
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );

  // 路由配置
  static final List<RouteBase> _routes = [
    // 根路由 - 欢迎页面
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const WelcomePage(),
    ),

    // 欢迎页面路由
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomePage(),
    ),

    // 认证相关路由
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const ModernLoginPage(),
    ),

    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const ModernRegisterPage(),
    ),

    // 主功能路由
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    // AI聊天路由
    GoRoute(
      path: '/ai-chat',
      name: 'ai-chat',
      builder: (context, state) => const AIChatPage(),
    ),

    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),

    // 计算器结果页面路由
    GoRoute(
      path: '/calculation-result',
      name: 'calculation-result',
      builder: (context, state) {
        final formData = state.extra as Map<String, dynamic>? ?? {};
        return CalculationResultPage(formData: formData);
      },
    ),

    GoRoute(
      path: '/pension-result',
      name: 'pension-result',
      builder: (context, state) {
        final formData = state.extra as Map<String, dynamic>? ?? {};
        return PensionResultPage(formData: formData);
      },
    ),
  ];

  // 错误处理
  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                '页面未找到',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '路径: ${state.uri.toString()}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 保留原始路由生成方法作为备份（已弃用）
  @deprecated
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 此方法已弃用，请使用 AppRouter.router
    throw UnsupportedError('请使用 AppRouter.router 替代 generateRoute');
  }
}
