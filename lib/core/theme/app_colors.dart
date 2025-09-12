import 'package:flutter/material.dart';

/// 应用颜色定义
class AppColors {
  // 主色调
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color primary = primaryColor; // 别名，保持兼容性
  static const Color error = errorColor; // 别名，保持兼容性
  static const Color background = darkBackground;
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B); // 别名，保持兼容性
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // 背景色
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFF1F5F9);
  
  // 文本颜色
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF4B5563);
  static const Color textLight = Color(0xFF1F2937);
  static const Color textLightSecondary = Color(0xFF6B7280);
  
  // 边框颜色
  static const Color borderColor = Color(0xFF374151);
  static const Color borderLightColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFF374151);
  static const Color dividerLightColor = Color(0xFFE5E7EB);
  
  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkBackground,
      Color(0xFF16213E),
      darkSurface,
    ],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [successColor, Color(0xFF059669)],
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorColor, Color(0xFFDC2626)],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warningColor, Color(0xFFD97706)],
  );
  
  // 心理测试专用颜色
  static const Color psychTestPrimary = Color(0xFF8B5CF6);
  static const Color psychTestSecondary = Color(0xFF06B6D4);
  static const Color psychTestAccent = Color(0xFF10B981);
  
  // 情绪状态颜色
  static const Color emotionPositive = Color(0xFF10B981);
  static const Color emotionNeutral = Color(0xFF6B7280);
  static const Color emotionNegative = Color(0xFFEF4444);
  
  // 风险等级颜色
  static const Color riskLow = Color(0xFF10B981);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color riskHigh = Color(0xFFEF4444);
  
  // 透明度变体
  static Color get primaryWithOpacity => primaryColor.withOpacity(0.1);
  static Color get secondaryWithOpacity => secondaryColor.withOpacity(0.1);
  static Color get accentWithOpacity => accentColor.withOpacity(0.1);
  static Color get errorWithOpacity => errorColor.withOpacity(0.1);
  static Color get warningWithOpacity => warningColor.withOpacity(0.1);
  static Color get successWithOpacity => successColor.withOpacity(0.1);
  
  // 阴影颜色
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}