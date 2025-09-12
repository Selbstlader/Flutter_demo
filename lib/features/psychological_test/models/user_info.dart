import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'user_info.g.dart';

/// 用户信息模型
@JsonSerializable()
@HiveType(typeId: 4)
class UserInfo {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int age;
  @HiveField(2)
  final String gender;
  @HiveField(3)
  final String occupation;
  @HiveField(4)
  final String education;
  @HiveField(5)
  final String maritalStatus;
  @HiveField(6)
  final String livingCondition;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final String? email;
  @HiveField(9)
  final String? phone;
  @HiveField(10)
  final List<String>? concerns; // 用户关注的心理健康问题
  @HiveField(11)
  final String? previousExperience; // 之前的心理健康经历
  @HiveField(12)
  final String graduationStatus; // 毕业状态

  const UserInfo({
    required this.id,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.education,
    required this.maritalStatus,
    required this.livingCondition,
    required this.createdAt,
    required this.graduationStatus,
    this.email,
    this.phone,
    this.concerns,
    this.previousExperience,
  });

  /// 从JSON创建UserInfo实例
  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  /// 创建副本
  UserInfo copyWith({
    String? id,
    int? age,
    String? gender,
    String? occupation,
    String? education,
    String? maritalStatus,
    String? livingCondition,
    DateTime? createdAt,
    String? graduationStatus,
    String? email,
    String? phone,
    List<String>? concerns,
    String? previousExperience,
  }) {
    return UserInfo(
      id: id ?? this.id,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      livingCondition: livingCondition ?? this.livingCondition,
      createdAt: createdAt ?? this.createdAt,
      graduationStatus: graduationStatus ?? this.graduationStatus,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      concerns: concerns ?? this.concerns,
      previousExperience: previousExperience ?? this.previousExperience,
    );
  }

  /// 验证用户信息是否完整
  bool get isValid {
    return id.isNotEmpty &&
        age > 0 &&
        gender.isNotEmpty &&
        occupation.isNotEmpty &&
        education.isNotEmpty &&
        maritalStatus.isNotEmpty &&
        livingCondition.isNotEmpty &&
        graduationStatus.isNotEmpty;
  }

  /// 获取用户年龄段
  String get ageGroup {
    if (age < 18) return '未成年';
    if (age < 25) return '青年早期';
    if (age < 35) return '青年期';
    if (age < 45) return '中年早期';
    if (age < 60) return '中年期';
    return '老年期';
  }

  /// 获取用户信息摘要（用于AI分析）
  String get summary {
    final buffer = StringBuffer();
    buffer.write('年龄：$age岁（$ageGroup）');
    buffer.write('，性别：$gender');
    buffer.write('，职业：$occupation');
    buffer.write('，教育背景：$education');
    buffer.write('，婚姻状况：$maritalStatus');
    buffer.write('，居住情况：$livingCondition');

    if (concerns != null && concerns!.isNotEmpty) {
      buffer.write('，关注问题：${concerns!.join('、')}');
    }

    if (previousExperience != null && previousExperience!.isNotEmpty) {
      buffer.write('，相关经历：$previousExperience');
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserInfo(id: $id, age: $age, gender: $gender, occupation: $occupation)';
  }
}

/// 性别枚举
enum Gender {
  male('男'),
  female('女'),
  other('其他');

  const Gender(this.displayName);
  final String displayName;

  static Gender fromString(String value) {
    switch (value) {
      case '男':
        return Gender.male;
      case '女':
        return Gender.female;
      case '其他':
        return Gender.other;
      default:
        return Gender.other;
    }
  }
}

/// 教育背景枚举
enum Education {
  primary('小学'),
  middle('初中'),
  high('高中'),
  college('大专'),
  bachelor('本科'),
  master('硕士'),
  doctor('博士');

  const Education(this.displayName);
  final String displayName;

  static Education fromString(String value) {
    for (final education in Education.values) {
      if (education.displayName == value) {
        return education;
      }
    }
    return Education.high;
  }
}

/// 婚姻状况枚举
enum MaritalStatus {
  single('单身'),
  married('已婚'),
  divorced('离异'),
  widowed('丧偶');

  const MaritalStatus(this.displayName);
  final String displayName;

  static MaritalStatus fromString(String value) {
    for (final status in MaritalStatus.values) {
      if (status.displayName == value) {
        return status;
      }
    }
    return MaritalStatus.single;
  }
}

/// 居住情况枚举
enum LivingCondition {
  alone('独居'),
  withFamily('与家人同住'),
  withRoommates('与室友同住'),
  withPartner('与伴侣同住'),
  dormitory('宿舍'),
  other('其他');

  const LivingCondition(this.displayName);
  final String displayName;

  static LivingCondition fromString(String value) {
    for (final condition in LivingCondition.values) {
      if (condition.displayName == value) {
        return condition;
      }
    }
    return LivingCondition.other;
  }
}

/// 毕业状态枚举
enum GraduationStatus {
  student('在校学生'),
  graduated('已毕业');

  const GraduationStatus(this.displayName);
  final String displayName;

  static GraduationStatus fromString(String value) {
    for (final status in GraduationStatus.values) {
      if (status.displayName == value) {
        return status;
      }
    }
    return GraduationStatus.student;
  }
}
