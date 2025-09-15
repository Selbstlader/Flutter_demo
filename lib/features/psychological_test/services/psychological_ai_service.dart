import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/error_handler.dart';
import '../config/psychological_ai_config.dart';
import '../models/user_info.dart';
import '../models/test_question.dart';
import '../models/test_session.dart';
import '../models/test_result.dart';

class PsychologicalAIService {
  static const String _endpoint = '/chat/completions';

  /// 根据用户信息生成个性化心理测试题目
  Stream<String> generateQuestions(UserInfo userInfo,
      {String? focusArea}) async* {
    // 检查网络连接
    final isConnected = await ConnectivityService.isConnected;
    if (!isConnected) {
      yield 'error:网络连接不可用，请检查网络设置';
      return;
    }

    int retryCount = 0;

    while (retryCount < PsychologicalAIConfig.maxRetries) {
      try {
        yield* _makeQuestionRequest(userInfo, focusArea: focusArea);
        return;
      } catch (e) {
        retryCount++;
        final errorMsg = ErrorHandler.handleError(e,
            context: 'PsychologicalAIService.generateQuestions');

        if (retryCount >= PsychologicalAIConfig.maxRetries) {
          yield 'error:$errorMsg (已重试${PsychologicalAIConfig.maxRetries}次)';
          return;
        }

        yield 'error:$errorMsg，正在重试... ($retryCount/${PsychologicalAIConfig.maxRetries})';
        await Future.delayed(PsychologicalAIConfig.retryDelay);
      }
    }
  }

  /// 根据用户信息和测试答案生成心理健康分析报告
  Stream<String> generateAnalysis(
      UserInfo userInfo, TestSession testSession) async* {
    // 检查网络连接
    final isConnected = await ConnectivityService.isConnected;
    if (!isConnected) {
      yield 'error:网络连接不可用，请检查网络设置';
      return;
    }

    int retryCount = 0;

    while (retryCount < PsychologicalAIConfig.maxRetries) {
      try {
        yield* _makeAnalysisRequest(userInfo, testSession);
        return;
      } catch (e) {
        retryCount++;
        final errorMsg = ErrorHandler.handleError(e,
            context: 'PsychologicalAIService.generateAnalysis');

        if (retryCount >= PsychologicalAIConfig.maxRetries) {
          yield 'error:$errorMsg (已重试${PsychologicalAIConfig.maxRetries}次)';
          return;
        }

        yield 'error:$errorMsg，正在重试... ($retryCount/${PsychologicalAIConfig.maxRetries})';
        await Future.delayed(PsychologicalAIConfig.retryDelay);
      }
    }
  }

  /// 生成题目的请求处理
  Stream<String> _makeQuestionRequest(UserInfo userInfo,
      {String? focusArea}) async* {
    final systemPrompt = '''你是一个专业的心理健康评估专家，负责生成个性化的心理测试题目。

用户基本信息：
- 年龄：${userInfo.age}岁
- 性别：${userInfo.gender}
- 教育程度：${userInfo.education}
- 婚姻状况：${userInfo.maritalStatus}
- 居住情况：${userInfo.livingCondition}
- 职业：${userInfo.occupation}
- 毕业状态：${userInfo.graduationStatus}
${focusArea != null ? '- 关注领域：$focusArea' : ''}

请根据用户信息生成${PsychologicalAIConfig.questionsPerSession}道心理测试题目，题目类型分布如下：
- 单选题：${PsychologicalAIConfig.questionTypeDistribution['single_choice']}道
- 多选题：${PsychologicalAIConfig.questionTypeDistribution['multiple_choice']}道
- 量表题：${PsychologicalAIConfig.questionTypeDistribution['scale']}道
- 文本输入题：${PsychologicalAIConfig.questionTypeDistribution['text_input']}道

要求：
1. 题目要针对用户的年龄、性别、教育背景等特点进行个性化设计
2. 涵盖情绪状态、压力水平、人际关系、自我认知等多个维度
3. 题目表述要专业、准确、易懂
4. 选项设计要合理，避免引导性答案
5. 量表题使用1-5分制，1表示完全不符合，5表示完全符合
6. **重要：根据毕业状态调整题目内容**：
   - 如果用户毕业状态为"已毕业"，则不要生成与学校、学业、考试、同学关系、校园生活等相关的题目
   - 如果用户毕业状态为"在校学生"，可以包含学业压力、同学关系、校园适应等相关题目
   - 针对已毕业用户，重点关注职场适应、工作压力、职业发展等方面
7. 返回JSON格式，包含题目ID、类型、题目内容、选项等信息

请直接返回JSON格式的题目数据，不要包含其他解释文字。''';

    final requestBody = {
      'model': PsychologicalAIConfig.model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': '请为我生成个性化的心理测试题目'},
      ],
      'stream': PsychologicalAIConfig.stream,
      'max_tokens': PsychologicalAIConfig.maxTokens,
      'temperature': PsychologicalAIConfig.temperature,
    };

