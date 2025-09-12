import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'test_session.dart';

part 'test_result.g.dart';

/// 测试结果模型
@JsonSerializable()
class TestResult {
  final String id;
  final String sessionId;
  final String userInfoId;
  final int totalScore;
  final Map<String, int> categoryScores;
  final String analysis;
  final List<String> recommendations;
  final List<ResultInsight> insights;
  final RiskLevel riskLevel;
  final DateTime createdAt;
  final String? aiModel; // 使用的AI模型
  final Map<String, dynamic>? metadata; // 额外元数据
  final List<String>? tags; // 结果标签
  final String? summary; // 结果摘要
  final String? aiAnalysis; // AI分析结果
  
  const TestResult({
    required this.id,
    required this.sessionId,
    required this.userInfoId,
    required this.totalScore,
    required this.categoryScores,
    required this.analysis,
    required this.recommendations,
    required this.insights,
    required this.riskLevel,
    required this.createdAt,
    this.aiModel,
    this.metadata,
    this.tags,
    this.summary,
    this.aiAnalysis,
  });
  
  /// 从JSON创建TestResult实例
  factory TestResult.fromJson(Map<String, dynamic> json) => _$TestResultFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TestResultToJson(this);
  
  /// 创建副本
  TestResult copyWith({
    String? id,
    String? sessionId,
    String? userInfoId,
    int? totalScore,
    Map<String, int>? categoryScores,
    String? analysis,
    List<String>? recommendations,
    List<ResultInsight>? insights,
    RiskLevel? riskLevel,
    DateTime? createdAt,
    String? aiModel,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? summary,
    String? aiAnalysis,
  }) {
    return TestResult(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userInfoId: userInfoId ?? this.userInfoId,
      totalScore: totalScore ?? this.totalScore,
      categoryScores: categoryScores ?? this.categoryScores,
      analysis: analysis ?? this.analysis,
      recommendations: recommendations ?? this.recommendations,
      insights: insights ?? this.insights,
      riskLevel: riskLevel ?? this.riskLevel,
      createdAt: createdAt ?? this.createdAt,
      aiModel: aiModel ?? this.aiModel,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }
  
  /// 获取最高分类别
  String get topCategory {
    if (categoryScores.isEmpty) return '综合';
    return categoryScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// 获取最低分类别
  String get lowestCategory {
    if (categoryScores.isEmpty) return '综合';
    return categoryScores.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }
  
  /// 获取平均分
  double get averageScore {
    if (categoryScores.isEmpty) return 0.0;
    final total = categoryScores.values.fold(0, (sum, score) => sum + score);
    return total / categoryScores.length;
  }
  
  /// 获取总体分数（别名）
  int get overallScore => totalScore;
  
  /// 获取分数百分比
  double get scorePercentage {
    const maxScore = 100; // 假设满分为100
    return (totalScore / maxScore).clamp(0.0, 1.0);
  }
  
  /// 获取风险等级描述
  String get riskDescription {
    switch (riskLevel) {
      case RiskLevel.minimal:
        return '您的心理健康状况良好，请继续保持积极的生活态度。';
      case RiskLevel.low:
        return '您的心理健康状况基本正常，建议关注一些细节问题。';
      case RiskLevel.medium:
        return '您可能存在一些心理健康问题，建议寻求专业帮助。';
      case RiskLevel.high:
        return '您的心理健康状况需要引起重视，强烈建议咨询专业心理医生。';
    }
  }
  
  /// 获取主要洞察
  List<ResultInsight> get primaryInsights {
    return insights.where((insight) => insight.importance == InsightImportance.high).toList();
  }
  
  /// 获取次要洞察
  List<ResultInsight> get secondaryInsights {
    return insights.where((insight) => insight.importance != InsightImportance.high).toList();
  }
  
  /// 获取优先推荐
  List<String> get priorityRecommendations {
    return recommendations.take(3).toList();
  }
  
  /// 获取格式化的创建时间
  String get formattedDate {
    return '${createdAt.year}年${createdAt.month}月${createdAt.day}日';
  }
  
  /// 获取详细的创建时间
  String get detailedFormattedDate {
    return '${createdAt.year}年${createdAt.month}月${createdAt.day}日 '
           '${createdAt.hour.toString().padLeft(2, '0')}:'
           '${createdAt.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestResult && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'TestResult(id: $id, totalScore: $totalScore, riskLevel: $riskLevel)';
  }
}

/// 结果洞察模型
@JsonSerializable()
@HiveType(typeId: 5)
class ResultInsight {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final InsightType type;
  @HiveField(4)
  final InsightImportance importance;
  @HiveField(5)
  final String? category;
  @HiveField(6)
  final Map<String, dynamic>? data;
  
  const ResultInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.importance,
    this.category,
    this.data,
  });
  
