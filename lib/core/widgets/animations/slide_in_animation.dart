import 'package:flutter/material.dart';

/// 滑入方向枚举
enum SlideDirection {
  top,
  bottom,
  left,
  right,
}

/// 滑入动画组件
class SlideInAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;
  
  /// 滑入方向
  final SlideDirection direction;
  
  /// 动画持续时间
  final Duration duration;
  
  /// 延迟时间
  final Duration delay;
  
  /// 动画曲线
  final Curve curve;
  
  /// 滑动距离
  final double offset;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottom,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.offset = 50.0,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    // 根据方向设置初始偏移
    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.top:
        beginOffset = Offset(0, -widget.offset / 100);
        break;
      case SlideDirection.bottom:
        beginOffset = Offset(0, widget.offset / 100);
        break;
      case SlideDirection.left:
        beginOffset = Offset(-widget.offset / 100, 0);
        break;
      case SlideDirection.right:
        beginOffset = Offset(widget.offset / 100, 0);
        break;
    }
    
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    // 延迟启动动画
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}