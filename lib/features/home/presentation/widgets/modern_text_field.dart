import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 现代化文本输入框组件
class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData? icon;
  final String? iconText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    this.icon,
    this.iconText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 10)),
        border: Border.all(
          color: const Color(0xFFE0E6ED),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 15),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3E50),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 13),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7F8C8D),
          ),
          suffixText: suffix,
          suffixStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 13),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A90E2),
          ),
          prefixIcon: iconText != null
              ? Container(
                  width: _getResponsiveSpacing(context, 44),
                  height: _getResponsiveSpacing(context, 44),
                  alignment: Alignment.center,
                  child: Text(
                    iconText!,
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(_getResponsiveSpacing(context, 10)),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4A90E2),
                    size: _getResponsiveFontSize(context, 18),
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 10)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 10)),
            borderSide: const BorderSide(
              color: Color(0xFF4A90E2),
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 10)),
            borderSide: const BorderSide(
              color: Color(0xFFE74C3C),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getResponsiveSpacing(context, 14),
            vertical: _getResponsiveSpacing(context, 14),
          ),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
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

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
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

  double _getResponsiveRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 768) {
      return baseRadius * 1.2;
    }
    return baseRadius;
  }
}