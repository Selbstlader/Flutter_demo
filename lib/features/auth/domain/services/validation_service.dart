/// 统一的验证服务
/// 提供邮箱、密码、昵称等字段的验证功能
class ValidationService {
  // 邮箱格式验证的正则表达式
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // 密码强度验证的正则表达式
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-zA-Z])(?=.*\d)',
  );

  // 昵称验证的正则表达式
  static final RegExp _nicknameRegex = RegExp(
    r'^[\u4e00-\u9fa5a-zA-Z0-9_\s]{1,20}$',
  );

  /// 验证邮箱格式
  /// 
  /// [email] 要验证的邮箱地址
  /// 返回 true 表示格式正确，false 表示格式错误
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// 验证邮箱并返回错误信息
  /// 
  /// [email] 要验证的邮箱地址
  /// 返回 null 表示验证通过，返回字符串表示错误信息
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '邮箱不能为空';
    }
    
    final trimmedEmail = email.trim();
    
    if (trimmedEmail.length > 254) {
      return '邮箱地址过长';
    }
    
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return '请输入正确的邮箱格式';
    }
    
    return null;
  }

  /// 验证密码强度
  /// 
  /// [password] 要验证的密码
  /// 返回 null 表示验证通过，返回字符串表示错误信息
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '密码不能为空';
    }
    
    if (password.length < 6) {
      return '密码长度不能少于6位';
    }
    
    if (password.length > 128) {
      return '密码长度不能超过128位';
    }
    
    if (!_passwordRegex.hasMatch(password)) {
      return '密码必须包含字母和数字';
    }
    
    return null;
  }

  /// 验证确认密码
  /// 
  /// [password] 原密码
  /// [confirmPassword] 确认密码
  /// 返回 null 表示验证通过，返回字符串表示错误信息
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return '请确认密码';
    }
    
    if (password != confirmPassword) {
      return '两次输入的密码不一致';
    }
    
    return null;
  }

  /// 验证昵称
  /// 
  /// [nickname] 要验证的昵称
  /// 返回 null 表示验证通过，返回字符串表示错误信息
  static String? validateNickname(String? nickname) {
    // 昵称是可选的，可以为空
    if (nickname == null || nickname.isEmpty) {
      return null;
    }
    
    final trimmedNickname = nickname.trim();
    
    if (trimmedNickname.isEmpty) {
      return null;
    }
    
    if (trimmedNickname.length < 1) {
      return '昵称不能为空';
    }
    
    if (trimmedNickname.length > 20) {
      return '昵称长度不能超过20个字符';
    }
    
    if (!_nicknameRegex.hasMatch(trimmedNickname)) {
      return '昵称只能包含中文、英文、数字、下划线和空格';
    }
    
    return null;
  }

  /// 获取密码强度等级
  /// 
  /// [password] 要检查的密码
  /// 返回密码强度等级：0-弱，1-中等，2-强
  static int getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) return 0;
    
    int score = 0;
    
    // 长度检查
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    
    // 字符类型检查
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (hasLower) score++;
    if (hasUpper) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;
    
    // 必须同时包含字母和数字才能达到中等强度
    bool hasLetterAndDigit = (hasLower || hasUpper) && hasDigit;
    if (!hasLetterAndDigit) {
      return 0; // 弱密码
    }
    
    // 返回强度等级
    if (score <= 4) return 1; // 中等
    return 2; // 强
  }

  /// 获取密码强度描述文本
  static String getPasswordStrengthText(String? password) {
    final strength = getPasswordStrength(password);
    switch (strength) {
      case 0:
        return '弱';
      case 1:
        return '中等';
      case 2:
        return '强';
      default:
        return '弱';
    }
  }

  /// 验证注册表单
  static Map<String, String?> validateRegisterForm({
    required String? email,
    required String? password,
    required String? confirmPassword,
    String? nickname,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(password, confirmPassword),
      'nickname': validateNickname(nickname),
    };
  }

  /// 验证登录表单
  static Map<String, String?> validateLoginForm({
    required String? email,
    required String? password,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
    };
  }

  /// 检查表单是否有效（所有字段都没有错误）
  static bool isFormValid(Map<String, String?> validationResult) {
    return validationResult.values.every((error) => error == null);
  }
}