import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_notifier.dart';

/// 通用渐变按钮组件
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool showLoading;
  final double? width;
  final double height;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.showLoading = false,
    this.width,
    this.height = 56,
    this.gradientColors,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradientColors = gradientColors ?? 
        [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(12);
    final defaultBoxShadow = boxShadow ?? [
      BoxShadow(
        color: const Color(0xFF6366F1).withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: defaultGradientColors,
        ),
        borderRadius: defaultBorderRadius,
        boxShadow: defaultBoxShadow,
      ),
      child: ElevatedButton(
        onPressed: showLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: defaultBorderRadius,
          ),
        ),
        child: showLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// 带AuthProvider集成的渐变按钮
class AuthGradientButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AuthGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 56,
    this.gradientColors,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    
    return GradientButton(
      text: text,
      onPressed: onPressed,
      showLoading: isLoading,
      width: width,
      height: height,
      gradientColors: gradientColors,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
    );
  }
}