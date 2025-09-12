import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/utils/error_handler.dart';

/// 通用计算服务 - 支持社保和养老金计算
class CalculationService {
  static Map<String, dynamic> _regionData = {};
  
  /// 加载地区数据
  static Future<void> loadRegionData() async {
    if (_regionData.isNotEmpty) return;
    
    try {
      final String jsonString = await rootBundle
          .loadString('assets/data/regions.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      _regionData = data['regions'];
    } catch (e) {
      throw Exception('加载地区数据失败: ${ErrorHandler.handleError(e, context: 'loadRegionData')}');
    }
  }
  
  /// 获取地区信息
  static Map<String, dynamic>? getRegionInfo(String regionKey) {
    return _regionData[regionKey];
  }
  
  /// 社保计算
  static Map<String, dynamic> calculateSocialSecurity({
    required double salary,
    required double housingFundRate,
    required double socialSecurityBase,
    required double housingFundBase,
    required double specialDeduction,
    required String regionKey,
  }) {
    final regionInfo = getRegionInfo(regionKey) ?? {};
    final rates = regionInfo['rates'] ?? {};

    // 社保费率
    final double pensionPersonal = (rates['pensionPersonal'] ?? 8.0) / 100;
    final double pensionCompany = (rates['pensionCompany'] ?? 16.0) / 100;
    final double medicalPersonal = (rates['medicalPersonal'] ?? 2.0) / 100;
    final double medicalCompany = (rates['medicalCompany'] ?? 10.0) / 100;
    final double unemploymentPersonal = (rates['unemploymentPersonal'] ?? 0.2) / 100;
    final double unemploymentCompany = (rates['unemploymentCompany'] ?? 0.8) / 100;
    final double injuryPersonal = (rates['injuryPersonal'] ?? 0.0) / 100;
    final double injuryCompany = (rates['injuryCompany'] ?? 0.2) / 100;
    final double maternityPersonal = (rates['maternityPersonal'] ?? 0.0) / 100;
    final double maternityCompany = (rates['maternityCompany'] ?? 0.8) / 100;

    // 个人缴费计算
    final double personalPension = socialSecurityBase * pensionPersonal;
    final double personalMedical = socialSecurityBase * medicalPersonal;
    final double personalUnemployment = socialSecurityBase * unemploymentPersonal;
    final double personalInjury = socialSecurityBase * injuryPersonal;
    final double personalMaternity = socialSecurityBase * maternityPersonal;
    final double personalHousingFund = housingFundBase * (housingFundRate / 100);

    // 单位缴费计算
    final double companyPension = socialSecurityBase * pensionCompany;
    final double companyMedical = socialSecurityBase * medicalCompany;
    final double companyUnemployment = socialSecurityBase * unemploymentCompany;
    final double companyInjury = socialSecurityBase * injuryCompany;
    final double companyMaternity = socialSecurityBase * maternityCompany;
    final double companyHousingFund = housingFundBase * (housingFundRate / 100);

    // 总计
    final double totalPersonal = personalPension + personalMedical + 
        personalUnemployment + personalInjury + personalMaternity + personalHousingFund;
    final double totalCompany = companyPension + companyMedical + 
        companyUnemployment + companyInjury + companyMaternity + companyHousingFund;

    // 扣除社保公积金后的金额
    final double afterSocialSecurity = salary - totalPersonal;

    // 个人所得税计算
    final double personalTax = _calculatePersonalTax(afterSocialSecurity - 5000 - specialDeduction);

    // 税后收入
    final double afterTaxIncome = afterSocialSecurity - personalTax;

    return {
      'type': 'social_security',
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
        'housingFundRate': housingFundRate,
      },
      'summary': {
        'salary': salary,
        'afterSocialSecurity': afterSocialSecurity,
        'personalTax': personalTax,
        'afterTaxIncome': afterTaxIncome,
        'specialDeduction': specialDeduction,
      }
    };
  }

