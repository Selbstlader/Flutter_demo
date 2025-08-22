import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/app.dart';
import 'core/app_initializer.dart';

/// 应用程序入口点
void main() async {
  // 初始化应用
  await AppInitializer.initialize();
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

/// 主应用组件
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // 设计稿尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const App();
      },
    );
  }
}