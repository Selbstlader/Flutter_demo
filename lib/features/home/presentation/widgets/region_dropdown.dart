import 'package:flutter/material.dart';

/// 地区选择下拉框组件
class RegionDropdown extends StatelessWidget {
  final String? selectedRegion;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const RegionDropdown({
    super.key,
    required this.selectedRegion,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 16)),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRegion,
        decoration: InputDecoration(
          labelText: '请选择您所在的城市',
          labelStyle: TextStyle(
            fontSize: _getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getResponsiveRadius(context, 16)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: Container(
            padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
            child: Icon(
              Icons.location_city_rounded,
              color: const Color(0xFF6366F1),
              size: _getResponsiveFontSize(context, 20),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getResponsiveSpacing(context, 16),
            vertical: _getResponsiveSpacing(context, 16),
          ),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF334155),
        ),
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