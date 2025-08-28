import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/widgets/safe_area_scaffold.dart';
import '../../../../core/widgets/adaptive_form_container.dart';
import '../../../../core/utils/safe_area_utils.dart';
import '../../../../core/config/android_adaptation_config.dart';

/// 适配测试页面
/// 用于测试各种安卓设备的适配效果
class AdaptationTestPage extends StatefulWidget {
  const AdaptationTestPage({Key? key}) : super(key: key);

  @override
  State<AdaptationTestPage> createState() => _AdaptationTestPageState();
}

class _AdaptationTestPageState extends State<AdaptationTestPage> {
  final TextEditingController _textController = TextEditingController();
  bool _showKeyboard = false;
  int _selectedTab = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      enableSafeArea: true,
      appBar: AppBar(
        title: const Text('适配测试页面'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: AndroidAdaptationConfig.createAdaptiveSystemUIStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          navigationBarColor: const Color(0xFFF5F7FA),
          navigationBarIconBrightness: Brightness.dark,
        ),
      ),
      body: AdaptiveFormContainer(
        enableBottomSafeArea: true,
        enableKeyboardPadding: true,
        child: Column(
          children: [
            // 设备信息卡片
            _buildDeviceInfoCard(),
            
            // 安全区域信息卡片
            _buildSafeAreaInfoCard(),
            
            // 测试功能卡片
            _buildTestFeaturesCard(),
            
            // 键盘测试区域
            _buildKeyboardTestArea(),
            
            const Spacer(),
            
            // 底部测试按钮
            _buildBottomTestButtons(),
          ],
        ),
      ),
      bottomNavigationBar: _buildTestBottomNavigation(),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: const Color(0xFF6366F1),
                  size: ResponsiveUtils.getResponsiveFontSize(context, 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '设备信息',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('设备类型', ResponsiveUtils.getDeviceType(context).name),
            _buildInfoRow('屏幕宽度', '${MediaQuery.of(context).size.width.toInt()}px'),
            _buildInfoRow('屏幕高度', '${MediaQuery.of(context).size.height.toInt()}px'),
            _buildInfoRow('是否全面屏', AndroidAdaptationConfig.isFullScreenDevice(context) ? '是' : '否'),
            _buildInfoRow('有物理按键', AndroidAdaptationConfig.hasPhysicalNavigationKeys(context) ? '是' : '否'),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeAreaInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: const Color(0xFF10B981),
                  size: ResponsiveUtils.getResponsiveFontSize(context, 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '安全区域信息',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('顶部安全区域', '${SafeAreaUtils.getTopSafeArea(context).toInt()}px'),
            _buildInfoRow('底部安全区域', '${SafeAreaUtils.getBottomSafeArea(context).toInt()}px'),
            _buildInfoRow('左侧安全区域', '${SafeAreaUtils.getLeftSafeArea(context).toInt()}px'),
            _buildInfoRow('右侧安全区域', '${SafeAreaUtils.getRightSafeArea(context).toInt()}px'),
            _buildInfoRow('可用高度', '${SafeAreaUtils.getAvailableHeight(context).toInt()}px'),
            _buildInfoRow('可用宽度', '${SafeAreaUtils.getAvailableWidth(context).toInt()}px'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestFeaturesCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: const Color(0xFFEF4444),
                  size: ResponsiveUtils.getResponsiveFontSize(context, 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '测试功能',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testHapticFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('触觉反馈'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testSystemUI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('系统UI'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testFullScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('全屏模式'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testOrientation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('旋转屏幕'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardTestArea() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.keyboard,
                  color: const Color(0xFF6366F1),
                  size: ResponsiveUtils.getResponsiveFontSize(context, 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '键盘适配测试',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '点击输入测试键盘适配',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              onTap: () {
                setState(() {
                  _showKeyboard = true;
                });
              },
              onEditingComplete: () {
                setState(() {
                  _showKeyboard = false;
                });
              },
            ),
            if (_showKeyboard) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '键盘已弹起，页面应自动适配',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTestButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showTestDialog,
              icon: const Icon(Icons.info),
              label: const Text('显示测试对话框'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showTestBottomSheet,
              icon: const Icon(Icons.vertical_align_bottom),
              label: const Text('显示底部面板'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (index) => setState(() => _selectedTab = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: '测试',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  void _testHapticFeedback() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('触觉反馈测试完成')),
    );
  }

  void _testSystemUI() {
    SafeAreaUtils.setSystemUIOverlayStyle(
      statusBarColor: Colors.red.withOpacity(0.3),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.blue.withOpacity(0.3),
      systemNavigationBarIconBrightness: Brightness.dark,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('系统UI样式已更改，3秒后恢复')),
    );
    
    Future.delayed(const Duration(seconds: 3), () {
      SafeAreaUtils.setSystemUIOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFFF5F7FA),
        systemNavigationBarIconBrightness: Brightness.dark,
      );
    });
  }

  void _testFullScreen() {
    SafeAreaUtils.hideSystemNavigationBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已进入全屏模式，3秒后退出')),
    );
    
    Future.delayed(const Duration(seconds: 3), () {
      SafeAreaUtils.showSystemNavigationBar();
    });
  }

  void _testOrientation() {
    final currentOrientation = MediaQuery.of(context).orientation;
    if (currentOrientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('屏幕方向已切换')),
    );
  }

  void _showTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('测试对话框'),
        content: const Text('这是一个测试对话框，用于验证对话框在不同设备上的显示效果。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showTestBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 16 + SafeAreaUtils.getBottomSafeArea(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '测试底部面板',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text('这是一个测试底部面板，用于验证底部面板在不同设备上的显示效果和安全区域适配。'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}