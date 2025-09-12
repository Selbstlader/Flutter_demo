// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestSessionAdapter extends TypeAdapter<TestSession> {
  @override
  final int typeId = 2;

  @override
  TestSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestSession(
      id: fields[0] as String,
      userInfoId: fields[1] as String,
      questions: (fields[2] as List).cast<TestQuestion>(),
      answers: (fields[3] as Map).cast<String, String>(),
      createdAt: fields[7] as DateTime,
      status: fields[8] as TestStatus,
      analysis: fields[4] as String?,
      score: fields[5] as int?,
      completedAt: fields[6] as DateTime?,
      sessionType: fields[9] as String?,
      metadata: (fields[10] as Map?)?.cast<String, dynamic>(),
      recommendations: (fields[11] as List?)?.cast<String>(),
      categoryScores: (fields[12] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, TestSession obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userInfoId)
      ..writeByte(2)
      ..write(obj.questions)
      ..writeByte(3)
      ..write(obj.answers)
      ..writeByte(4)
      ..write(obj.analysis)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.sessionType)
      ..writeByte(10)
      ..write(obj.metadata)
      ..writeByte(11)
      ..write(obj.recommendations)
      ..writeByte(12)
      ..write(obj.categoryScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TestStatusAdapter extends TypeAdapter<TestStatus> {
  @override
  final int typeId = 3;

  @override
  TestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TestStatus.created;
      case 1:
        return TestStatus.inProgress;
      case 2:
        return TestStatus.paused;
      case 3:
        return TestStatus.completed;
      case 4:
        return TestStatus.cancelled;
      default:
        return TestStatus.created;
    }
  }

  @override
  void write(BinaryWriter writer, TestStatus obj) {
    switch (obj) {
      case TestStatus.created:
        writer.writeByte(0);
        break;
      case TestStatus.inProgress:
        writer.writeByte(1);
        break;
      case TestStatus.paused:
        writer.writeByte(2);
        break;
      case TestStatus.completed:
        writer.writeByte(3);
        break;
      case TestStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestSession _$TestSessionFromJson(Map<String, dynamic> json) => TestSession(
      id: json['id'] as String,
      userInfoId: json['userInfoId'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => TestQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      answers: Map<String, String>.from(json['answers'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$TestStatusEnumMap, json['status']),
      analysis: json['analysis'] as String?,
      score: (json['score'] as num?)?.toInt(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      sessionType: json['sessionType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      categoryScores: (json['categoryScores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$TestSessionToJson(TestSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userInfoId': instance.userInfoId,
      'questions': instance.questions,
      'answers': instance.answers,
      'analysis': instance.analysis,
      'score': instance.score,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$TestStatusEnumMap[instance.status]!,
      'sessionType': instance.sessionType,
      'metadata': instance.metadata,
      'recommendations': instance.recommendations,
      'categoryScores': instance.categoryScores,
    };

const _$TestStatusEnumMap = {
  TestStatus.created: 'created',
  TestStatus.inProgress: 'in_progress',
  TestStatus.paused: 'paused',
  TestStatus.completed: 'completed',
  TestStatus.cancelled: 'cancelled',
};
