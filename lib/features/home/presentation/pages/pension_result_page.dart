import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widgets/modern_text_field.dart';
import '../widgets/modern_button.dart';
import '../widgets/region_dropdown.dart';
import '../../data/services/calculation_service.dart';

/// 养老金计算结果页面
class PensionResultPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const PensionResultPage({
    super.key,
    required this.formData,
  });

  @override
  State<PensionResultPage> createState() => _PensionResultPageState();
}

class _PensionResultPageState extends State<PensionResultPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic> _calculationResult = {};
  
  // 新增输入框控制器
  final _localAvgSalaryController = TextEditingController();
  final _paidYearsController = TextEditingController();
  
  // 地区数据
  Map<String, dynamic> _regionData = {};
  String? _selectedRegion;
  List<DropdownMenuItem<String>> _regionItems = [];
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRegionData();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _localAvgSalaryController.dispose();
    _paidYearsController.dispose();
    super.dispose();
  }

  Future<void> _loadRegionData() async {
    try {
      await CalculationService.loadRegionData();
      final String jsonString = await rootBundle
          .loadString('lib/features/home/presentation/pages/data/resign.json');
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
      });
      
      // 数据加载完成后初始化表单
      _initializeFormData();
    } catch (e) {
      debugPrint('加载地区数据失败: $e');
    }
  }

  void _initializeFormData() {
    // 从传入的formData初始化表单数据
    _selectedRegion = widget.formData['region'] ?? 'beijing';
    
    // 如果有地区数据，设置当地社平工资
    if (_regionData.isNotEmpty && _selectedRegion != null && _regionData.containsKey(_selectedRegion)) {
      final regionInfo = _regionData[_selectedRegion!];
      _localAvgSalaryController.text = regionInfo['socialSecurityBase'].toString();
    }
    
    // 设置已缴费年限
    _paidYearsController.text = widget.formData['paymentYears'] ?? '30';
    
    // 初始化完成后进行计算
    _calculatePension();
  }

  void _onRegionChanged(String? regionKey) {
    if (regionKey != null && _regionData.containsKey(regionKey)) {
      final regionInfo = _regionData[regionKey];
      setState(() {
        _selectedRegion = regionKey;
        _localAvgSalaryController.text = regionInfo['socialSecurityBase'].toString();
      });
      _calculatePension();
    }
  }

  void _calculatePension() {
    try {
      final double currentSalary = double.tryParse(widget.formData['currentSalary']) ?? 0;
      final int currentAge = int.tryParse(widget.formData['currentAge']) ?? 0;
      final int retirementAge = int.tryParse(widget.formData['retirementAge']) ?? 0;
      final int paymentYears = int.tryParse(_paidYearsController.text) ?? 0;
      final double socialSecurityBase = double.tryParse(_localAvgSalaryController.text) ?? 0;
      final String regionKey = _selectedRegion ?? 'beijing';

      setState(() {
        _calculationResult = CalculationService.calculatePension(
          currentSalary: currentSalary,
          currentAge: currentAge,
          retirementAge: retirementAge,
          paymentYears: paymentYears,
          socialSecurityBase: socialSecurityBase,
          regionKey: regionKey,
          accountBalance: null, // 移除账户余额
        );
      });
    } catch (e) {
      debugPrint('养老金计算失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '养老金计算结果',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(20),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(_getResponsiveSpacing(20)),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildInputCard(),
                SizedBox(height: _getResponsiveSpacing(20)),
                if (_calculationResult.isNotEmpty) ...[
                  _buildSummaryCard(),
                  SizedBox(height: _getResponsiveSpacing(20)),
                  _buildDetailCard(),
                  SizedBox(height: _getResponsiveSpacing(20)),
                  _buildProjectionCard(),
                  SizedBox(height: _getResponsiveSpacing(20)),
                  _buildPaybackAnalysisCard(),
                  SizedBox(height: _getResponsiveSpacing(20)),
                  _buildActionButtons(),
                ],
                SizedBox(height: _getResponsiveSpacing(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, _) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_getResponsiveRadius(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0F000000),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveSpacing(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_getResponsiveSpacing(8)),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: const Color(0xFF10B981),
                            size: _getResponsiveFontSize(20),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSpacing(12)),
                        Text(
                          '调整计算参数',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSpacing(24)),
                    
                    // 地区选择
                    Text(
                      '地区选择',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: _getResponsiveSpacing(8)),
                    RegionDropdown(
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
                    
                    SizedBox(height: _getResponsiveSpacing(20)),
                    
                    // 当地社平工资
                    ModernTextField(
                      controller: _localAvgSalaryController,
                      label: '当地社平工资',
                      suffix: '元',
                      iconText: '¥',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入当地社平工资';
                        }
                        final salary = double.tryParse(value);
                        if (salary == null || salary <= 0) {
                          return '请输入有效的社平工资';
                        }
                        return null;
                      },
                      onChanged: (value) => _calculatePension(),
                    ),
                    
                    SizedBox(height: _getResponsiveSpacing(20)),
                    
                    // 已缴费年限
                    ModernTextField(
                      controller: _paidYearsController,
                      label: '已缴费年限',
                      suffix: '年',
                      icon: Icons.schedule_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入已缴费年限';
                        }
                        final years = int.tryParse(value);
                        if (years == null || years < 0 || years > 50) {
                          return '请输入0-50年之间的缴费年限';
                        }
                        return null;
                      },
                      onChanged: (value) => _calculatePension(),
                    ),
                    
                    SizedBox(height: _getResponsiveSpacing(20)),
                    
                    // 重新计算按钮
                    SizedBox(
                      width: double.infinity,
                      child: ModernButton(
                        text: '重新计算',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _calculatePension();
                          }
                        },
                        isPrimary: true,
                        icon: Icons.calculate_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    final summary = _calculationResult['summary'] ?? {};
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, _) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                ),
                borderRadius: BorderRadius.circular(_getResponsiveRadius(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveSpacing(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_getResponsiveSpacing(8)),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                          ),
                          child: Icon(
                            Icons.elderly_rounded,
                            color: Colors.white,
                            size: _getResponsiveFontSize(24),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSpacing(12)),
                        Text(
                          '养老金预估',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(20),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSpacing(24)),
                    _buildSummaryItem(
                      '基础养老金',
                      '¥${(_calculationResult['basicPension'] ?? 0).toStringAsFixed(2)}',
                      Colors.white70,
                    ),
                    SizedBox(height: _getResponsiveSpacing(16)),
                    _buildSummaryItem(
                      '个人账户养老金',
                      '¥${(_calculationResult['personalAccountPension'] ?? 0).toStringAsFixed(2)}',
                      Colors.white70,
                    ),
                    SizedBox(height: _getResponsiveSpacing(16)),
                    _buildSummaryItem(
                      '缴费年限',
                      '${summary['paymentYears'] ?? 0}年',
                      Colors.white70,
                    ),
                    SizedBox(height: _getResponsiveSpacing(16)),
                    _buildSummaryItem(
                      '替代率',
                      '${(summary['replacementRate'] ?? 0).toStringAsFixed(1)}%',
                      Colors.white70,
                    ),
                    SizedBox(height: _getResponsiveSpacing(20)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(_getResponsiveSpacing(20)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(_getResponsiveRadius(16)),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '每月可领取养老金',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(16),
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '¥${(_calculationResult['totalMonthlyPension'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(32),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
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
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(14),
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(16),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, _) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_getResponsiveRadius(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0F000000),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveSpacing(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_getResponsiveSpacing(8)),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                          ),
                          child: Icon(
                            Icons.analytics_rounded,
                            color: const Color(0xFF10B981),
                            size: _getResponsiveFontSize(20),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSpacing(12)),
                        Text(
                          '计算详情',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSpacing(24)),
                    _buildDetailItem('个人账户总余额', '¥${(_calculationResult['totalAccountBalance'] ?? 0).toStringAsFixed(2)}'),
                    _buildDetailItem('计发月数', '${_calculationResult['paymentMonths'] ?? 0}个月'),
                    _buildDetailItem('退休时社会平均工资', '¥${(_calculationResult['avgSalaryAtRetirement'] ?? 0).toStringAsFixed(2)}'),
                    _buildDetailItem('退休前预估工资', '¥${(_calculationResult['preRetirementSalary'] ?? 0).toStringAsFixed(2)}'),
                    _buildDetailItem('月缴费金额', '¥${(_calculationResult['monthlyContribution'] ?? 0).toStringAsFixed(2)}'),
                    
                    // 添加计算说明
                    SizedBox(height: _getResponsiveSpacing(16)),
                    Container(
                      padding: EdgeInsets.all(_getResponsiveSpacing(16)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                        border: Border.all(
                          color: const Color(0xFF0EA5E9),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: const Color(0xFF0EA5E9),
                                size: _getResponsiveFontSize(16),
                              ),
                              SizedBox(width: _getResponsiveSpacing(8)),
                              Text(
                                '计算说明',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(14),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0EA5E9),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '• 基础养老金 = (社会平均工资 + 个人指数化缴费工资) ÷ 2 × 缴费年限 × 1%\n'
                            '• 个人账户养老金 = 个人账户余额 ÷ 计发月数\n'
                            '• 预估工资增长率：3%/年\n'
                            '• 个人账户收益率：3%/年',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(12),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF0369A1),
                              height: 1.4,
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
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: _getResponsiveSpacing(16)),
      padding: EdgeInsets.all(_getResponsiveSpacing(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(16),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCard() {
    final summary = _calculationResult['summary'] ?? {};
    final monthlyPension = _calculationResult['totalMonthlyPension'] ?? 0;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, _) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_getResponsiveRadius(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0F000000),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveSpacing(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_getResponsiveSpacing(8)),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: const Color(0xFF6366F1),
                            size: _getResponsiveFontSize(20),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSpacing(12)),
                        Text(
                          '收益预测',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSpacing(24)),
                    _buildProjectionItem('年收益', '¥${(monthlyPension * 12).toStringAsFixed(2)}'),
                    _buildProjectionItem('10年累计', '¥${(monthlyPension * 12 * 10).toStringAsFixed(2)}'),
                    _buildProjectionItem('20年累计', '¥${(monthlyPension * 12 * 20).toStringAsFixed(2)}'),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(_getResponsiveSpacing(16)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '距离退休还有',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(14),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '${summary['yearsToRetirement'] ?? 0}年',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(24),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6366F1),
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
      },
    );
  }

  Widget _buildProjectionItem(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: _getResponsiveSpacing(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(16),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaybackAnalysisCard() {
    // 计算回本年限分析
    final paybackAnalysis = _calculatePaybackAnalysis();
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, _) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_getResponsiveRadius(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0F000000),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveSpacing(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_getResponsiveSpacing(8)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                          ),
                          child: Icon(
                            Icons.timeline_rounded,
                            color: const Color(0xFFEF4444),
                            size: _getResponsiveFontSize(20),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSpacing(12)),
                        Text(
                          '回本年限分析',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSpacing(24)),
                    
                    // 核心回本信息
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(_getResponsiveSpacing(20)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFEF4444).withOpacity(0.1),
                            const Color(0xFFDC2626).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(_getResponsiveRadius(16)),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '预计回本年限',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(16),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '${paybackAnalysis['paybackYears'].toStringAsFixed(1)}年',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(32),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '约${(paybackAnalysis['paybackYears'] * 12).round()}个月',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(14),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: _getResponsiveSpacing(20)),
                    
                    // 详细分析数据
                    _buildPaybackItem('参保期间总缴费', '¥${paybackAnalysis['totalContributions'].toStringAsFixed(2)}'),
                    _buildPaybackItem('每月养老金', '¥${paybackAnalysis['monthlyPension'].toStringAsFixed(2)}'),
                    _buildPaybackItem('年度养老金', '¥${paybackAnalysis['yearlyPension'].toStringAsFixed(2)}'),
                    
                    SizedBox(height: _getResponsiveSpacing(16)),
                    
                    // 回本进度条
                    Container(
                      padding: EdgeInsets.all(_getResponsiveSpacing(16)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '回本进度预测',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(14),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              Text(
                                '${(100 / paybackAnalysis['paybackYears'] * 1).toStringAsFixed(1)}%/年',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(12),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (1 / paybackAnalysis['paybackYears']).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '第1年回本进度：${(100 / paybackAnalysis['paybackYears']).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(12),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: _getResponsiveSpacing(16)),
                    
                    // 分析说明
                    Container(
                      padding: EdgeInsets.all(_getResponsiveSpacing(16)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: const Color(0xFFF59E0B),
                                size: _getResponsiveFontSize(16),
                              ),
                              SizedBox(width: _getResponsiveSpacing(8)),
                              Text(
                                '分析说明',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(14),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '• 回本年限 = 参保期间总缴费金额 ÷ 年度养老金收入\n'
                            '• 总缴费包括个人缴费部分（8%）和历年收益\n'
                            '• 计算基于当前参数，实际情况可能因政策调整而变化\n'
                            '• 养老保险具有保障功能，不应仅从投资回报角度考虑',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(12),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFD97706),
                              height: 1.4,
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
      },
    );
  }

  Widget _buildPaybackItem(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: _getResponsiveSpacing(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(16),
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculatePaybackAnalysis() {
    final int paymentYears = int.tryParse(_paidYearsController.text) ?? 0;
    final double socialSecurityBase = double.tryParse(_localAvgSalaryController.text) ?? 0;
    
    // 养老保险个人缴费比例（8%）
    const double pensionRate = 0.08;
    
    // 月缴费金额
    final double monthlyContribution = socialSecurityBase * pensionRate;
    
    // 参保期间总缴费金额（个人部分）
    // 考虑工资增长和缴费基数调整，假设年增长3%
    double totalContributions = 0;
    for (int year = 0; year < paymentYears; year++) {
      final double yearlyBase = socialSecurityBase * math.pow(1.03, year);
      final double yearlyContribution = yearlyBase * pensionRate * 12;
      totalContributions += yearlyContribution;
    }
    
    // 每月养老金
    final double monthlyPension = _calculationResult['totalMonthlyPension'] ?? 0;
    
    // 年度养老金
    final double yearlyPension = monthlyPension * 12;
    
    // 回本年限
    final double paybackYears = yearlyPension > 0 ? totalContributions / yearlyPension : 0;
    
    return {
      'totalContributions': totalContributions,
      'monthlyPension': monthlyPension,
      'yearlyPension': yearlyPension,
      'paybackYears': paybackYears,
      'monthlyContribution': monthlyContribution,
    };
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: '重新计算',
            onPressed: () => context.pop(),
            isPrimary: false,
            icon: Icons.refresh_rounded,
          ),
        ),
        SizedBox(width: _getResponsiveSpacing(16)),
        Expanded(
          child: _buildActionButton(
            text: '分享结果',
            onPressed: _shareResult,
            isPrimary: true,
            icon: Icons.share_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_getResponsiveRadius(16)),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: _getResponsiveSpacing(16),
            horizontal: _getResponsiveSpacing(24),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_getResponsiveRadius(16)),
            gradient: isPrimary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF059669),
                    ],
                  )
                : null,
            border: !isPrimary
                ? Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  )
                : null,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF10B981),
                size: _getResponsiveFontSize(18),
              ),
              SizedBox(width: _getResponsiveSpacing(8)),
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF10B981),
                  fontSize: _getResponsiveFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareResult() {
    final monthlyPension = _calculationResult['totalMonthlyPension'] ?? 0;
    final summary = _calculationResult['summary'] ?? {};
    
    final String shareText = '''
养老金计算结果：
退休年龄：${summary['retirementAge'] ?? 0}岁
缴费年限：${summary['paymentYears'] ?? 0}年
每月养老金：¥${monthlyPension.toStringAsFixed(2)}
年收益：¥${(monthlyPension * 12).toStringAsFixed(2)}
替代率：${(summary['replacementRate'] ?? 0).toStringAsFixed(1)}%
''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享功能开发中...'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  // 响应式尺寸计算方法
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

  double _getResponsiveRadius(double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 768) {
      return baseRadius * 1.2;
    }
    return baseRadius;
  }
}