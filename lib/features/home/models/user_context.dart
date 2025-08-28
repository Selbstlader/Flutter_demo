class UserContext {
  final String socialSecurityType; // 社保类型：城镇职工/城乡居民/灵活就业
  final int paymentYears; // 缴费年限
  final double pensionBalance; // 养老金账户余额
  final int age; // 年龄
  final String region; // 地区
  final double monthlyIncome; // 月收入
  final String employmentStatus; // 就业状态

  const UserContext({
    required this.socialSecurityType,
    required this.paymentYears,
    required this.pensionBalance,
    required this.age,
    required this.region,
    required this.monthlyIncome,
    required this.employmentStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'socialSecurityType': socialSecurityType,
      'paymentYears': paymentYears,
      'pensionBalance': pensionBalance,
      'age': age,
      'region': region,
      'monthlyIncome': monthlyIncome,
      'employmentStatus': employmentStatus,
    };
  }

  String toContextString() {
    return '''
用户基本信息：
- 社保类型：$socialSecurityType
- 缴费年限：$paymentYears年
- 养老金账户余额：${pensionBalance.toStringAsFixed(2)}元
- 年龄：$age岁
- 所在地区：$region
- 月收入：${monthlyIncome.toStringAsFixed(2)}元
- 就业状态：$employmentStatus

请基于以上用户信息，提供专业、准确的社保和养老金相关建议。
''';
  }
}