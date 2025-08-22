// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      gender: json['gender'] as int?,
      birthday: json['birthday'] as String?,
      bio: json['bio'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      status: json['status'] as int? ?? 0,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'phone': instance.phone,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'gender': instance.gender,
      'birthday': instance.birthday,
      'bio': instance.bio,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'email_verified': instance.emailVerified,
      'phone_verified': instance.phoneVerified,
      'status': instance.status,
    };