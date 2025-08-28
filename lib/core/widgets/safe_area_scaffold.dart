import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/safe_area_utils.dart';

/// 安全区域适配的Scaffold
/// 自动处理安卓设备底部小白条的适配问题
class SafeAreaScaffold extends StatefulWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool automaticallyImplyLeading;
  final EdgeInsetsGeometry? padding;
  final bool enableSafeArea;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const SafeAreaScaffold({
    Key? key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.automaticallyImplyLeading = true,
    this.padding,
    this.enableSafeArea = true,
    this.systemOverlayStyle,
  }) : super(key: key);

  @override
  State<SafeAreaScaffold> createState() => _SafeAreaScaffoldState();
}

class _SafeAreaScaffoldState extends State<SafeAreaScaffold> {
  @override
  void initState() {
    super.initState();
    _setupSystemUI();
  }

  void _setupSystemUI() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.systemOverlayStyle != null) {
        SystemChrome.setSystemUIOverlayStyle(widget.systemOverlayStyle!);
      } else {
        // 默认系统UI样式
        SafeAreaUtils.setSystemUIOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: widget.backgroundColor ?? Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = widget.body ?? const SizedBox.shrink();
    
    // 如果启用安全区域适配
    if (widget.enableSafeArea) {
      body = SafeArea(
        top: widget.appBar == null,
        bottom: widget.bottomNavigationBar == null,
        left: true,
        right: true,
        child: body,
      );
    }
    
    // 添加自定义padding
    if (widget.padding != null) {
      body = Padding(
        padding: widget.padding!,
        child: body,
      );
    }

    return Scaffold(
      appBar: widget.appBar,
      body: body,
      bottomNavigationBar: widget.bottomNavigationBar != null
          ? _buildBottomNavigationBar()
          : null,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
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
        child: widget.bottomNavigationBar!,
      ),
    );
  }
}

/// 安全区域适配的Container
class SafeAreaContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final bool enableBottomSafeArea;
  final bool enableTopSafeArea;
  final bool enableLeftSafeArea;
  final bool enableRightSafeArea;

  const SafeAreaContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.enableBottomSafeArea = true,
    this.enableTopSafeArea = false,
    this.enableLeftSafeArea = false,
    this.enableRightSafeArea = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry finalPadding = padding ?? EdgeInsets.zero;
    
    // 添加安全区域padding
    if (enableBottomSafeArea) {
      final double bottomSafeArea = SafeAreaUtils.getBottomSafeArea(context);
      finalPadding = finalPadding.add(EdgeInsets.only(bottom: bottomSafeArea));
    }
    
    if (enableTopSafeArea) {
      final double topSafeArea = SafeAreaUtils.getTopSafeArea(context);
      finalPadding = finalPadding.add(EdgeInsets.only(top: topSafeArea));
    }
    
    if (enableLeftSafeArea) {
      final double leftSafeArea = SafeAreaUtils.getLeftSafeArea(context);
      finalPadding = finalPadding.add(EdgeInsets.only(left: leftSafeArea));
    }
    
    if (enableRightSafeArea) {
      final double rightSafeArea = SafeAreaUtils.getRightSafeArea(context);
      finalPadding = finalPadding.add(EdgeInsets.only(right: rightSafeArea));
    }

    return Container(
      padding: finalPadding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      child: child,
    );
  }
}

/// 响应式布局Widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}