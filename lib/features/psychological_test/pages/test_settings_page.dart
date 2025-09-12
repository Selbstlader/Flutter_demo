import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/safe_area_scaffold.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TestSettingsPage extends StatefulWidget {
  const TestSettingsPage({super.key});

  @override
  State<TestSettingsPage> createState() => _TestSettingsPageState();
}

class _TestSettingsPageState extends State<TestSettingsPage> {
  bool _notificationsEnabled = true;
  bool _reminderEnabled = true;
  bool _dataAnalyticsEnabled = true;
  bool _autoSaveEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  int _reminderFrequency = 7; // 天数
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await StorageService.getTestSettings();
      if (settings != null) {
        setState(() {
          _notificationsEnabled = settings['notificationsEnabled'] ?? true;
          _reminderEnabled = settings['reminderEnabled'] ?? true;
          _dataAnalyticsEnabled = settings['dataAnalyticsEnabled'] ?? true;
          _autoSaveEnabled = settings['autoSaveEnabled'] ?? true;
          _reminderFrequency = settings['reminderFrequency'] ?? 7;
          
          if (settings['reminderTime'] != null) {
            final timeString = settings['reminderTime'] as String;
            final parts = timeString.split(':');
            _reminderTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('加载设置失败: ${e.toString()}');
    }
  }

  Future<void> _saveSettings() async {
    try {
      setState(() => _isLoading = true);
      
      final settings = {
        'notificationsEnabled': _notificationsEnabled,
        'reminderEnabled': _reminderEnabled,
        'dataAnalyticsEnabled': _dataAnalyticsEnabled,
        'autoSaveEnabled': _autoSaveEnabled,
        'reminderFrequency': _reminderFrequency,
        'reminderTime': '${_reminderTime.hour}:${_reminderTime.minute}',
      };
      
      await StorageService.saveTestSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('保存设置失败: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await _showConfirmDialog(
      '清除所有数据',
      '确定要清除所有测试数据吗？此操作将删除所有测试记录和结果，且不可恢复。',
      confirmText: '清除',
      isDestructive: true,
    );
    
    if (confirmed) {
      try {
        setState(() => _isLoading = true);
        await StorageService.clearAllTestData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('所有数据已清除'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        _showErrorSnackBar('清除数据失败: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportData() async {
    try {
      setState(() => _isLoading = true);
      
      final exportData = await StorageService.exportTestData();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('导出数据'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('数据导出成功！'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '导出统计:',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '测试会话: ${exportData['sessions']?.length ?? 0} 个',
                        style: AppTextStyles.bodySmall,
                      ),
                      Text(
                        '测试结果: ${exportData['results']?.length ?? 0} 个',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '数据已保存到应用文档目录，您可以通过文件管理器访问。',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('导出数据失败: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<bool> _showConfirmDialog(
    String title,
    String content, {
    String confirmText = '确定',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: AppBar(
        title: const Text('测试设置'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: '保存设置',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSectionTitle('通知设置'),
                    _buildSwitchTile(
                      title: '启用通知',
                      subtitle: '接收测试相关的通知消息',
                      value: _notificationsEnabled,
                      onChanged: (value) => setState(() => _notificationsEnabled = value),
                      icon: Icons.notifications,
                    ),
                    _buildSwitchTile(
                      title: '测试提醒',
                      subtitle: '定期提醒进行心理健康测试',
                      value: _reminderEnabled,
                      onChanged: (value) => setState(() => _reminderEnabled = value),
                      icon: Icons.schedule,
                    ),
                    if (_reminderEnabled) ...[
                      _buildReminderSettings(),
                    ],
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('数据设置'),
                    _buildSwitchTile(
                      title: '数据分析',
                      subtitle: '允许分析测试数据以改善服务',
                      value: _dataAnalyticsEnabled,
                      onChanged: (value) => setState(() => _dataAnalyticsEnabled = value),
                      icon: Icons.analytics,
                    ),
                    _buildSwitchTile(
                      title: '自动保存',
                      subtitle: '自动保存测试进度和结果',
                      value: _autoSaveEnabled,
                      onChanged: (value) => setState(() => _autoSaveEnabled = value),
                      icon: Icons.save,
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('数据管理'),
                    _buildActionTile(
                      title: '导出数据',
                      subtitle: '导出所有测试数据到本地文件',
                      icon: Icons.file_download,
                      onTap: _exportData,
                    ),
                    _buildActionTile(
                      title: '清除所有数据',
                      subtitle: '删除所有测试记录和结果',
                      icon: Icons.delete_forever,
                      onTap: _clearAllData,
                      isDestructive: true,
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('关于'),
                    _buildInfoTile(
                      title: '应用版本',
                      subtitle: '1.0.0',
                      icon: Icons.info,
                    ),
                    _buildActionTile(
                      title: '隐私政策',
                      subtitle: '查看我们的隐私保护政策',
                      icon: Icons.privacy_tip,
                      onTap: () {
                        // TODO: 打开隐私政策页面
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('隐私政策功能开发中')),
                        );
                      },
                    ),
                    _buildActionTile(
                      title: '用户协议',
                      subtitle: '查看用户服务协议',
                      icon: Icons.description,
                      onTap: () {
                        // TODO: 打开用户协议页面
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('用户协议功能开发中')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        secondary: Icon(
          icon,
          color: AppColors.primary,
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? AppColors.error : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提醒设置',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '提醒时间',
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              GestureDetector(
                onTap: _selectReminderTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.repeat,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '提醒频率',
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              DropdownButton<int>(
                value: _reminderFrequency,
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('每天')),
                  DropdownMenuItem(value: 3, child: Text('每3天')),
                  DropdownMenuItem(value: 7, child: Text('每周')),
                  DropdownMenuItem(value: 14, child: Text('每两周')),
                  DropdownMenuItem(value: 30, child: Text('每月')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reminderFrequency = value);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}