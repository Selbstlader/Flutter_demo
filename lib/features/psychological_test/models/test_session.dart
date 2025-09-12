import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import 'test_question.dart';
import 'user_info.dart';

part 'test_session.g.dart';

/// 测试会话模型
@JsonSerializable()
@HiveType(typeId: 2)
class TestSession {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userInfoId;
  @HiveField(2)
  final List<TestQuestion> questions;
  @HiveField(3)
  final Map<String, String> answers;
  @HiveField(4)
  final String? analysis;
  @HiveField(5)
  final int? score;
  @HiveField(6)
  final DateTime? completedAt;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final TestStatus status;
  @HiveField(9)
  final String? sessionType; // 测试类型（如：综合评估、专项测试等）
  @HiveField(10)
  final Map<String, dynamic>? metadata; // 额外元数据
  @HiveField(11)
  final List<String>? recommendations; // AI推荐建议
  @HiveField(12)
  final Map<String, int>? categoryScores; // 各分类得分
  
  const TestSession({
    required this.id,
    required this.userInfoId,
    required this.questions,
    required this.answers,
    required this.createdAt,
    required this.status,
    this.analysis,
    this.score,
    this.completedAt,
    this.sessionType,
    this.metadata,
    this.recommendations,
    this.categoryScores,
  });
  
  /// 从JSON创建TestSession实例
  factory TestSession.fromJson(Map<String, dynamic> json) => _$TestSessionFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TestSessionToJson(this);
  
  /// 创建副本
  TestSession copyWith({
    String? id,
    String? userInfoId,
    List<TestQuestion>? questions,
    Map<String, String>? answers,
    String? analysis,
    int? score,
    DateTime? completedAt,
    DateTime? createdAt,
    TestStatus? status,
    String? sessionType,
    Map<String, dynamic>? metadata,
    List<String>? recommendations,
    Map<String, int>? categoryScores,
  }) {
    return TestSession(
      id: id ?? this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      analysis: analysis ?? this.analysis,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      metadata: metadata ?? this.metadata,
      recommendations: recommendations ?? this.recommendations,
      categoryScores: categoryScores ?? this.categoryScores,
    );
  }
  
  /// 更新答案
  TestSession updateAnswer(String questionId, String answer) {
    final newAnswers = Map<String, String>.from(answers);
    newAnswers[questionId] = answer;
    
    // 更新对应题目的答案
    final updatedQuestions = questions.map((q) {
      if (q.id == questionId) {
        return q.withAnswer(answer);
      }
      return q;
    }).toList();
    
    return copyWith(
      answers: newAnswers,
      questions: updatedQuestions,
    );
  }
  
  /// 完成测试
  TestSession complete({
    String? analysis,
    int? score,
    List<String>? recommendations,
    Map<String, int>? categoryScores,
  }) {
    return copyWith(
      status: TestStatus.completed,
      completedAt: DateTime.now(),
      analysis: analysis,
      score: score,
      recommendations: recommendations,
      categoryScores: categoryScores,
    );
  }
  
  /// 暂停测试
  TestSession pause() {
    return copyWith(status: TestStatus.paused);
  }
  
  /// 恢复测试
  TestSession resume() {
    return copyWith(status: TestStatus.inProgress);
  }
  
  /// 获取当前进度
  double get progress {
    if (questions.isEmpty) return 0.0;
    final answeredCount = questions.where((q) => q.isAnswered).length;
    return answeredCount / questions.length;
  }
  
  /// 获取已回答题目数量
  int get answeredCount {
    return questions.where((q) => q.isAnswered).length;
  }
  
  /// 获取总题目数量
  int get totalQuestions => questions.length;
  
  /// 检查是否所有必答题都已回答
  bool get isAllRequiredAnswered {
    return questions
        .where((q) => q.isRequired)
        .every((q) => q.isAnswered);
  }
  
  /// 检查是否可以提交
  bool get canSubmit {
    return isAllRequiredAnswered && status == TestStatus.inProgress;
  }
  
