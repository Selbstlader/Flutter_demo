import 'package:flutter/material.dart';

/// 现代化按钮组件
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final AnimationController? scaleAnimationController;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.scaleAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = scaleAnimationController != null
        ? Tween<double>(
            begin: 1.0,
            end: 0.98,
          ).animate(CurvedAnimation(
            parent: scaleAnimationController!,
            curve: Curves.easeInOut,
          ))
        : null;

    Widget buttonContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        onTapDown: (_) => scaleAnimationController?.forward(),
        onTapUp: (_) => scaleAnimationController?.reverse(),
        onTapCancel: () => scaleAnimationController?.reverse(),
        borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 10)),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: _getResponsiveSpacing(context, 14),
            horizontal: _getResponsiveSpacing(context, 20),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 10)),
            color: isPrimary ? const Color(0xFF4A90E2) : Colors.white,
            border: !isPrimary
                ? Border.all(
                    color: const Color(0xFF4A90E2),
                    width: 1.5,
                  )
                : null,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : const Color(0xFF4A90E2),
                  size: _getResponsiveFontSize(context, 16),
                ),
                SizedBox(width: _getResponsiveSpacing(context, 8)),
              ],
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF4A90E2),
                  fontSize: _getResponsiveFontSize(context, 15),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (scaleAnimation != null) {
      return AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: buttonContent,
          );
        },
      );
    }

    return buttonContent;
  }

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) {
      return baseFontSize * 1.3;
    } else if (screenWidth > 768) {
      return baseFontSize * 1.2;
    } else if (screenWidth > 414) {
      return baseFontSize * 1.1;
    }
    return baseFontSize;
  }

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) {
      return baseSpacing * 1.4;
    } else if (screenWidth > 768) {
      return baseSpacing * 1.3;
    } else if (screenWidth > 414) {
      return baseSpacing * 1.1;
    }
    return baseSpacing;
  }

  double _getResponsiveRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 768) {
      return baseRadius * 1.2;
    }
    return baseRadius;
  }
}