import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 空状态组件
class EmptyWidget extends StatelessWidget {
  /// 图标
  final IconData? icon;
  
  /// 标题
  final String? title;
  
  /// 描述
  final String? description;
  
  /// 按钮文本
  final String? buttonText;
  
  /// 按钮点击回调
  final VoidCallback? onButtonPressed;
  
  /// 图标大小
  final double? iconSize;
  
  /// 图标颜色
  final Color? iconColor;

  const EmptyWidget({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize,
    this.iconColor,
  });

  /// 无数据状态
  factory EmptyWidget.noData({
    String? title,
    String? description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyWidget(
      icon: Icons.inbox_outlined,
      title: title ?? '暂无数据',
      description: description ?? '当前没有任何数据',
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  /// 网络错误状态
  factory EmptyWidget.networkError({
    String? title,
    String? description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyWidget(
      icon: Icons.wifi_off_outlined,
      title: title ?? '网络连接失败',
      description: description ?? '请检查网络连接后重试',
      buttonText: buttonText ?? '重试',
      onButtonPressed: onButtonPressed,
    );
  }

  /// 搜索无结果状态
  factory EmptyWidget.searchEmpty({
    String? title,
    String? description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyWidget(
      icon: Icons.search_off_outlined,
      title: title ?? '未找到相关内容',
      description: description ?? '尝试使用其他关键词搜索',
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  /// 服务器错误状态
  factory EmptyWidget.serverError({
    String? title,
    String? description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return EmptyWidget(
      icon: Icons.error_outline,
      title: title ?? '服务器异常',
      description: description ?? '服务器开小差了，请稍后重试',
      buttonText: buttonText ?? '重试',
      onButtonPressed: onButtonPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            if (icon != null)
              Icon(
                icon,
                size: iconSize ?? 80.w,
                color: iconColor ?? Theme.of(context).textTheme.bodySmall?.color,
              ),
            
            if (icon != null) SizedBox(height: 24.h),
            
            // 标题
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            
            if (title != null && description != null) SizedBox(height: 8.h),
            
            // 描述
            if (description != null)
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            
            if ((title != null || description != null) && buttonText != null)
              SizedBox(height: 24.h),
            
            // 按钮
            if (buttonText != null && onButtonPressed != null)
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
          ],
        ),
      ),
    );
  }
}