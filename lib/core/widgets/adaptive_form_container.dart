import 'package:flutter/material.dart';
import '../utils/safe_area_utils.dart';

/// 自适应表单容器
/// 专门处理表单在不同设备上的布局适配
class AdaptiveFormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableKeyboardPadding;
  final bool enableBottomSafeArea;
  final ScrollController? scrollController;
  final bool shrinkWrap;

  const AdaptiveFormContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.enableKeyboardPadding = true,
    this.enableBottomSafeArea = true,
    this.scrollController,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final double bottomSafeArea = SafeAreaUtils.getBottomSafeArea(context);

    // 计算可用高度
    double availableHeight = screenHeight -
        SafeAreaUtils.getTopSafeArea(context) -
        (enableBottomSafeArea ? bottomSafeArea : 0);

    // 如果键盘弹起，减去键盘高度
    if (enableKeyboardPadding && keyboardHeight > 0) {
      availableHeight -= keyboardHeight;
    }

    EdgeInsetsGeometry finalPadding = padding ?? const EdgeInsets.all(16.0);

    // 响应式padding调整
    final double responsivePadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    if (padding == null) {
      finalPadding = EdgeInsets.all(responsivePadding);
    }

    Widget content = Container(
      margin: margin,
      padding: finalPadding,
      child: child,
    );

    // 如果内容可能超出屏幕，使用滚动视图
    if (!shrinkWrap) {
      content = SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: availableHeight - (finalPadding.vertical),
          ),
          child: IntrinsicHeight(
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}

/// 响应式卡片容器
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double responsivePadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    final double responsiveMargin = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    final double responsiveBorderRadius = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    return Container(
      margin: margin ?? EdgeInsets.all(responsiveMargin),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius:
            borderRadius ?? BorderRadius.circular(responsiveBorderRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(responsivePadding),
        child: child,
      ),
    );
  }
}

/// 自适应按钮容器
class AdaptiveButtonContainer extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? padding;
  final bool enableBottomSafeArea;

  const AdaptiveButtonContainer({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
    this.enableBottomSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea =
        enableBottomSafeArea ? SafeAreaUtils.getBottomSafeArea(context) : 0;

    final double responsivePadding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );

    EdgeInsetsGeometry finalPadding = padding ??
        EdgeInsets.only(
          left: responsivePadding,
          right: responsivePadding,
          top: responsivePadding,
          bottom: responsivePadding + bottomSafeArea,
        );

    return Container(
      width: double.infinity,
      padding: finalPadding,
      child: ResponsiveUtils.getDeviceType(context) == DeviceType.mobile
          ? Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            )
          : Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children:
                  children.map((child) => Expanded(child: child)).toList(),
            ),
    );
  }
}

/// 键盘感知容器
class KeyboardAwareContainer extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;

  const KeyboardAwareContainer({
    Key? key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<KeyboardAwareContainer> createState() => _KeyboardAwareContainerState();
}

class _KeyboardAwareContainerState extends State<KeyboardAwareContainer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double currentKeyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    if (currentKeyboardHeight != _keyboardHeight) {
      _keyboardHeight = currentKeyboardHeight;
      if (_keyboardHeight > 0) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_keyboardHeight * _animation.value * 0.3),
          child: widget.child,
        );
      },
    );
  }
}
