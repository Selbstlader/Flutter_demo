// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_security_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialSecurityModel _$SocialSecurityModelFromJson(Map<String, dynamic> json) => SocialSecurityModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      socialSecurityNumber: json['social_security_number'] as String,
      companyName: json['company_name'] as String?,
      paymentBase: (json['payment_base'] as num?)?.toDouble(),
      paymentRatio: (json['payment_ratio'] as num?)?.toDouble(),
      paymentAmount: (json['payment_amount'] as num?)?.toDouble(),
      paymentDate: json['payment_date'] == null
          ? null
          : DateTime.parse(json['payment_date'] as String),
      status: json['status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SocialSecurityModelToJson(SocialSecurityModel instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'social_security_number': instance.socialSecurityNumber,
      'company_name': instance.companyName,
      'payment_base': instance.paymentBase,
      'payment_ratio': instance.paymentRatio,
      'payment_amount': instance.paymentAmount,
      'payment_date': instance.paymentDate?.toIso8601String(),
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };