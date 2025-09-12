import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 应用文本样式定义
class AppTextStyles {
  // 字体大小常量
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 32.0;
  static const double fontSizeHeading = 28.0;
  static const double fontSizeSubheading = 18.0;
  
  // 字体权重
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // 标题样式
  static const TextStyle title = TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle heading = TextStyle(
    fontSize: fontSizeHeading,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: fontSizeSubheading,
    fontWeight: medium,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  // 正文样式
  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: regular,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // 按钮样式
  static const TextStyle buttonLarge = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: semiBold,
    color: Colors.white,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: medium,
    color: Colors.white,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: medium,
    color: Colors.white,
  );
  
  // 标签样式
  static const TextStyle label = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: medium,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelBold = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  // 提示文本样式
  static const TextStyle hint = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: regular,
    color: AppColors.textHint,
    fontStyle: FontStyle.italic,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: regular,
    color: AppColors.textSecondary,
  );
  
  // 链接样式
  static const TextStyle link = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: medium,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
  );
  
  // 错误样式
  static const TextStyle error = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: regular,
    color: AppColors.errorColor,
  );
  
  // 成功样式
  static const TextStyle success = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: regular,
    color: AppColors.successColor,
  );
  
  // 警告样式
  static const TextStyle warning = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: regular,
    color: AppColors.warningColor,
  );
  
  // 心理测试专用样式
  static const TextStyle questionTitle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle questionDescription = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: regular,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static const TextStyle optionText = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle resultTitle = TextStyle(
    fontSize: fontSizeXLarge,
    fontWeight: bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle resultScore = TextStyle(
    fontSize: fontSizeXXLarge,
    fontWeight: bold,
    color: AppColors.primaryColor,
    height: 1.2,
  );
  
  static const TextStyle resultDescription = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: regular,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // 工具方法：创建带颜色的文本样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  // 工具方法：创建带字体大小的文本样式
  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }
  
  // 工具方法：创建带字体权重的文本样式
  static TextStyle withWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }
  
  // 工具方法：创建带透明度的文本样式
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }
}