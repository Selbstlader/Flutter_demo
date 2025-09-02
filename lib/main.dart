import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/services/token_refresh_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/utils/safe_area_utils.dart';
// import 'core/services/app_initializer.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式 - 支持安卓设备底部小白条适配
  SafeAreaUtils.setSystemUIOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: const Color(0xFF0F0F23),
    systemNavigationBarIconBrightness: Brightness.light,
  );
  
  // 设置系统UI模式 - 启用边到边显示
  SafeAreaUtils.showSystemNavigationBar();
  
  // 初始化环境变量
  await dotenv.load(fileName: ".env");
  
  // 初始化Hive
  await Hive.initFlutter();
  
  // 初始化存储服务
  await StorageService.init();
  
  // 初始化Supabase
  await SupabaseService.initialize();
  
  // 初始化应用服务
  // await AppInitializer.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final TokenRefreshService _tokenRefreshService = TokenRefreshService();

  @override
  void dispose() {
    _tokenRefreshService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听认证状态变化
    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (next) {
        _tokenRefreshService.startTokenRefresh();
      } else {
        _tokenRefreshService.stopTokenRefresh();
      }
    });

    return MaterialApp.router(
      title: 'AI智能助手',
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}