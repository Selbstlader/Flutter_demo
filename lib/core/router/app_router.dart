import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/modern_login_page.dart';
import '../../features/auth/presentation/pages/modern_register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/ai_chat_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String aiChat = '/ai-chat';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const ModernLoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const ModernRegisterPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/ai-chat':
        return MaterialPageRoute(builder: (_) => const AIChatPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
                ),
              ),
              child: const Center(
                child: Text(
                  '页面未找到',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}