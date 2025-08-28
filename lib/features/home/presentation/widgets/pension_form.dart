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
import '../../data/services/calculation_service.dart';

/// 养老金计算表单组件
class PensionForm extends BaseForm {
  const PensionForm({super.key});

  @override
  State<PensionForm> createState() => _PensionFormState();
}

class _PensionFormState extends BaseFormState<PensionForm> {
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  final _currentSalaryController = TextEditingController(text: '10000');
  final _currentAgeController = TextEditingController(text: '30');
  final _retirementAgeController = TextEditingController(text: '60');
  final _paymentYearsController = TextEditingController(text: '30');
  final _socialSecurityBaseController = TextEditingController();
  final _accountBalanceController = TextEditingController(text: '0');

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
    _currentSalaryController.dispose();
    _currentAgeController.dispose();
    _retirementAgeController.dispose();
    _paymentYearsController.dispose();
    _socialSecurityBaseController.dispose();
    _accountBalanceController.dispose();
    super.dispose();
  }

  Future<void> _loadRegionData() async {
    try {
      await CalculationService.loadRegionData();
      final String jsonString =
          await rootBundle.loadString('assets/data/regions.json');
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

        if (_selectedRegion == 'beijing' &&
            _regionData.containsKey('beijing')) {
          final beijingInfo = _regionData['beijing'];
          _socialSecurityBaseController.text =
              beijingInfo['socialSecurityBase'].toString();
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
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();

      final formData = {
        'currentSalary': _currentSalaryController.text,
        'currentAge': _currentAgeController.text,
        'retirementAge': _retirementAgeController.text,
        'paymentYears': _paymentYearsController.text,
        'socialSecurityBase': _socialSecurityBaseController.text,
        'accountBalance': _accountBalanceController.text,
        'region': _selectedRegion ?? 'beijing',
      };
      
      // 检查GoRouter是否可用
      try {
        if (mounted && context.mounted) {
          context.pushNamed('pension-result', extra: formData);
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
      _currentSalaryController.text = '10000';
      _currentAgeController.text = '30';
      _retirementAgeController.text = '60';
      _paymentYearsController.text = '30';
      _socialSecurityBaseController.text = '5869';
      _accountBalanceController.text = '0';
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
                              color: const Color(0xFF27AE60).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.elderly_outlined,
                              color: const Color(0xFF27AE60),
                              size: getResponsiveFontSize(20),
                            ),
                          ),
                          SizedBox(width: getResponsiveSpacing(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '养老金计算',
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(22),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C3E50),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: getResponsiveSpacing(4)),
                                Text(
                                  '预估您的养老金收益情况',
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
                        controller: _currentSalaryController,
                        label: '当前月薪',
                        suffix: '元',
                        iconText: '¥',
                        validator: _validateSalary,
                      ),
                      SizedBox(height: getResponsiveSpacing(20)),
                      Row(
                        children: [
                          Expanded(
                            child: ModernTextField(
                              controller: _currentAgeController,
                              label: '当前年龄',
                              suffix: '岁',
                              icon: Icons.person_outline,
                              validator: _validateAge,
                            ),
                          ),
                          SizedBox(width: getResponsiveSpacing(16)),
                          Expanded(
                            child: ModernTextField(
                              controller: _retirementAgeController,
                              label: '退休年龄',
                              suffix: '岁',
                              icon: Icons.elderly_outlined,
                              validator: _validateRetirementAge,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getResponsiveSpacing(20)),
                      ModernTextField(
                        controller: _paymentYearsController,
                        label: '缴费年限',
                        suffix: '年',
                        icon: Icons.access_time_outlined,
                        validator: _validatePaymentYears,
                      ),
                      SizedBox(height: getResponsiveSpacing(20)),
                      ModernTextField(
                        controller: _socialSecurityBaseController,
                        label: '社保基数',
                        suffix: '元',
                        icon: Icons.shield_outlined,
                        validator: _validateBaseField,
                      ),
                      SizedBox(height: getResponsiveSpacing(20)),
                      ModernTextField(
                        controller: _accountBalanceController,
                        label: '当前账户余额（可选）',
                        suffix: '元',
                        icon: Icons.account_balance_wallet_outlined,
                        validator: _validateAccountBalance,
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
                          text: '计算养老金',
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
      return '请输入当前月薪';
    }
    final salary = double.tryParse(value);
    if (salary == null || salary <= 0) {
      return '请输入有效的月薪';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入当前年龄';
    }
    final age = int.tryParse(value);
    if (age == null || age < 18 || age > 65) {
      return '请输入18-65之间的有效年龄';
    }
    return null;
  }

  String? _validateRetirementAge(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入退休年龄';
    }
    final retirementAge = int.tryParse(value);
    final currentAge = int.tryParse(_currentAgeController.text) ?? 0;
    if (retirementAge == null || retirementAge < 50 || retirementAge > 70) {
      return '请输入50-70之间的退休年龄';
    }
    if (retirementAge <= currentAge) {
      return '退休年龄必须大于当前年龄';
    }
    return null;
  }

  String? _validatePaymentYears(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入缴费年限';
    }
    final years = int.tryParse(value);
    if (years == null || years < 15 || years > 45) {
      return '请输入15-45年之间的缴费年限';
    }
    return null;
  }

  String? _validateBaseField(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入社保基数';
    }
    final base = double.tryParse(value);
    if (base == null || base <= 0) {
      return '请输入有效的社保基数';
    }
    return null;
  }

  String? _validateAccountBalance(String? value) {
    if (value != null && value.isNotEmpty) {
      final balance = double.tryParse(value);
      if (balance == null || balance < 0) {
        return '请输入有效的账户余额';
      }
    }
    return null;
  }
}
