import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/animations/fade_in_animation.dart';

/// 设置页
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 外观设置
            FadeInAnimation(
              child: _buildSectionTitle(context, '外观设置'),
            ),
            
            FadeInAnimation(
              delay: const Duration(milliseconds: 100),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('主题模式'),
                      subtitle: Text(_getThemeModeText(themeMode)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeDialog(context, themeModeNotifier),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('语言'),
                      subtitle: const Text('简体中文'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('语言切换功能待实现')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // 通知设置
            FadeInAnimation(
              delay: const Duration(milliseconds: 200),
              child: _buildSectionTitle(context, '通知设置'),
            ),
            
            FadeInAnimation(
              delay: const Duration(milliseconds: 300),
              child: Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('推送通知'),
                      subtitle: const Text('接收应用推送通知'),
                      value: true,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('推送通知已${value ? '开启' : '关闭'}')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration),
                      title: const Text('震动反馈'),
                      subtitle: const Text('操作时提供震动反馈'),
                      value: false,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('震动反馈已${value ? '开启' : '关闭'}')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // 其他设置
            FadeInAnimation(
              delay: const Duration(milliseconds: 400),
              child: _buildSectionTitle(context, '其他'),
            ),
            
            FadeInAnimation(
              delay: const Duration(milliseconds: 500),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('关于应用'),
                      subtitle: const Text('版本 1.0.0'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.feedback_outlined),
                      title: const Text('意见反馈'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('意见反馈功能待实现')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('清除缓存'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showClearCacheDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 获取主题模式文本
  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  /// 显示主题选择对话框
  void _showThemeDialog(BuildContext context, ThemeModeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('浅色模式'),
              onTap: () {
                notifier.setLightTheme();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('深色模式'),
              onTap: () {
                notifier.setDarkTheme();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_mode),
              title: const Text('跟随系统'),
              onTap: () {
                notifier.setSystemTheme();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter Demo',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.flutter_dash,
        size: 48.w,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text('这是一个高度可扩展的Flutter基础项目架构演示应用。'),
        const SizedBox(height: 16),
        const Text('主要特性：'),
        const Text('• 分层架构设计'),
        const Text('• 状态管理 (Riverpod)'),
        const Text('• API封装'),
        const Text('• Cookie管理'),
        const Text('• 动画组件'),
        const Text('• 主题切换'),
      ],
    );
  }

  /// 显示清除缓存对话框
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存清除成功')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}