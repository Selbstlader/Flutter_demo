import 'package:flutter/material.dart';

/// 现代化卡片组件
class ModernCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ModernCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.only(bottom: _getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 24,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE0E6ED),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 12)),
        child: Container(
          padding: padding ?? EdgeInsets.all(_getResponsiveSpacing(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    if (icon != null) ...[ 
                      Container(
                        padding: EdgeInsets.all(_getResponsiveSpacing(context, 8)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 8)),
                        ),
                        child: Icon(
                          icon,
                          color: const Color(0xFF4A90E2),
                          size: _getResponsiveFontSize(context, 18),
                        ),
                      ),
                      SizedBox(width: _getResponsiveSpacing(context, 12)),
                    ],
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _getResponsiveSpacing(context, 16)),
              ],
              child,
            ],
          ),
        ),
      ),
    );
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