import 'package:flutter/material.dart';
import '../../../../core/utils/safe_area_utils.dart';

/// 带有中央AI按钮的底部导航栏 - 支持安全区域适配
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final VoidCallback? onAITap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onAITap,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = SafeAreaUtils.getBottomSafeArea(context);
    final bool hasBottomNav = SafeAreaUtils.hasBottomNavigationBar(context);

    // 计算底部导航栏的总高度，包含安全区域和凸起按钮
    final double totalHeight = 90 + (hasBottomNav ? bottomSafeArea : 16);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 底部导航栏背景
        Container(
          height: totalHeight,
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
          child: Column(
            children: [
              // 导航栏内容
              SizedBox(
                height: 90,
                child: Row(
                  children: [
                    // 左侧 - 社保计算
                    Expanded(
                      child: _buildNavItem(
                        context,
                        items[0],
                        0,
                        currentIndex == 0,
                      ),
                    ),
                    // 中央空间 - 为AI按钮预留
                    const SizedBox(width: 80),
                    // 右侧 - 养老金计算
                    Expanded(
                      child: _buildNavItem(
                        context,
                        items[1],
                        1,
                        currentIndex == 1,
                      ),
                    ),
                  ],
                ),
              ),
              // 底部安全区域
              if (hasBottomNav)
                SizedBox(height: bottomSafeArea)
              else
                const SizedBox(height: 16),
            ],
          ),
        ),
        // 中央凸起的AI按钮
        Positioned(
          top: -20,
          left: MediaQuery.of(context).size.width / 2 - 35,
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

  /// 构建中央凸起的AI按钮
  Widget _buildAIButton(BuildContext context) {
    return GestureDetector(
      onTap: onAITap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 0,
              offset: const Offset(0, 0),
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Icon(
          Icons.support_agent_rounded,
          color: Colors.white,
          size: 32,
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
