// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInfoAdapter extends TypeAdapter<UserInfo> {
  @override
  final int typeId = 4;

  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfo(
      id: fields[0] as String,
      age: fields[1] as int,
      gender: fields[2] as String,
      occupation: fields[3] as String,
      education: fields[4] as String,
      maritalStatus: fields[5] as String,
      livingCondition: fields[6] as String,
      createdAt: fields[7] as DateTime,
      graduationStatus: fields[12] as String,
      email: fields[8] as String?,
      phone: fields[9] as String?,
      concerns: (fields[10] as List?)?.cast<String>(),
      previousExperience: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfo obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.occupation)
      ..writeByte(4)
      ..write(obj.education)
      ..writeByte(5)
      ..write(obj.maritalStatus)
      ..writeByte(6)
      ..write(obj.livingCondition)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.email)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.concerns)
      ..writeByte(11)
      ..write(obj.previousExperience)
      ..writeByte(12)
      ..write(obj.graduationStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      id: json['id'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      occupation: json['occupation'] as String,
      education: json['education'] as String,
      maritalStatus: json['maritalStatus'] as String,
      livingCondition: json['livingCondition'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      graduationStatus: json['graduationStatus'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      concerns: (json['concerns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      previousExperience: json['previousExperience'] as String?,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'id': instance.id,
      'age': instance.age,
      'gender': instance.gender,
      'occupation': instance.occupation,
      'education': instance.education,
      'maritalStatus': instance.maritalStatus,
      'livingCondition': instance.livingCondition,
      'createdAt': instance.createdAt.toIso8601String(),
      'email': instance.email,
      'phone': instance.phone,
      'concerns': instance.concerns,
      'previousExperience': instance.previousExperience,
      'graduationStatus': instance.graduationStatus,
    };
