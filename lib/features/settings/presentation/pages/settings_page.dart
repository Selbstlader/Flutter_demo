import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/services/auth_api_service.dart';
import '../../../../core/router/app_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF64748B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '设置',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAccountSection(),
            const SizedBox(height: 24),
            _buildToolsSection(),
            const SizedBox(height: 24),
            _buildPrivacySection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 构建区块容器
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // 构建账户设置区块
  Widget _buildAccountSection() {
    return _buildSection(
      title: '账户设置',
      children: [
        _buildSettingItem(
          icon: Icons.person_outline,
          title: '个人信息',
          subtitle: '管理您的个人资料',
          onTap: () {
            context.push(AppRouter.userProfile);
          },
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: Icons.security_rounded,
          title: '账户安全',
          subtitle: '密码、验证方式',
          onTap: () {},
        ),
      ],
    );
  }

  // 构建工具区块
  Widget _buildToolsSection() {
    return _buildSection(
      title: '健康工具',
      children: [
        _buildSettingItem(
          icon: Icons.psychology,
          title: '心理健康测试',
          subtitle: '专业心理评估工具',
          onTap: () {
            context.push(AppRouter.psychologicalTest);
          },
        ),
      ],
    );
  }

  // 构建隐私设置区块
  Widget _buildPrivacySection() {
    return _buildSection(
      title: '隐私设置',
      children: [
        _buildSettingItem(
          icon: Icons.privacy_tip_outlined,
          title: '隐私设置',
          subtitle: '数据使用权限',
          onTap: () {},
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: Icons.data_usage,
          title: '数据管理',
          subtitle: '清理缓存和数据',
          onTap: () {},
        ),
      ],
    );
  }

  // 构建通知设置区块
  Widget _buildNotificationSection() {
    return _buildSection(
      title: '应用设置',
      children: [
        _buildSwitchItem(
          icon: Icons.notifications_outlined,
          title: '推送通知',
          subtitle: '接收重要消息提醒',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchItem(
          icon: Icons.light_mode_outlined,
          title: '浅色模式',
          subtitle: '清爽界面，护眼舒适',
          value: !_darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = !value;
            });
          },
        ),
      ],
    );
  }

  // 构建关于区块
  Widget _buildAboutSection() {
    return _buildSection(
      title: '帮助与支持',
      children: [
        _buildSettingItem(
          icon: Icons.help_outline,
          title: '使用帮助',
          subtitle: '常见问题解答',
          onTap: () {},
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: Icons.feedback_outlined,
          title: '意见反馈',
          subtitle: '告诉我们您的建议',
          onTap: () {},
        ),
        _buildDivider(),
        _buildSettingItem(
          icon: Icons.info_outline,
          title: '关于我们',
          subtitle: '版本信息和团队介绍',
          onTap: () {},
        ),
      ],
    );
  }

  // 构建分割线
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFF94A3B8),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6366F1),
        activeTrackColor: const Color(0xFF6366F1).withOpacity(0.3),
        inactiveThumbColor: const Color(0xFF94A3B8),
        inactiveTrackColor: const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '确认退出',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            '您确定要退出登录吗？',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                // 这里添加退出登录的逻辑
                context.go(AppRouter.welcome);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('退出'),
            ),
          ],
        );
      },
    );
  }
}