    yield* _executeRequest(requestBody);
  }

  /// 生成分析报告的请求处理
  Stream<String> _makeAnalysisRequest(
      UserInfo userInfo, TestSession testSession) async* {
    // 构建答案摘要 - 使用题目序号和分类标注，不显示题目内容
    final answerSummary = testSession.answers.entries.map((entry) {
      final questionId = entry.key;
      final answer = entry.value;

      // 查找对应的题目
      final question = testSession.questions.firstWhere(
        (q) => q.id == questionId,
        orElse: () => TestQuestion(
          id: questionId,
          questionText: '',
          type: QuestionType.singleChoice,
          order: 0,
        ),
      );

      // 构建题目标识：使用题目内容而不是题目序号
      final questionLabel = question.questionText.isNotEmpty
          ? question.questionText
          : '题目${questionId}';

      return '$questionLabel: $answer';
    }).join('\n');

    final systemPrompt = '''你是一个专业的心理健康分析师，负责根据用户信息和测试答案生成详细的心理健康分析报告。

用户基本信息：
- 年龄：${userInfo.age}岁
- 性别：${userInfo.gender}
- 教育程度：${userInfo.education}
- 婚姻状况：${userInfo.maritalStatus}
- 居住情况：${userInfo.livingCondition}
- 职业：${userInfo.occupation}
- 毕业状态：${userInfo.graduationStatus}

测试完成情况：
- 测试时间：${testSession.createdAt}
- 完成进度：${testSession.progress.toStringAsFixed(1)}%
- 测试状态：${testSession.status.displayName}

用户答案：
$answerSummary

请生成一份专业的心理健康分析报告，包含以下内容：

1. **总体评估**：
   - 心理健康总体状况评分（0-100分）
   - 风险等级评估（低风险/中等风险/高风险）
   - 主要心理特征概述

2. **各维度分析**：
   - 情绪状态分析
   - 压力水平评估
   - 人际关系状况
   - 自我认知能力
   - 应对策略评估

3. **个性化洞察**：
   - 基于用户背景的个性化分析
   - 潜在的心理健康风险点
   - 个人优势和资源识别

4. **专业建议**：
   - 具体的改善建议
   - 推荐的心理健康维护方法
   - 是否需要专业心理咨询建议

5. **行动计划**：
   - 短期目标（1-2周）
   - 中期目标（1-3个月）
   - 长期目标（3-6个月）

要求：
- 分析要客观、专业、有依据
- 语言要温和、支持性，避免负面标签
- 建议要具体、可操作
- 考虑用户的文化背景和生活环境
- 如发现严重心理健康风险，要明确建议寻求专业帮助

请返回JSON格式的分析报告，包含各个维度的评分和详细分析内容。''';

    final requestBody = {
      'model': PsychologicalAIConfig.model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': '请为我生成详细的心理健康分析报告'},
      ],
      'stream': PsychologicalAIConfig.stream,
      'max_tokens': PsychologicalAIConfig.maxTokens,
      'temperature': PsychologicalAIConfig.temperature,
    };

    yield* _executeRequest(requestBody);
  }

  /// 执行HTTP请求的通用方法
  Stream<String> _executeRequest(Map<String, dynamic> requestBody) async* {
    final url = Uri.parse('${PsychologicalAIConfig.baseURL}$_endpoint');

    http.Client? client;
    try {
      // 创建带有自定义配置的HTTP客户端
      client = http.Client();

      final request = http.Request('POST', url);

      // 设置请求头
      request.headers.addAll({
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${PsychologicalAIConfig.apiKey}',
        'Accept': 'application/json',
        'User-Agent': 'Flutter-PsychologicalTest/1.0',
      });

      request.body = json.encode(requestBody);

      // 发送请求，设置超时
      final streamedResponse = await client.send(request).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('请求超时，请检查网络连接', const Duration(seconds: 30));
        },
      );

      if (streamedResponse.statusCode != 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        client.close();

        // 解析错误响应
        try {
          final errorData = json.decode(responseBody);
          final errorMsg =
              errorData['error']?['message'] ?? errorData['message'] ?? '未知错误';
          throw HttpException(
              'API错误 (${streamedResponse.statusCode}): $errorMsg');
        } catch (e) {
          throw HttpException(
              'HTTP ${streamedResponse.statusCode}: $responseBody');
        }
      }

      // 处理完整响应
      final responseBody = await streamedResponse.stream.bytesToString();
      client.close();

      try {
        final jsonData = json.decode(responseBody);
        final choices = jsonData['choices'] as List?;

        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'];
          final content = message?['content'] as String?;

          if (content != null && content.isNotEmpty) {
            yield content;
          }
        }
      } catch (e) {
        throw Exception('解析响应数据失败: ${e.toString()}');
      }
    } on TimeoutException catch (e) {
      throw Exception(
          '请求超时: ${ErrorHandler.handleError(e, context: 'PsychologicalAIService.timeout')}');
    } catch (e) {
      // 使用统一的错误处理
      final errorMessage = ErrorHandler.handleError(e,
          context: 'PsychologicalAIService._executeRequest');
      throw Exception('心理测试AI服务请求失败: $errorMessage');
    } finally {
      client?.close();
    }
  }

  /// 解析AI生成的题目JSON数据
  List<TestQuestion> parseGeneratedQuestions(String jsonResponse) {
    try {
      // 清理响应中的markdown代码块标记
      String cleanedResponse = jsonResponse.trim();

      // 移除开头的```json标记
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }

      // 移除结尾的```标记
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse =
            cleanedResponse.substring(0, cleanedResponse.length - 3);
      }

      // 再次清理首尾空白字符
      cleanedResponse = cleanedResponse.trim();

      // 验证清理后的数据不为空
      if (cleanedResponse.isEmpty) {
        throw Exception('清理后的JSON数据为空');
      }

      LoggerUtil.d('清理后的JSON数据: ${cleanedResponse.substring(0, cleanedResponse.length > 200 ? 200 : cleanedResponse.length)}...');

      final data = json.decode(cleanedResponse);

      // 支持两种格式：直接数组或包含questions/test_questions字段的对象
      List<dynamic> questionsJson;
      if (data is List) {
        questionsJson = data;
      } else if (data is Map) {
        if (data.containsKey('questions')) {
          questionsJson = data['questions'] as List;
        } else if (data.containsKey('test_questions')) {
          questionsJson = data['test_questions'] as List;
        } else {
          throw Exception(
              'Invalid response format: expected array or object with questions/test_questions field');
        }
      } else {
        throw Exception('Invalid response format: expected array or object');
      }

      return questionsJson.asMap().entries.map((entry) {
        final index = entry.key;
        final questionJson = entry.value as Map<String, dynamic>;

        // 转换AI返回的格式到TestQuestion格式
        final convertedJson = _convertQuestionFormat(questionJson, index);
        return TestQuestion.fromJson(convertedJson);
      }).toList();
    } catch (e) {
      throw Exception('解析AI生成的题目数据失败: ${e.toString()}');
    }
  }

  /// 转换AI返回的题目格式到TestQuestion格式
  Map<String, dynamic> _convertQuestionFormat(
      Map<String, dynamic> aiQuestion, int index) {
    // 转换题目类型
    String convertType(String aiType) {
      switch (aiType) {
        case 'single_choice':
          return 'single_choice';
        case 'multiple_choice':
          return 'multiple_choice';
        case 'scale':
          return 'scale';
        case 'text_input':
        case 'text':
          return 'text';
        default:
          return 'single_choice'; // 默认为单选
      }
    }

    final convertedQuestion = <String, dynamic>{
      'id': aiQuestion['id']?.toString() ?? 'q_$index',
      'questionText':
          aiQuestion['question'] ?? aiQuestion['questionText'] ?? '',
      'type': convertType(aiQuestion['type'] ?? 'single_choice'),
      'order': index + 1,
      'isRequired': true,
    };

    // 处理选项
    if (aiQuestion['options'] != null) {
      convertedQuestion['options'] = List<String>.from(aiQuestion['options']);
    }

    // 处理评分题的范围
    if (aiQuestion['scale_range'] != null) {
      final scaleRange = aiQuestion['scale_range'] as Map<String, dynamic>;
      convertedQuestion['scaleMin'] = scaleRange['min'] ?? 1;
      convertedQuestion['scaleMax'] = scaleRange['max'] ?? 5;
    }

    // 设置默认值
    convertedQuestion['category'] = aiQuestion['category'];
    convertedQuestion['weight'] = aiQuestion['weight'];
    convertedQuestion['description'] = aiQuestion['description'];

    return convertedQuestion;
  }

  /// 解析AI生成的分析报告JSON数据
  TestResult parseAnalysisResult(String jsonResponse, String sessionId) {
    try {
      final data = json.decode(jsonResponse);
      return TestResult.fromJson({
        ...data,
        'sessionId': sessionId,
        'generatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('解析AI生成的分析报告失败: ${e.toString()}');
    }
  }
}
