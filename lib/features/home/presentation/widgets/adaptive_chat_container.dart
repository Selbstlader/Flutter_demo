import 'package:flutter/material.dart';
import '../../../../core/utils/safe_area_utils.dart';
import '../../../../core/widgets/adaptive_form_container.dart';

/// AI聊天页面的自适应容器
/// 专门处理聊天界面在安卓设备上的适配问题
class AdaptiveChatContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool enableKeyboardPadding;
  final ScrollController? scrollController;

  const AdaptiveChatContainer({
    Key? key,
    required this.child,
    this.padding,
    this.enableKeyboardPadding = true,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final double bottomSafeArea = SafeAreaUtils.getBottomSafeArea(context);
    
    // 聊天界面特殊处理：当键盘弹起时，需要额外的间距
    double bottomPadding = bottomSafeArea;
    if (enableKeyboardPadding && keyboardHeight > 0) {
      bottomPadding = keyboardHeight + 8; // 键盘上方留8px间距
    }

    return Container(
      padding: EdgeInsets.only(
        left: SafeAreaUtils.getLeftSafeArea(context),
        right: SafeAreaUtils.getRightSafeArea(context),
        bottom: bottomPadding,
      ),
      child: child,
    );
  }
}

/// 聊天输入框容器
/// 专门处理输入框在不同设备上的适配
class ChatInputContainer extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ChatInputContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  State<ChatInputContainer> createState() => _ChatInputContainerState();
}

class _ChatInputContainerState extends State<ChatInputContainer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double currentKeyboardHeight = mediaQuery.viewInsets.bottom;
    final double bottomSafeArea = SafeAreaUtils.getBottomSafeArea(context);
    
    // 检测键盘状态变化
    if (currentKeyboardHeight != _keyboardHeight) {
      _keyboardHeight = currentKeyboardHeight;
      if (_keyboardHeight > 0) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // 计算底部间距
    double bottomPadding = bottomSafeArea;
    if (_keyboardHeight > 0) {
      bottomPadding = _keyboardHeight + 8;
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          padding: EdgeInsets.only(
            left: (widget.padding?.horizontal ?? 16) / 2,
            right: (widget.padding?.horizontal ?? 16) / 2,
            top: widget.padding?.vertical ?? 12,
            bottom: bottomPadding + (widget.padding?.vertical ?? 12),
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 聊天消息列表容器
/// 处理消息列表的滚动和安全区域适配
class ChatMessageListContainer extends StatelessWidget {
  final Widget child;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  const ChatMessageListContainer({
    Key? key,
    required this.child,
    this.scrollController,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double topSafeArea = SafeAreaUtils.getTopSafeArea(context);
    final double leftSafeArea = SafeAreaUtils.getLeftSafeArea(context);
    final double rightSafeArea = SafeAreaUtils.getRightSafeArea(context);

    return Container(
      padding: EdgeInsets.only(
        top: topSafeArea + (padding?.vertical ?? 8),
        left: leftSafeArea + (padding?.horizontal ?? 16) / 2,
        right: rightSafeArea + (padding?.horizontal ?? 16) / 2,
        bottom: padding?.vertical ?? 8,
      ),
      child: child,
    );
  }
}

/// 响应式聊天气泡
class ResponsiveChatBubble extends StatelessWidget {
  final Widget child;
  final bool isUser;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ResponsiveChatBubble({
    Key? key,
    required this.child,
    required this.isUser,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: screenWidth * 0.75,
      tablet: screenWidth * 0.6,
      desktop: screenWidth * 0.5,
    );

    final double responsivePadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    final double responsiveMargin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    return Container(
      margin: margin ?? EdgeInsets.symmetric(
        vertical: responsiveMargin / 2,
        horizontal: responsiveMargin,
      ),
      child: Row(
        mainAxisAlignment: isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: padding ?? EdgeInsets.all(responsivePadding),
            decoration: BoxDecoration(
              color: backgroundColor ?? (isUser 
                  ? const Color(0xFF6366F1) 
                  : Colors.grey[100]),
              borderRadius: borderRadius ?? BorderRadius.circular(
                ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 16.0,
                  desktop: 20.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}