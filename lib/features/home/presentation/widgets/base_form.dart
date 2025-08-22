import 'package:flutter/material.dart';

/// 表单基类 - 提供通用的响应式布局和动画功能
abstract class BaseForm extends StatefulWidget {
  const BaseForm({super.key});
}

abstract class BaseFormState<T extends BaseForm> extends State<T> 
    with TickerProviderStateMixin {
  
  // 通用动画控制器
  late AnimationController slideAnimationController;
  late AnimationController scaleAnimationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    initAnimations();
  }

  @override
  void dispose() {
    slideAnimationController.dispose();
    scaleAnimationController.dispose();
    super.dispose();
  }

  /// 初始化动画
  void initAnimations() {
    slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: slideAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    slideAnimationController.forward();
  }

  /// 响应式字体大小计算
  double getResponsiveFontSize(double baseFontSize) {
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

  /// 响应式间距计算
  double getResponsiveSpacing(double baseSpacing) {
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

  /// 响应式圆角计算
  double getResponsiveRadius(double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 768) {
      return baseRadius * 1.2;
    }
    return baseRadius;
  }

  /// 显示提示信息
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
      ),
    );
  }

  /// 通用容器装饰
  BoxDecoration get containerDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF8FAFC),
        Color(0xFFE2E8F0),
      ],
    ),
  );

  /// 构建动画包装器
  Widget buildAnimatedWrapper({required Widget child}) {
    return AnimatedBuilder(
      animation: slideAnimation,
      builder: (context, _) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}