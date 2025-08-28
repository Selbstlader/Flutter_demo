import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/adaptive_form_container.dart';
import '../../../../core/utils/safe_area_utils.dart';
import 'base_form.dart';
import 'modern_card.dart';
import 'modern_text_field.dart';
import 'modern_button.dart';
import 'region_dropdown.dart';

/// 社保计算表单组件
class SocialSecurityForm extends BaseForm {
  const SocialSecurityForm({super.key});

  @override
  State<SocialSecurityForm> createState() => _SocialSecurityFormState();
}

class _SocialSecurityFormState extends BaseFormState<SocialSecurityForm> {
  final _formKey = GlobalKey<FormState>();

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
    _loadRegionData();
  }

  @override
  void dispose() {
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
                fontSize: getResponsiveFontSize(16),
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
      showSnackBar('加载地区数据失败: $e', isError: true);
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
        showSnackBar('导航失败: $e', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareContainer(
      child: AdaptiveFormContainer(
        enableBottomSafeArea: true,
        enableKeyboardPadding: true,
        child: Form(
          key: _formKey,
          child: buildAnimatedWrapper(
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
                              size: getResponsiveFontSize(20),
                            ),
                          ),
                          SizedBox(width: getResponsiveSpacing(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '社保个税计算',
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(22),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C3E50),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: getResponsiveSpacing(4)),
                                Text(
                                  '计算您的社保缴费和个人所得税',
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(14),
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
                      SizedBox(height: getResponsiveSpacing(20)),
                      ModernTextField(
                        controller: _housingFundRateController,
                        label: '公积金缴纳比例',
                        suffix: '%',
                        icon: Icons.percent_outlined,
                        validator: _validateRate,
                      ),
                      SizedBox(height: getResponsiveSpacing(20)),
                      ModernTextField(
                        controller: _specialDeductionController,
                        label: '专项附加扣除',
                        suffix: '元',
                        icon: Icons.receipt_outlined,
                        validator: _validateDeduction,
                      ),
                      SizedBox(height: getResponsiveSpacing(20)),
                      ModernTextField(
                        controller: _socialSecurityBaseController,
                        label: '社保基数',
                        suffix: '元',
                        icon: Icons.shield_outlined,
                        onChanged: (value) => _validateBaseInput(value, 'social'),
                        validator: _validateBaseField,
                      ),
                      SizedBox(height: getResponsiveSpacing(20)),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ModernButton(
                          text: '计算结果',
                          onPressed: _submitForm,
                          isPrimary: true,
                          icon: Icons.calculate_rounded,
                          scaleAnimationController: scaleAnimationController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernButton(
                          text: '重置表单',
                          onPressed: _resetForm,
                          isPrimary: false,
                          icon: Icons.refresh_rounded,
                          scaleAnimationController: scaleAnimationController,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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