import 'package:json_annotation/json_annotation.dart';

part 'social_security_model.g.dart';

@JsonSerializable()
class SocialSecurityModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'social_security_number')
  final String socialSecurityNumber;
  @JsonKey(name: 'company_name')
  final String? companyName;
  @JsonKey(name: 'payment_base')
  final double? paymentBase;
  @JsonKey(name: 'payment_ratio')
  final double? paymentRatio;
  @JsonKey(name: 'payment_amount')
  final double? paymentAmount;
  @JsonKey(name: 'payment_date')
  final DateTime? paymentDate;
  final String? status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  SocialSecurityModel({
    required this.id,
    required this.userId,
    required this.socialSecurityNumber,
    this.companyName,
    this.paymentBase,
    this.paymentRatio,
    this.paymentAmount,
    this.paymentDate,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory SocialSecurityModel.fromJson(Map<String, dynamic> json) => _$SocialSecurityModelFromJson(json);
  Map<String, dynamic> toJson() => _$SocialSecurityModelToJson(this);
  
  SocialSecurityModel copyWith({
    String? id,
    String? userId,
    String? socialSecurityNumber,
    String? companyName,
    double? paymentBase,
    double? paymentRatio,
    double? paymentAmount,
    DateTime? paymentDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialSecurityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      socialSecurityNumber: socialSecurityNumber ?? this.socialSecurityNumber,
      companyName: companyName ?? this.companyName,
      paymentBase: paymentBase ?? this.paymentBase,
      paymentRatio: paymentRatio ?? this.paymentRatio,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'SocialSecurityModel(id: $id, userId: $userId, socialSecurityNumber: $socialSecurityNumber, companyName: $companyName, paymentBase: $paymentBase, paymentRatio: $paymentRatio, paymentAmount: $paymentAmount, paymentDate: $paymentDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SocialSecurityModel &&
      other.id == id &&
      other.userId == userId &&
      other.socialSecurityNumber == socialSecurityNumber &&
      other.companyName == companyName &&
      other.paymentBase == paymentBase &&
      other.paymentRatio == paymentRatio &&
      other.paymentAmount == paymentAmount &&
      other.paymentDate == paymentDate &&
      other.status == status &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      socialSecurityNumber.hashCode ^
      companyName.hashCode ^
      paymentBase.hashCode ^
      paymentRatio.hashCode ^
      paymentAmount.hashCode ^
      paymentDate.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}