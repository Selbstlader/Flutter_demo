import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 统一的表单输入框组件
/// 解决双边框线问题，提供一致的样式和交互体验
class UnifiedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? suffix;
  final IconData? icon;
  final String? iconText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final bool enabled;
  final int? maxLines;
  final String? helperText;
  final bool isRequired;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const UnifiedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.suffix,
    this.icon,
    this.iconText,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.isPassword = false,
    this.enabled = true,
    this.maxLines = 1,
    this.helperText,
    this.isRequired = false,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.contentPadding,
  });

  @override
  State<UnifiedTextField> createState() => _UnifiedTextFieldState();
}

class _UnifiedTextFieldState extends State<UnifiedTextField> {
  bool _isPasswordVisible = false;
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        if (widget.label.isNotEmpty) ...[
          _buildLabel(),
          SizedBox(height: _getResponsiveSpacing(8)),
        ],
        
        // 输入框
        _buildTextField(),
        
        // 帮助文本或错误信息
        if (widget.helperText != null || _errorText != null) ...[
          SizedBox(height: _getResponsiveSpacing(6)),
          _buildHelperOrErrorText(),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.label,
            style: TextStyle(
              color: const Color(0xFF374151),
              fontSize: _getResponsiveFontSize(14),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: const Color(0xFFE74C3C),
                fontSize: _getResponsiveFontSize(14),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword && !_isPasswordVisible,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType ?? _getDefaultKeyboardType(),
        inputFormatters: widget.inputFormatters ?? _getDefaultInputFormatters(),
        style: TextStyle(
          color: widget.enabled ? const Color(0xFF2C3E50) : const Color(0xFF9CA3AF),
          fontSize: _getResponsiveFontSize(15),
          fontWeight: FontWeight.w500,
        ),
        decoration: _buildInputDecoration(),
        validator: (value) {
          final error = widget.validator?.call(value);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _errorText = error;
              });
            }
          });
          return error;
        },
        onChanged: widget.onChanged,
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    final hasError = _errorText != null;
    final borderColor = hasError 
        ? (widget.errorBorderColor ?? const Color(0xFFE74C3C))
        : _isFocused 
            ? (widget.focusedBorderColor ?? const Color(0xFF4A90E2))
            : (widget.borderColor ?? const Color(0xFFE0E6ED));
    
    final borderRadius = BorderRadius.circular(
      widget.borderRadius ?? _getResponsiveRadius(10)
    );

    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: TextStyle(
        color: const Color(0xFF9CA3AF),
        fontSize: _getResponsiveFontSize(15),
        fontWeight: FontWeight.w400,
      ),
      suffixText: widget.suffix,
      suffixStyle: TextStyle(
        fontSize: _getResponsiveFontSize(13),
        fontWeight: FontWeight.w500,
        color: hasError 
            ? const Color(0xFFE74C3C)
            : const Color(0xFF4A90E2),
      ),
      prefixIcon: _buildPrefixIcon(),
      suffixIcon: _buildSuffixIcon(),
      filled: true,
      fillColor: widget.enabled 
          ? (widget.backgroundColor ?? const Color(0xFFFAFBFC))
          : const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: widget.borderColor ?? const Color(0xFFE0E6ED),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: widget.focusedBorderColor ?? const Color(0xFF4A90E2),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: widget.errorBorderColor ?? const Color(0xFFE74C3C),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: widget.errorBorderColor ?? const Color(0xFFE74C3C),
          width: 1.5,
        ),
      ),
      contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
        horizontal: _getResponsiveSpacing(14),
        vertical: _getResponsiveSpacing(14),
      ),
      errorStyle: const TextStyle(height: 0), // 隐藏默认错误文本
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.iconText != null) {
      return Container(
        width: _getResponsiveSpacing(44),
        height: _getResponsiveSpacing(44),
        alignment: Alignment.center,
        child: Text(
          widget.iconText!,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(16),
            fontWeight: FontWeight.w600,
            color: _errorText != null 
                ? const Color(0xFFE74C3C)
                : const Color(0xFF4A90E2),
          ),
        ),
      );
    }
    
    if (widget.icon != null) {
      return Container(
        padding: EdgeInsets.all(_getResponsiveSpacing(10)),
        child: Icon(
          widget.icon,
          color: _errorText != null 
              ? const Color(0xFFE74C3C)
              : const Color(0xFF4A90E2),
          size: _getResponsiveFontSize(18),
        ),
      );
    }
    
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible 
              ? Icons.visibility_off_outlined 
              : Icons.visibility_outlined,
          color: const Color(0xFF6B7280),
          size: _getResponsiveFontSize(20),
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }
    return null;
  }

  Widget _buildHelperOrErrorText() {
    final text = _errorText ?? widget.helperText;
    final isError = _errorText != null;
    
    return Text(
      text!,
      style: TextStyle(
        color: isError 
            ? const Color(0xFFE74C3C)
            : const Color(0xFF6B7280),
        fontSize: _getResponsiveFontSize(12),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  TextInputType _getDefaultKeyboardType() {
    if (widget.suffix == '元' || widget.suffix == '%' || widget.suffix == '年' || widget.suffix == '岁') {
      return TextInputType.number;
    }
    return TextInputType.text;
  }

  List<TextInputFormatter> _getDefaultInputFormatters() {
    if (widget.keyboardType == TextInputType.number || 
        widget.suffix == '元' || widget.suffix == '%') {
      return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))];
    }
    if (widget.suffix == '年' || widget.suffix == '岁') {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return [];
  }

  // 响应式设计辅助方法
  double _getResponsiveFontSize(double baseFontSize) {
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

  double _getResponsiveSpacing(double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) {
      return baseSpacing * 1.3;
    } else if (screenWidth > 768) {
      return baseSpacing * 1.2;
    } else if (screenWidth > 414) {
      return baseSpacing * 1.1;
    }
    return baseSpacing;
  }

  double _getResponsiveRadius(double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) {
      return baseRadius * 1.2;
    } else if (screenWidth > 768) {
      return baseRadius * 1.1;
    }
    return baseRadius;
  }
}