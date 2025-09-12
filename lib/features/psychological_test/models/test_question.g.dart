// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestQuestionAdapter extends TypeAdapter<TestQuestion> {
  @override
  final int typeId = 0;

  @override
  TestQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestQuestion(
      id: fields[0] as String,
      questionText: fields[1] as String,
      type: fields[2] as QuestionType,
      order: fields[5] as int,
      options: (fields[3] as List?)?.cast<String>(),
      userAnswer: fields[4] as String?,
      category: fields[6] as String?,
      weight: fields[7] as int?,
      description: fields[8] as String?,
      isRequired: fields[9] as bool,
      scaleMin: fields[10] as int?,
      scaleMax: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TestQuestion obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.options)
      ..writeByte(4)
      ..write(obj.userAnswer)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.isRequired)
      ..writeByte(10)
      ..write(obj.scaleMin)
      ..writeByte(11)
      ..write(obj.scaleMax);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final int typeId = 1;

  @override
  QuestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestionType.singleChoice;
      case 1:
        return QuestionType.multipleChoice;
      case 2:
        return QuestionType.scale;
      case 3:
        return QuestionType.text;
      default:
        return QuestionType.singleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    switch (obj) {
      case QuestionType.singleChoice:
        writer.writeByte(0);
        break;
      case QuestionType.multipleChoice:
        writer.writeByte(1);
        break;
      case QuestionType.scale:
        writer.writeByte(2);
        break;
      case QuestionType.text:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestQuestion _$TestQuestionFromJson(Map<String, dynamic> json) => TestQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      order: (json['order'] as num).toInt(),
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      userAnswer: json['userAnswer'] as String?,
      category: json['category'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool? ?? true,
      scaleMin: (json['scaleMin'] as num?)?.toInt(),
      scaleMax: (json['scaleMax'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TestQuestionToJson(TestQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionText': instance.questionText,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'options': instance.options,
      'userAnswer': instance.userAnswer,
      'order': instance.order,
      'category': instance.category,
      'weight': instance.weight,
      'description': instance.description,
      'isRequired': instance.isRequired,
      'scaleMin': instance.scaleMin,
      'scaleMax': instance.scaleMax,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.singleChoice: 'single_choice',
  QuestionType.multipleChoice: 'multiple_choice',
  QuestionType.scale: 'scale',
  QuestionType.text: 'text',
};
