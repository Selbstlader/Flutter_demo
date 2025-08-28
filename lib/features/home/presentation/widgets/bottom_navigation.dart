import 'package:flutter/material.dart';

/// 带有中间圆形突起AI图标的自定义底部导航栏
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final VoidCallback? onAITap;
  final VoidCallback? onSettingsTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onAITap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 底部导航栏背景
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 左侧导航项
              _buildNavItem(
                context,
                items[0],
                0,
                currentIndex == 0,
              ),
              // 中间空白区域（为圆形按钮留空间）
              const SizedBox(width: 60),
              // 右侧导航项
              _buildNavItem(
                context,
                items[1],
                1,
                currentIndex == 1,
              ),
              // 设置按钮
              // _buildSettingsButton(context),
            ],
          ),
        ),
        // 中间圆形突起AI按钮
        Positioned(
          top: -20,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: _buildAIButton(context),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavigationBarItem item,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF6366F1).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon is Icon ? (item.icon as Icon).icon : Icons.home,
                color: isSelected 
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF64748B),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label ?? '',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 12),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIButton(BuildContext context) {
    return GestureDetector(
      onTap: onAITap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B6B), // 改为红色
                Color(0xFF4ECDC4), // 改为青色
              ],
            ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景光晕效果
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // AI图标
            const Center(
              child: Icon(
                Icons.auto_awesome_rounded, // 改为星星图标
                color: Colors.white,
                size: 32, // 增大尺寸
              ),
            ),
            // 闪烁动画点
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: onSettingsTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   padding: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: Colors.transparent,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: const Icon(
            //     Icons.settings_outlined,
            //     color: Color(0xFF64748B),
            //     size: 24,
            //   ),
            // ),
            // const SizedBox(height: 4),
            // Text(
            //   '设置',
            //   style: TextStyle(
            //     fontSize: _getResponsiveFontSize(context, 12),
            //     fontWeight: FontWeight.w500,
            //     color: const Color(0xFF64748B),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 768) {
      return baseFontSize * 1.2;
    } else if (screenWidth > 414) {
      return baseFontSize * 1.1;
    }
    return baseFontSize;
  }
}
