import 'package:flutter/material.dart';

/// String扩展方法
extension StringExtensions on String {
  /// 判断字符串是否为空或null
  bool get isNullOrEmpty => isEmpty;

  /// 判断字符串是否不为空且不为null
  bool get isNotNullOrEmpty => isNotEmpty;

  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 移除所有空格
  String get removeAllSpaces => replaceAll(' ', '');

  /// 验证邮箱格式
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// 验证手机号格式
  bool get isValidPhone {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }

  /// 验证身份证号格式
  bool get isValidIdCard {
    return RegExp(r'^\d{17}[\dXx]$').hasMatch(this);
  }

  /// 隐藏手机号中间4位
  String get hiddenPhone {
    if (length != 11) return this;
    return '${substring(0, 3)}****${substring(7)}';
  }

  /// 隐藏邮箱用户名部分
  String get hiddenEmail {
    final atIndex = indexOf('@');
    if (atIndex <= 0) return this;
    final username = substring(0, atIndex);
    final domain = substring(atIndex);
    if (username.length <= 2) return this;
    return '${username.substring(0, 2)}***$domain';
  }
}

/// DateTime扩展方法
extension DateTimeExtensions on DateTime {
  /// 格式化为字符串 yyyy-MM-dd
  String get formatDate {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// 格式化为字符串 yyyy-MM-dd HH:mm:ss
  String get formatDateTime {
    return '$formatDate '
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';
  }

  /// 格式化为字符串 HH:mm
  String get formatTime {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }

  /// 获取友好的时间显示
  String get friendlyFormat {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 7) {
      return formatDate;
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// BuildContext扩展方法
extension BuildContextExtensions on BuildContext {
  /// 获取屏幕尺寸
  Size get screenSize => MediaQuery.of(this).size;

  /// 获取屏幕宽度
  double get screenWidth => screenSize.width;

  /// 获取屏幕高度
  double get screenHeight => screenSize.height;

  /// 获取状态栏高度
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  /// 获取底部安全区域高度
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// 获取主题数据
  ThemeData get theme => Theme.of(this);

  /// 获取颜色方案
  ColorScheme get colorScheme => theme.colorScheme;

  /// 获取文字主题
  TextTheme get textTheme => theme.textTheme;

  /// 显示SnackBar
  void showSnackBar(String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// 显示成功消息
  void showSuccessMessage(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// 显示错误消息
  void showErrorMessage(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// 显示警告消息
  void showWarningMessage(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  /// 隐藏键盘
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// 是否为深色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;
}

/// List扩展方法
extension ListExtensions<T> on List<T> {
  /// 安全获取元素
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// 添加元素如果不存在
  void addIfNotExists(T item) {
    if (!contains(item)) {
      add(item);
    }
  }

  /// 移除所有匹配的元素
  void removeWhere(bool Function(T) test) {
    removeWhere(test);
  }

  /// 分组
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => <T>[]).add(item);
    }
    return map;
  }
}

/// Map扩展方法
extension MapExtensions<K, V> on Map<K, V> {
  /// 安全获取值
  V? safeGet(K key) {
    return containsKey(key) ? this[key] : null;
  }

  /// 获取值或默认值
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }
}

/// Color扩展方法
extension ColorExtensions on Color {
  /// 转换为十六进制字符串
  String get hexString {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// 获取对比色（黑色或白色）
  Color get contrastColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 调整透明度
  Color withAlpha(int alpha) {
    return Color.fromARGB(alpha, red, green, blue);
  }

  /// 调整亮度
  Color withBrightness(double brightness) {
    assert(brightness >= 0.0 && brightness <= 1.0);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness(brightness).toColor();
  }
}