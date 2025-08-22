import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 用户模型
@JsonSerializable()
class UserModel {
  /// 用户ID
  @JsonKey(name: 'id')
  final String id;

  /// 用户名
  @JsonKey(name: 'username')
  final String username;

  /// 邮箱
  @JsonKey(name: 'email')
  final String email;

  /// 手机号
  @JsonKey(name: 'phone')
  final String? phone;

  /// 昵称
  @JsonKey(name: 'nickname')
  final String? nickname;

  /// 头像URL
  @JsonKey(name: 'avatar')
  final String? avatar;

  /// 性别 (0: 未知, 1: 男, 2: 女)
  @JsonKey(name: 'gender')
  final int? gender;

  /// 生日
  @JsonKey(name: 'birthday')
  final String? birthday;

  /// 个人简介
  @JsonKey(name: 'bio')
  final String? bio;

  /// 创建时间
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// 更新时间
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  /// 是否已验证邮箱
  @JsonKey(name: 'email_verified')
  final bool emailVerified;

  /// 是否已验证手机号
  @JsonKey(name: 'phone_verified')
  final bool phoneVerified;

  /// 用户状态 (0: 正常, 1: 禁用)
  @JsonKey(name: 'status')
  final int status;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.nickname,
    this.avatar,
    this.gender,
    this.birthday,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.status = 0,
  });

  /// 从JSON创建实例
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// 获取显示名称
  String get displayName => nickname ?? username;

  /// 获取性别文本
  String get genderText {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未知';
    }
  }

  /// 是否为正常状态
  bool get isActive => status == 0;

  /// 是否已完善个人信息
  bool get isProfileComplete {
    return nickname != null && 
           avatar != null && 
           phone != null && 
           gender != null;
  }

  /// 复制并更新部分字段
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? nickname,
    String? avatar,
    int? gender,
    String? birthday,
    String? bio,
    String? createdAt,
    String? updatedAt,
    bool? emailVerified,
    bool? phoneVerified,
    int? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, email: $email, '
        'nickname: $nickname, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}