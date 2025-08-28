import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'modern_card.dart';
import 'modern_text_field.dart';
import 'modern_button.dart';
import 'region_dropdown.dart';

/// 社保计算表单组件
class SocialSecurityForm extends StatefulWidget {
  const SocialSecurityForm({super.key});

  @override
  State<SocialSecurityForm> createState() => _SocialSecurityFormState();
}

class _SocialSecurityFormState extends State<SocialSecurityForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // 动画控制器
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // 表单控制器
  final _salaryController = TextEditingController(text: '10000');
  final _housingFundRateController = TextEditingController(text: '12');
  final _socialSecurityBaseController = TextEditingController();
  final _housingFundBaseController = TextEditingController();
  final _specialDeductionController = TextEditingController(text: '2000');

  // 地区数据
  Map<String, dynamic> _regionData = {};
  String? _selectedRegion = 'beijing';
  List<DropdownMenuItem<String>> _regionItems = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRegionData();
  }

  void _initAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _salaryController.dispose();
    _housingFundRateController.dispose();
    _socialSecurityBaseController.dispose();
    _housingFundBaseController.dispose();
    _specialDeductionController.dispose();
    super.dispose();
  }

  Future<void> _loadRegionData() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/data/regions.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      setState(() {
        _regionData = data['regions'];
        _regionItems = _regionData.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.value['name'],
              style: TextStyle(
                fontSize: _getResponsiveFontSize(16),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
          );
        }).toList();

        if (_selectedRegion == 'beijing' && _regionData.containsKey('beijing')) {
          final beijingInfo = _regionData['beijing'];
          _socialSecurityBaseController.text =
              beijingInfo['socialSecurityBase'].toString();
          _housingFundBaseController.text =
              beijingInfo['housingFundBase'].toString();
        }
      });
    } catch (e) {
      _showSnackBar('加载地区数据失败: $e', isError: true);
    }
  }

  void _onRegionChanged(String? regionKey) {
    if (regionKey != null && _regionData.containsKey(regionKey)) {
      final regionInfo = _regionData[regionKey];
      setState(() {
        _selectedRegion = regionKey;
        _socialSecurityBaseController.text =
            regionInfo['socialSecurityBase'].toString();
        _housingFundBaseController.text =
            regionInfo['housingFundBase'].toString();
      });
    }
  }

  void _validateBaseInput(String value, String type) {
    if (_selectedRegion == null) return;
    // 可以在这里添加基数验证逻辑
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();

      final formData = {
        'salary': _salaryController.text,
        'housingFundRate': _housingFundRateController.text,
        'socialSecurityBase': _socialSecurityBaseController.text,
        'housingFundBase': _housingFundBaseController.text,
        'specialDeduction': _specialDeductionController.text,
        'region': _selectedRegion ?? 'beijing',
      };

      // 检查GoRouter是否可用
      try {
        if (mounted && context.mounted) {
          context.pushNamed('calculation-result', extra: formData);
        }
      } catch (e) {
        _showSnackBar('导航失败: $e', isError: true);
      }
    }
  }

  void _resetForm() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRegion = 'beijing';
      _salaryController.text = '10000';
      _housingFundRateController.text = '12';
      _socialSecurityBaseController.text = '5869';
      _housingFundBaseController.text = '2320';
      _specialDeductionController.text = '2000';
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? screenWidth * 0.15 : _getResponsiveSpacing(20),
          vertical: _getResponsiveSpacing(24),
        ),
        child: Form(
          key: _formKey,
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, _) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 页面标题
                      ModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.calculate_outlined,
                                    color: const Color(0xFF4A90E2),
                                    size: _getResponsiveFontSize(20),
                                  ),
                                ),
                                SizedBox(width: _getResponsiveSpacing(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '社保个税计算',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(22),
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2C3E50),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(height: _getResponsiveSpacing(4)),
                                      Text(
                                        '计算您的社保缴费和个人所得税',
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(14),
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF7F8C8D),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 地区选择
                      ModernCard(
                        title: '地区选择',
                        icon: Icons.location_on_outlined,
                        child: RegionDropdown(
                          selectedRegion: _selectedRegion,
                          items: _regionItems,
                          onChanged: _onRegionChanged,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请选择地区';
                            }
                            return null;
                          },
                        ),
                      ),

                      // 基本信息
                      ModernCard(
                        title: '基本信息',
                        icon: Icons.person_outline_rounded,
                        child: Column(
                          children: [
                            ModernTextField(
                              controller: _salaryController,
                              label: '税前月薪',
                              suffix: '元',
                              iconText: '¥',
                              validator: _validateSalary,
                            ),
                            SizedBox(height: _getResponsiveSpacing(20)),
                            ModernTextField(
                              controller: _housingFundRateController,
                              label: '公积金缴纳比例',
                              suffix: '%',
                              icon: Icons.percent_outlined,
                              validator: _validateRate,
                            ),
                            SizedBox(height: _getResponsiveSpacing(20)),
                            ModernTextField(
                              controller: _specialDeductionController,
                              label: '专项附加扣除',
                              suffix: '元',
                              icon: Icons.receipt_outlined,
                              validator: _validateDeduction,
                            ),
                            SizedBox(height: _getResponsiveSpacing(20)),
                            ModernTextField(
                              controller: _socialSecurityBaseController,
                              label: '社保基数',
                              suffix: '元',
                              icon: Icons.shield_outlined,
                              onChanged: (value) => _validateBaseInput(value, 'social'),
                              validator: _validateBaseField,
                            ),
                            SizedBox(height: _getResponsiveSpacing(20)),
                            ModernTextField(
                              controller: _housingFundBaseController,
                              label: '公积金基数',
                              suffix: '元',
                              icon: Icons.home_outlined,
                              onChanged: (value) => _validateBaseInput(value, 'housing'),
                              validator: _validateBaseField,
                            ),
                          ],
                        ),
                      ),

                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: ModernButton(
                              text: '计算结果',
                              onPressed: _submitForm,
                              isPrimary: true,
                              icon: Icons.calculate_rounded,
                              scaleAnimationController: _scaleAnimationController,
                            ),
                          ),
                          SizedBox(width: _getResponsiveSpacing(16)),
                          Expanded(
                            child: ModernButton(
                              text: '重置表单',
                              onPressed: _resetForm,
                              isPrimary: false,
                              icon: Icons.refresh_rounded,
                              scaleAnimationController: _scaleAnimationController,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: _getResponsiveSpacing(40)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 响应式尺寸计算
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
      return baseSpacing * 1.4;
    } else if (screenWidth > 768) {
      return baseSpacing * 1.3;
    } else if (screenWidth > 414) {
      return baseSpacing * 1.1;
    }
    return baseSpacing;
  }

  // 表单验证方法
  String? _validateSalary(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入税前月薪';
    }
    final salary = double.tryParse(value);
    if (salary == null || salary <= 0) {
      return '请输入有效的税前月薪';
    }
    return null;
  }

  String? _validateRate(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入公积金缴纳比例';
    }
    final rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > 100) {
      return '请输入0-100之间的有效比例';
    }
    return null;
  }

  String? _validateDeduction(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入专项附加扣除金额';
    }
    final deduction = double.tryParse(value);
    if (deduction == null || deduction < 0) {
      return '请输入有效的专项附加扣除金额';
    }
    return null;
  }

  String? _validateBaseField(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入基数';
    }
    final base = double.tryParse(value);
    if (base == null || base <= 0) {
      return '请输入有效的基数';
    }
    return null;
  }
}