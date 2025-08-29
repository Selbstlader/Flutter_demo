/// 应用程序常量配置
class AppConstants {
  // 私有构造函数，防止实例化
  AppConstants._();

  /// API相关常量
  static const String baseUrl = 'https://api.example.com';
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒
  static const int sendTimeout = 30000; // 30秒

  /// Hive box names
  static const String userBoxName = 'user_box';
  static const String cacheBoxName = 'cache_box';

  /// 缓存键名
  static const String userTokenKey = 'user_token';
  static const String userInfoKey = 'user_info';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  /// 动画持续时间
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  /// 页面路由名称
  static const String splashRoute = '/splash';
  static const String homeRoute = '/home';
}