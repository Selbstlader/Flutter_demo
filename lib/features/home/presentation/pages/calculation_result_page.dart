import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// 社保计算结果页面
class CalculationResultPage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const CalculationResultPage({
    super.key,
    required this.formData,
  });

  @override
  State<CalculationResultPage> createState() => _CalculationResultPageState();
}

class _CalculationResultPageState extends State<CalculationResultPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic> _regionData = {};
  Map<String, dynamic> _calculationResult = {};

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDataAndCalculate();
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
    super.dispose();
  }

  Future<void> _loadDataAndCalculate() async {
    try {
      final String jsonString = await rootBundle.loadString(
          'assets/data/regions.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      setState(() {
        _regionData = data['regions'];
        _calculationResult = _calculateSocialSecurity();
      });
    } catch (e) {
      debugPrint('加载数据失败: $e');
    }
  }

  /// 社保计算核心逻辑
  Map<String, dynamic> _calculateSocialSecurity() {
    final double salary = double.tryParse(widget.formData['salary']) ?? 0;
    final double housingFundRate =
        (double.tryParse(widget.formData['housingFundRate']) ?? 0) / 100;
    final double socialSecurityBase =
        double.tryParse(widget.formData['socialSecurityBase']) ?? 0;
    final double housingFundBase =
        double.tryParse(widget.formData['housingFundBase']) ?? 0;
    final double specialDeduction =
        double.tryParse(widget.formData['specialDeduction']) ?? 0;
    final String regionKey = widget.formData['region'] ?? 'beijing';

    final regionInfo = _regionData[regionKey] ?? {};
    final rates = regionInfo['rates'] ?? {};

    // 社保费率
    final double pensionPersonal = (rates['pensionPersonal'] ?? 8.0) / 100;
    final double pensionCompany = (rates['pensionCompany'] ?? 16.0) / 100;
    final double medicalPersonal = (rates['medicalPersonal'] ?? 2.0) / 100;
    final double medicalCompany = (rates['medicalCompany'] ?? 10.0) / 100;
    final double unemploymentPersonal =
        (rates['unemploymentPersonal'] ?? 0.2) / 100;
    final double unemploymentCompany =
        (rates['unemploymentCompany'] ?? 0.8) / 100;
    final double injuryPersonal = (rates['injuryPersonal'] ?? 0.0) / 100;
    final double injuryCompany = (rates['injuryCompany'] ?? 0.2) / 100;
    final double maternityPersonal = (rates['maternityPersonal'] ?? 0.0) / 100;
    final double maternityCompany = (rates['maternityCompany'] ?? 0.8) / 100;

    // 个人缴费计算
    final double personalPension = socialSecurityBase * pensionPersonal;
    final double personalMedical = socialSecurityBase * medicalPersonal;
    final double personalUnemployment =
        socialSecurityBase * unemploymentPersonal;
    final double personalInjury = socialSecurityBase * injuryPersonal;
    final double personalMaternity = socialSecurityBase * maternityPersonal;
    final double personalHousingFund = housingFundBase * housingFundRate;

    // 单位缴费计算
    final double companyPension = socialSecurityBase * pensionCompany;
    final double companyMedical = socialSecurityBase * medicalCompany;
    final double companyUnemployment = socialSecurityBase * unemploymentCompany;
    final double companyInjury = socialSecurityBase * injuryCompany;
    final double companyMaternity = socialSecurityBase * maternityCompany;
    final double companyHousingFund = housingFundBase * housingFundRate;

    // 总计
    final double totalPersonal = personalPension +
        personalMedical +
        personalUnemployment +
        personalInjury +
        personalMaternity +
        personalHousingFund;

    final double totalCompany = companyPension +
        companyMedical +
        companyUnemployment +
        companyInjury +
        companyMaternity +
        companyHousingFund;

    // 扣除社保公积金后的金额
    final double afterSocialSecurity = salary - totalPersonal;

    // 个人所得税计算
    final double taxableIncome = afterSocialSecurity - 5000 - specialDeduction;
    final double personalTax = _calculatePersonalTax(taxableIncome);

    // 税后收入
    final double afterTaxIncome = afterSocialSecurity - personalTax;

    // 专项扣除后收入
    final double afterSpecialDeduction = afterTaxIncome;

    return {
      'personal': {
        'pension': personalPension,
        'medical': personalMedical,
        'unemployment': personalUnemployment,
        'injury': personalInjury,
        'maternity': personalMaternity,
        'housingFund': personalHousingFund,
        'total': totalPersonal,
      },
      'company': {
        'pension': companyPension,
        'medical': companyMedical,
        'unemployment': companyUnemployment,
        'injury': companyInjury,
        'maternity': companyMaternity,
        'housingFund': companyHousingFund,
        'total': totalCompany,
      },
      'rates': {
        'pensionPersonal': pensionPersonal * 100,
        'pensionCompany': pensionCompany * 100,
        'medicalPersonal': medicalPersonal * 100,
        'medicalCompany': medicalCompany * 100,
        'unemploymentPersonal': unemploymentPersonal * 100,
        'unemploymentCompany': unemploymentCompany * 100,
        'injuryPersonal': injuryPersonal * 100,
        'injuryCompany': injuryCompany * 100,
        'maternityPersonal': maternityPersonal * 100,
        'maternityCompany': maternityCompany * 100,
        'housingFundRate': housingFundRate * 100,
      },
      'summary': {
        'salary': salary,
        'afterSocialSecurity': afterSocialSecurity,
        'personalTax': personalTax,
        'afterTaxIncome': afterTaxIncome,
        'specialDeduction': specialDeduction,
        'afterSpecialDeduction': afterSpecialDeduction,
      }
    };
  }

  /// 个人所得税计算
  double _calculatePersonalTax(double taxableIncome) {
    if (taxableIncome <= 0) return 0;

    double tax = 0;
    double remainingIncome = taxableIncome;

    // 税率表
    final List<Map<String, dynamic>> taxBrackets = [
      {'min': 0, 'max': 3000, 'rate': 0.03, 'deduction': 0},
      {'min': 3000, 'max': 12000, 'rate': 0.10, 'deduction': 210},
      {'min': 12000, 'max': 25000, 'rate': 0.20, 'deduction': 1410},
      {'min': 25000, 'max': 35000, 'rate': 0.25, 'deduction': 2660},
      {'min': 35000, 'max': 55000, 'rate': 0.30, 'deduction': 4410},
      {'min': 55000, 'max': 80000, 'rate': 0.35, 'deduction': 7160},
      {'min': 80000, 'max': double.infinity, 'rate': 0.45, 'deduction': 15160},
    ];

    for (final bracket in taxBrackets) {
      if (taxableIncome > bracket['min']) {
        tax = taxableIncome * bracket['rate'] - bracket['deduction'];
        break;
      }
    }

    return tax > 0 ? tax : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '计算结果',
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
        child: _calculationResult.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(_getResponsiveSpacing(20)),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    SizedBox(height: _getResponsiveSpacing(20)),
                    _buildDetailCard(),
                    SizedBox(height: _getResponsiveSpacing(20)),
                    _buildActionButtons(),
                    SizedBox(height: _getResponsiveSpacing(40)),
                  ],
                ),
              ),
      ),
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
                    Color(0xFF6366F1),
                    Color(0xFF4F46E5),
                  ],
                ),
                borderRadius: BorderRadius.circular(_getResponsiveRadius(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
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
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: _getResponsiveFontSize(24),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSpacing(12)),
                        Text(
                          '计算结果',
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
                      '个人缴费总计',
                      '¥${(_calculationResult['personal']?['total'] ?? 0).toStringAsFixed(2)}',
                      Colors.white70,
                    ),
                    SizedBox(height: _getResponsiveSpacing(16)),
                    _buildSummaryItem(
                      '单位缴费总计',
                      '¥${(_calculationResult['company']?['total'] ?? 0).toStringAsFixed(2)}',
                      Colors.white70,
                    ),
                    SizedBox(height: _getResponsiveSpacing(16)),
                    _buildSummaryItem(
                      '扣除社保公积金后',
                      '¥${(summary['afterSocialSecurity'] ?? 0).toStringAsFixed(2)}',
                      Colors.white70,
                    ),
                    SizedBox(height: _getResponsiveSpacing(16)),
                    _buildSummaryItem(
                      '个人所得税',
                      '¥${(summary['personalTax'] ?? 0).toStringAsFixed(2)}',
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
                            '税后收入',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(16),
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: _getResponsiveSpacing(8)),
                          Text(
                            '¥${(summary['afterTaxIncome'] ?? 0).toStringAsFixed(2)}',
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
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: const Color(0xFF6366F1),
                            size: _getResponsiveFontSize(20),
                          ),
                        ),
                        SizedBox(width: _getResponsiveSpacing(12)),
                        Text(
                          '缴费明细',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSpacing(24)),
                    _buildDetailTable(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTable() {
    final personal = _calculationResult['personal'] ?? {};
    final company = _calculationResult['company'] ?? {};
    final rates = _calculationResult['rates'] ?? {};

    final List<Map<String, dynamic>> items = [
      {
        'name': '养老保险',
        'personalAmount': personal['pension'] ?? 0,
        'personalRate': rates['pensionPersonal'] ?? 0,
        'companyAmount': company['pension'] ?? 0,
        'companyRate': rates['pensionCompany'] ?? 0,
      },
      {
        'name': '医疗保险',
        'personalAmount': personal['medical'] ?? 0,
        'personalRate': rates['medicalPersonal'] ?? 0,
        'companyAmount': company['medical'] ?? 0,
        'companyRate': rates['medicalCompany'] ?? 0,
      },
      {
        'name': '失业保险',
        'personalAmount': personal['unemployment'] ?? 0,
        'personalRate': rates['unemploymentPersonal'] ?? 0,
        'companyAmount': company['unemployment'] ?? 0,
        'companyRate': rates['unemploymentCompany'] ?? 0,
      },
      {
        'name': '工伤保险',
        'personalAmount': personal['injury'] ?? 0,
        'personalRate': rates['injuryPersonal'] ?? 0,
        'companyAmount': company['injury'] ?? 0,
        'companyRate': rates['injuryCompany'] ?? 0,
      },
      {
        'name': '生育保险',
        'personalAmount': personal['maternity'] ?? 0,
        'personalRate': rates['maternityPersonal'] ?? 0,
        'companyAmount': company['maternity'] ?? 0,
        'companyRate': rates['maternityCompany'] ?? 0,
      },
      {
        'name': '基本住房公积金',
        'personalAmount': personal['housingFund'] ?? 0,
        'personalRate': rates['housingFundRate'] ?? 0,
        'companyAmount': company['housingFund'] ?? 0,
        'companyRate': rates['housingFundRate'] ?? 0,
      },
    ];

    return Column(
      children: [
        // 表头
        Container(
          padding: EdgeInsets.symmetric(
            vertical: _getResponsiveSpacing(12),
            horizontal: _getResponsiveSpacing(16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '项目',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '个人缴纳',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '单位缴纳',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(8)),
        // 数据行
        ...items.map((item) => _buildTableRow(item)),
        SizedBox(height: _getResponsiveSpacing(12)),
        // 合计行
        Container(
          padding: EdgeInsets.symmetric(
            vertical: _getResponsiveSpacing(16),
            horizontal: _getResponsiveSpacing(16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.05),
            borderRadius: BorderRadius.circular(_getResponsiveRadius(12)),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '共计',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '¥${(personal['total'] ?? 0).toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '¥${(company['total'] ?? 0).toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: _getResponsiveSpacing(8)),
      padding: EdgeInsets.symmetric(
        vertical: _getResponsiveSpacing(12),
        horizontal: _getResponsiveSpacing(16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_getResponsiveRadius(8)),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item['name'],
              style: TextStyle(
                fontSize: _getResponsiveFontSize(14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  '¥${item['personalAmount'].toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
                Text(
                  '(${item['personalRate'].toStringAsFixed(2)}%)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  '¥${item['companyAmount'].toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                Text(
                  '(${item['companyRate'].toStringAsFixed(2)}%)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(12),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                    ],
                  )
                : null,
            border: !isPrimary
                ? Border.all(
                    color: const Color(0xFF6366F1),
                    width: 2,
                  )
                : null,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
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
                color: isPrimary ? Colors.white : const Color(0xFF6366F1),
                size: _getResponsiveFontSize(18),
              ),
              SizedBox(width: _getResponsiveSpacing(8)),
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF6366F1),
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
    final summary = _calculationResult['summary'] ?? {};
    final personal = _calculationResult['personal'] ?? {};
    final company = _calculationResult['company'] ?? {};
    
    final String shareText = '''
社保计算结果：
税前月薪：¥${(summary['salary'] ?? 0).toStringAsFixed(2)}
个人缴费：¥${(personal['total'] ?? 0).toStringAsFixed(2)}
单位缴费：¥${(company['total'] ?? 0).toStringAsFixed(2)}
税后收入：¥${(summary['afterTaxIncome'] ?? 0).toStringAsFixed(2)}
''';
    
    // 这里可以集成分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享功能开发中...'),
        backgroundColor: const Color(0xFF6366F1),
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