  /// 养老金计算
  static Map<String, dynamic> calculatePension({
    required double currentSalary,
    required int currentAge,
    required int retirementAge,
    required int paymentYears,
    required double socialSecurityBase,
    required String regionKey,
    double? accountBalance,
  }) {
    final regionInfo = getRegionInfo(regionKey) ?? {};
    
    // 养老保险个人缴费比例（8%）
    final double pensionRate = 0.08;
    
    // 距离退休年数
    final int yearsToRetirement = retirementAge - currentAge;
    
    // 预估退休时社会平均工资（假设年增长3%）
    // 使用社保基数作为参考，通常接近社会平均工资
    final double currentAvgSalary = socialSecurityBase; 
    final double avgSalaryAtRetirement = currentAvgSalary * 
        _calculateCompoundGrowth(1.03, yearsToRetirement);
    
    // 个人指数化月平均缴费工资
    // 假设个人缴费基数相对于社会平均工资的比例保持稳定
    final double contributionIndex = socialSecurityBase / currentAvgSalary; // 缴费指数
    final double indexedAvgSalary = avgSalaryAtRetirement * contributionIndex;
    
    // 基础养老金 = (退休时社会平均工资 + 个人指数化月平均缴费工资) ÷ 2 × 缴费年限 × 1%
    final double basicPension = (avgSalaryAtRetirement + indexedAvgSalary) / 2 * 
        paymentYears * 0.01;
    
    // 个人账户养老金计算
    final double monthlyContribution = socialSecurityBase * pensionRate;
    
    // 如果有现有账户余额，则在此基础上继续累积
    double totalAccountBalance;
    if (accountBalance != null && accountBalance > 0) {
      // 现有余额按3%年化收益增长到退休
      final double futureAccountBalance = accountBalance * 
          _calculateCompoundGrowth(1.03, yearsToRetirement);
      
      // 未来缴费累积（考虑3%年化收益）
      final double futureContributions = monthlyContribution * 12 * yearsToRetirement * 
          _calculateCompoundGrowth(1.03, (yearsToRetirement / 2).round());
      
      totalAccountBalance = futureAccountBalance + futureContributions;
    } else {
      // 仅计算未来缴费累积
      totalAccountBalance = monthlyContribution * 12 * paymentYears * 
          _calculateCompoundGrowth(1.03, (paymentYears / 2).round());
    }
    
    // 计发月数（根据退休年龄确定）
    final int paymentMonths = _getPaymentMonths(retirementAge);
    final double personalAccountPension = totalAccountBalance / paymentMonths;
    
    // 总养老金
    final double totalMonthlyPension = basicPension + personalAccountPension;
    
    // 替代率计算（相对于退休前工资）
    final double preRetirementSalary = currentSalary * 
        _calculateCompoundGrowth(1.03, yearsToRetirement);
    final double replacementRate = (totalMonthlyPension / preRetirementSalary) * 100;
    
    return {
      'type': 'pension',
      'basicPension': basicPension,
      'personalAccountPension': personalAccountPension,
      'totalMonthlyPension': totalMonthlyPension,
      'totalAccountBalance': totalAccountBalance,
      'paymentMonths': paymentMonths,
      'avgSalaryAtRetirement': avgSalaryAtRetirement,
      'monthlyContribution': monthlyContribution,
      'preRetirementSalary': preRetirementSalary,
      'summary': {
        'currentAge': currentAge,
        'retirementAge': retirementAge,
        'paymentYears': paymentYears,
        'yearsToRetirement': yearsToRetirement,
        'replacementRate': replacementRate,
      }
    };
  }

  /// 计算复合增长
  static double _calculateCompoundGrowth(double rate, int years) {
    if (years <= 0) return 1.0;
    double result = 1.0;
    for (int i = 0; i < years; i++) {
      result *= rate;
    }
    return result;
  }

  /// 个人所得税计算
  static double _calculatePersonalTax(double taxableIncome) {
    if (taxableIncome <= 0) return 0;

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
        return taxableIncome * bracket['rate'] - bracket['deduction'];
      }
    }
    return 0;
  }

  /// 根据退休年龄获取计发月数
  static int _getPaymentMonths(int retirementAge) {
    switch (retirementAge) {
      case 50: return 195;
      case 55: return 170;
      case 60: return 139;
      case 65: return 101;
      default: return 139; // 默认60岁退休
    }
  }
}