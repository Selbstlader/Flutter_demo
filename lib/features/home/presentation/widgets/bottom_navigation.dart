import 'package:flutter/material.dart';

/// 简洁的两项底部导航栏
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 社保计算导航项
          _buildNavItem(
            context,
            items[0],
            0,
            currentIndex == 0,
          ),
          // 养老金计算导航项
          _buildNavItem(
            context,
            items[1],
            1,
            currentIndex == 1,
          ),
        ],
      ),
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