  /// 从JSON创建ResultInsight实例
  factory ResultInsight.fromJson(Map<String, dynamic> json) => _$ResultInsightFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ResultInsightToJson(this);
  
  /// 创建副本
  ResultInsight copyWith({
    String? id,
    String? title,
    String? description,
    InsightType? type,
    InsightImportance? importance,
    String? category,
    Map<String, dynamic>? data,
  }) {
    return ResultInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      importance: importance ?? this.importance,
      category: category ?? this.category,
      data: data ?? this.data,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResultInsight && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// 洞察类型枚举
@JsonEnum()
@HiveType(typeId: 6)
enum InsightType {
  @JsonValue('strength')
  @HiveField(0)
  strength,
  
  @JsonValue('weakness')
  @HiveField(1)
  weakness,
  
  @JsonValue('opportunity')
  @HiveField(2)
  opportunity,
  
  @JsonValue('risk')
  @HiveField(3)
  risk,
  
  @JsonValue('pattern')
  @HiveField(4)
  pattern,
  
  @JsonValue('trend')
  @HiveField(5)
  trend;
  
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case InsightType.strength:
        return '优势';
      case InsightType.weakness:
        return '待改善';
      case InsightType.opportunity:
        return '机会';
      case InsightType.risk:
        return '风险';
      case InsightType.pattern:
        return '模式';
      case InsightType.trend:
        return '趋势';
    }
  }
  
  /// 获取图标
  IconData get icon {
    switch (this) {
      case InsightType.strength:
        return Icons.trending_up;
      case InsightType.weakness:
        return Icons.build;
      case InsightType.opportunity:
        return Icons.star;
      case InsightType.risk:
        return Icons.warning;
      case InsightType.pattern:
        return Icons.search;
      case InsightType.trend:
        return Icons.show_chart;
    }
  }
  
  /// 获取颜色
  String get colorHex {
    switch (this) {
      case InsightType.strength:
        return '#10B981';
      case InsightType.weakness:
        return '#F59E0B';
      case InsightType.opportunity:
        return '#3B82F6';
      case InsightType.risk:
        return '#EF4444';
      case InsightType.pattern:
        return '#8B5CF6';
      case InsightType.trend:
        return '#06B6D4';
    }
  }
}

/// 洞察重要性枚举
@JsonEnum()
@HiveType(typeId: 7)
enum InsightImportance {
  @JsonValue('low')
  @HiveField(0)
  low,
  
  @JsonValue('medium')
  @HiveField(1)
  medium,
  
  @JsonValue('high')
  @HiveField(2)
  high,
  
  @JsonValue('critical')
  @HiveField(3)
  critical;
  
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case InsightImportance.low:
        return '一般';
      case InsightImportance.medium:
        return '重要';
      case InsightImportance.high:
        return '很重要';
      case InsightImportance.critical:
        return '非常重要';
    }
  }
  
  /// 获取优先级数值
  int get priority {
    switch (this) {
      case InsightImportance.low:
        return 1;
      case InsightImportance.medium:
        return 2;
      case InsightImportance.high:
        return 3;
      case InsightImportance.critical:
        return 4;
    }
  }
}