  /// 获取下一个未回答的题目
  TestQuestion? get nextUnansweredQuestion {
    return questions
        .where((q) => !q.isAnswered)
        .isNotEmpty
        ? questions.where((q) => !q.isAnswered).first
        : null;
  }
  
  /// 获取当前题目索引
  int get currentQuestionIndex {
    final nextQuestion = nextUnansweredQuestion;
    if (nextQuestion == null) return questions.length - 1;
    return questions.indexOf(nextQuestion);
  }
  
  /// 计算总分
  int get calculatedScore {
    if (score != null) return score!;
    return questions
        .where((q) => q.isAnswered)
        .map((q) => q.answerScore * (q.weight ?? 1))
        .fold(0, (sum, score) => sum + score);
  }
  
  /// 获取各分类得分
  Map<String, int> get calculatedCategoryScores {
    if (categoryScores != null) return categoryScores!;
    
    final scores = <String, int>{};
    final categoryQuestions = <String, List<TestQuestion>>{};
    
    // 按分类分组题目
    for (final question in questions.where((q) => q.isAnswered)) {
      final category = question.category ?? 'general';
      categoryQuestions.putIfAbsent(category, () => []).add(question);
    }
    
    // 计算各分类得分
    for (final entry in categoryQuestions.entries) {
      final categoryScore = entry.value
          .map((q) => q.answerScore * (q.weight ?? 1))
          .fold(0, (sum, score) => sum + score);
      scores[entry.key] = categoryScore;
    }
    
    return scores;
  }
  
  /// 获取测试时长
  Duration get duration {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(createdAt);
  }
  
  /// 获取格式化的测试时长
  String get formattedDuration {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else if (minutes > 0) {
      return '${minutes}分钟${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }
  
  /// 获取风险等级
  RiskLevel get riskLevel {
    final totalScore = calculatedScore;
    final maxScore = questions.length * 10; // 假设最高分为10分/题
    final percentage = totalScore / maxScore;
    
    if (percentage >= 0.8) return RiskLevel.high;
    if (percentage >= 0.6) return RiskLevel.medium;
    if (percentage >= 0.4) return RiskLevel.low;
    return RiskLevel.minimal;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestSession && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'TestSession(id: $id, status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}

/// 测试状态枚举
@JsonEnum()
@HiveType(typeId: 3)
enum TestStatus {
  @JsonValue('created')
  @HiveField(0)
  created,
  
  @JsonValue('in_progress')
  @HiveField(1)
  inProgress,
  
  @JsonValue('paused')
  @HiveField(2)
  paused,
  
  @JsonValue('completed')
  @HiveField(3)
  completed,
  
  @JsonValue('cancelled')
  @HiveField(4)
  cancelled;
  
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case TestStatus.created:
        return '已创建';
      case TestStatus.inProgress:
        return '进行中';
      case TestStatus.paused:
        return '已暂停';
      case TestStatus.completed:
        return '已完成';
      case TestStatus.cancelled:
        return '已取消';
    }
  }
  
  /// 获取颜色
  String get colorHex {
    switch (this) {
      case TestStatus.created:
        return '#9CA3AF';
      case TestStatus.inProgress:
        return '#3B82F6';
      case TestStatus.paused:
        return '#F59E0B';
      case TestStatus.completed:
        return '#10B981';
      case TestStatus.cancelled:
        return '#EF4444';
    }
  }
}

/// 风险等级枚举
enum RiskLevel {
  minimal('极低风险'),
  low('低风险'),
  medium('中等风险'),
  high('高风险');
  
  const RiskLevel(this.displayName);
  final String displayName;
  
  /// 获取颜色
  String get colorHex {
    switch (this) {
      case RiskLevel.minimal:
        return '#10B981';
      case RiskLevel.low:
        return '#84CC16';
      case RiskLevel.medium:
        return '#F59E0B';
      case RiskLevel.high:
        return '#EF4444';
    }
  }
}