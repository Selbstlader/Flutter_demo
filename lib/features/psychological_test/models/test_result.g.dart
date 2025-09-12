// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResultInsightAdapter extends TypeAdapter<ResultInsight> {
  @override
  final int typeId = 5;

  @override
  ResultInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResultInsight(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as InsightType,
      importance: fields[4] as InsightImportance,
      category: fields[5] as String?,
      data: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ResultInsight obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.importance)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightTypeAdapter extends TypeAdapter<InsightType> {
  @override
  final int typeId = 6;

  @override
  InsightType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InsightType.strength;
      case 1:
        return InsightType.weakness;
      case 2:
        return InsightType.opportunity;
      case 3:
        return InsightType.risk;
      case 4:
        return InsightType.pattern;
      case 5:
        return InsightType.trend;
      default:
        return InsightType.strength;
    }
  }

  @override
  void write(BinaryWriter writer, InsightType obj) {
    switch (obj) {
      case InsightType.strength:
        writer.writeByte(0);
        break;
      case InsightType.weakness:
        writer.writeByte(1);
        break;
      case InsightType.opportunity:
        writer.writeByte(2);
        break;
      case InsightType.risk:
        writer.writeByte(3);
        break;
      case InsightType.pattern:
        writer.writeByte(4);
        break;
      case InsightType.trend:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightImportanceAdapter extends TypeAdapter<InsightImportance> {
  @override
  final int typeId = 7;

  @override
  InsightImportance read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InsightImportance.low;
      case 1:
        return InsightImportance.medium;
      case 2:
        return InsightImportance.high;
      case 3:
        return InsightImportance.critical;
      default:
        return InsightImportance.low;
    }
  }

  @override
  void write(BinaryWriter writer, InsightImportance obj) {
    switch (obj) {
      case InsightImportance.low:
        writer.writeByte(0);
        break;
      case InsightImportance.medium:
        writer.writeByte(1);
        break;
      case InsightImportance.high:
        writer.writeByte(2);
        break;
      case InsightImportance.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightImportanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestResult _$TestResultFromJson(Map<String, dynamic> json) => TestResult(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      userInfoId: json['userInfoId'] as String,
      totalScore: (json['totalScore'] as num).toInt(),
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
      analysis: json['analysis'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => ResultInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      aiModel: json['aiModel'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      summary: json['summary'] as String?,
      aiAnalysis: json['aiAnalysis'] as String?,
    );

Map<String, dynamic> _$TestResultToJson(TestResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'userInfoId': instance.userInfoId,
      'totalScore': instance.totalScore,
      'categoryScores': instance.categoryScores,
      'analysis': instance.analysis,
      'recommendations': instance.recommendations,
      'insights': instance.insights,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'aiModel': instance.aiModel,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'summary': instance.summary,
      'aiAnalysis': instance.aiAnalysis,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.minimal: 'minimal',
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
};

ResultInsight _$ResultInsightFromJson(Map<String, dynamic> json) =>
    ResultInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      importance: $enumDecode(_$InsightImportanceEnumMap, json['importance']),
      category: json['category'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResultInsightToJson(ResultInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$InsightTypeEnumMap[instance.type]!,
      'importance': _$InsightImportanceEnumMap[instance.importance]!,
      'category': instance.category,
      'data': instance.data,
    };

const _$InsightTypeEnumMap = {
  InsightType.strength: 'strength',
  InsightType.weakness: 'weakness',
  InsightType.opportunity: 'opportunity',
  InsightType.risk: 'risk',
  InsightType.pattern: 'pattern',
  InsightType.trend: 'trend',
};

const _$InsightImportanceEnumMap = {
  InsightImportance.low: 'low',
  InsightImportance.medium: 'medium',
  InsightImportance.high: 'high',
  InsightImportance.critical: 'critical',
};
