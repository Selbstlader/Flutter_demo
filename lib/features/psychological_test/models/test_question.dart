import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'test_question.g.dart';

/// 测试题目模型
@JsonSerializable()
@HiveType(typeId: 0)
class TestQuestion {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String questionText;
  @HiveField(2)
  final QuestionType type;
  @HiveField(3)
  final List<String>? options;
  @HiveField(4)
  final String? userAnswer;
  @HiveField(5)
  final int order;
  @HiveField(6)
  final String? category; // 题目分类（如：情绪、压力、人际关系等）
  @HiveField(7)
  final int? weight; // 题目权重
  @HiveField(8)
  final String? description; // 题目说明
  @HiveField(9)
  final bool isRequired; // 是否必答
  @HiveField(10)
  final int? scaleMin; // 评分题最小值
  @HiveField(11)
  final int? scaleMax; // 评分题最大值

  const TestQuestion({
    required this.id,
    required this.questionText,
    required this.type,
    required this.order,
    this.options,
    this.userAnswer,
    this.category,
    this.weight,
    this.description,
    this.isRequired = true,
    this.scaleMin,
    this.scaleMax,
  });

  /// 从JSON创建TestQuestion实例
  factory TestQuestion.fromJson(Map<String, dynamic> json) =>
      _$TestQuestionFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TestQuestionToJson(this);

  /// 创建副本
  TestQuestion copyWith({
    String? id,
    String? questionText,
    QuestionType? type,
    List<String>? options,
    String? userAnswer,
    int? order,
    String? category,
    int? weight,
    String? description,
    bool? isRequired,
    int? scaleMin,
    int? scaleMax,
  }) {
    return TestQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      options: options ?? this.options,
      userAnswer: userAnswer ?? this.userAnswer,
      order: order ?? this.order,
      category: category ?? this.category,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      scaleMin: scaleMin ?? this.scaleMin,
      scaleMax: scaleMax ?? this.scaleMax,
    );
  }

  /// 设置用户答案
  TestQuestion withAnswer(String answer) {
    return copyWith(userAnswer: answer);
  }

  /// 检查是否已回答
  bool get isAnswered {
    return userAnswer != null && userAnswer!.isNotEmpty;
  }

  /// 检查答案是否有效
  bool get isValidAnswer {
    if (!isAnswered) return !isRequired;

    switch (type) {
      case QuestionType.singleChoice:
        return options?.contains(userAnswer) ?? false;
      case QuestionType.multipleChoice:
        if (userAnswer == null) return false;
        final selectedOptions = userAnswer!.split(',');
        return selectedOptions
            .every((option) => options?.contains(option.trim()) ?? false);
      case QuestionType.scale:
        final value = int.tryParse(userAnswer!);
        return value != null && value >= 1 && value <= 10;
      case QuestionType.text:
        return userAnswer!.trim().isNotEmpty;
    }
  }

  /// 获取答案分数（用于评分）
  int get answerScore {
    if (!isAnswered) return 0;

    switch (type) {
      case QuestionType.singleChoice:
        // 根据选项位置计算分数
        final index = options?.indexOf(userAnswer!) ?? -1;
        return index >= 0 ? index + 1 : 0;
      case QuestionType.multipleChoice:
        // 多选题按选择数量计分
        return userAnswer!.split(',').length;
      case QuestionType.scale:
        return int.tryParse(userAnswer!) ?? 0;
      case QuestionType.text:
        // 文本题默认分数
        return 5;
    }
  }

  /// 获取格式化的用户答案
  String get formattedAnswer {
    if (!isAnswered) return '未回答';

    switch (type) {
      case QuestionType.singleChoice:
        return userAnswer!;
      case QuestionType.multipleChoice:
        return userAnswer!.replaceAll(',', '、');
      case QuestionType.scale:
        return '$userAnswer 分';
      case QuestionType.text:
        return userAnswer!;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TestQuestion(id: $id, order: $order, type: $type, answered: $isAnswered)';
  }
}

/// 题目类型枚举
@JsonEnum()
@HiveType(typeId: 1)
enum QuestionType {
  @JsonValue('single_choice')
  @HiveField(0)
  singleChoice,

  @JsonValue('multiple_choice')
  @HiveField(1)
  multipleChoice,

  @JsonValue('scale')
  @HiveField(2)
  scale,

  @JsonValue('text')
  @HiveField(3)
  text;

  /// 获取显示名称
  String get displayName {
    switch (this) {
      case QuestionType.singleChoice:
        return '单选题';
      case QuestionType.multipleChoice:
        return '多选题';
      case QuestionType.scale:
        return '评分题';
      case QuestionType.text:
        return '文本题';
    }
  }

  /// 获取图标
  String get icon {
    switch (this) {
      case QuestionType.singleChoice:
        return '●';
      case QuestionType.multipleChoice:
        return '☐';
      case QuestionType.scale:
        return '★';
      case QuestionType.text:
        return '✎';
    }
  }

  /// 获取颜色
  Color get color {
    switch (this) {
      case QuestionType.singleChoice:
        return const Color(0xFF3B82F6);
      case QuestionType.multipleChoice:
        return const Color(0xFF10B981);
      case QuestionType.scale:
        return const Color(0xFFF59E0B);
      case QuestionType.text:
        return const Color(0xFF8B5CF6);
    }
  }
}

/// 题目分类枚举
enum QuestionCategory {
  emotion('情绪状态'),
  stress('压力水平'),
  relationship('人际关系'),
  sleep('睡眠质量'),
  work('工作状态'),
  family('家庭关系'),
  health('身体健康'),
  lifestyle('生活方式'),
  personality('性格特征'),
  coping('应对方式');

  const QuestionCategory(this.displayName);
  final String displayName;

  static QuestionCategory fromString(String value) {
    for (final category in QuestionCategory.values) {
      if (category.displayName == value) {
        return category;
      }
    }
    return QuestionCategory.emotion;
  }
}
