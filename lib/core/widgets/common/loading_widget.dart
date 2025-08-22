import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 加载组件
class LoadingWidget extends StatelessWidget {
  /// 加载文本
  final String? text;
  
  /// 加载指示器大小
  final double? size;
  
  /// 加载指示器颜色
  final Color? color;
  
  /// 是否显示文本
  final bool showText;

  const LoadingWidget({
    super.key,
    this.text,
    this.size,
    this.color,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40.w,
            height: size ?? 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          if (showText && text != null) ...[
            SizedBox(height: 16.h),
            Text(
              text!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 全屏加载组件
class FullScreenLoading extends StatelessWidget {
  /// 加载文本
  final String? text;
  
  /// 背景颜色
  final Color? backgroundColor;

  const FullScreenLoading({
    super.key,
    this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: LoadingWidget(text: text ?? '加载中...'),
    );
  }
}

/// 覆盖层加载组件
class OverlayLoading extends StatelessWidget {
  /// 是否显示
  final bool isLoading;
  
  /// 子组件
  final Widget child;
  
  /// 加载文本
  final String? text;
  
  /// 背景颜色
  final Color? backgroundColor;

  const OverlayLoading({
    super.key,
    required this.isLoading,
    required this.child,
    this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.3),
            child: LoadingWidget(text: text ?? '加载中...'),
          ),
      ],
    );
  }
}