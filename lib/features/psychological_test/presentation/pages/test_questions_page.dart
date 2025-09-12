import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/widgets/safe_area_scaffold.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/services/storage_service.dart';
import '../../models/user_info.dart';
import '../../models/test_question.dart';
import '../../models/test_session.dart';
import '../../services/psychological_ai_service.dart';

class TestQuestionsPage extends StatefulWidget {
  final String userInfoId;

  const TestQuestionsPage({
    super.key,
    required this.userInfoId,
  });

  @override
  State<TestQuestionsPage> createState() => _TestQuestionsPageState();
}

class _TestQuestionsPageState extends State<TestQuestionsPage> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService.instance;
  final PsychologicalAIService _aiService = PsychologicalAIService();

  UserInfo? _userInfo;
  TestSession? _testSession;
  List<TestQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeTest();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeTest() async {
    try {
      print('开始初始化测试，userInfoId: ${widget.userInfoId}');

      // 加载用户信息
      final userInfoData = await _storageService.getUserInfo(widget.userInfoId);
      print('获取到的用户信息数据: $userInfoData');

      if (userInfoData != null) {
        // 检查是否已经是UserInfo对象
        if (userInfoData is UserInfo) {
          _userInfo = userInfoData;
        } else if (userInfoData is Map<String, dynamic>) {
          _userInfo = UserInfo.fromJson(userInfoData);
        }
        print('用户信息解析成功: ${_userInfo!.id}, 年龄: ${_userInfo!.age}');
      }

      if (_userInfo == null) {
        throw Exception('用户信息不存在，userInfoId: ${widget.userInfoId}');
      }

      print('开始生成AI题目...');
      // 使用AI服务生成个性化测试题目
      await _generateQuestionsFromAI(_userInfo!);
      print('AI题目生成完成，题目数量: ${_questions.length}');

      // 创建测试会话
      _testSession = TestSession(
        id: const Uuid().v4(),
        userInfoId: widget.userInfoId,
        questions: _questions,
        answers: {},
        createdAt: DateTime.now(),
        status: TestStatus.inProgress,
        sessionType: '综合心理健康评估',
      );

      print('开始保存测试会话: ${_testSession!.id}');
      // 保存测试会话
      await _storageService.saveTestSession(_testSession!);
      print('测试会话保存成功');

      setState(() {
        _isLoading = false;
      });
      print('测试初始化完成');
    } catch (e, stackTrace) {
      print('初始化测试失败: $e');
      print('堆栈跟踪: $stackTrace');

      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('初始化测试失败：$e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  /// 使用AI服务生成个性化测试题目
  Future<void> _generateQuestionsFromAI(UserInfo userInfo) async {
    try {
      print('开始从AI生成题目，用户信息: ${userInfo.toJson()}');

      final stream = _aiService.generateQuestions(userInfo);
      String fullResponse = '';

      await for (final chunk in stream) {
        if (chunk.startsWith('error:')) {
          throw Exception(chunk.substring(6));
        }
        fullResponse = chunk; // 现在是完整响应，不需要累积
        print('接收到AI完整响应: $chunk');
        break; // 只有一个完整响应
      }

      print('完整AI响应: $fullResponse');

      // 解析AI生成的题目数据
      if (fullResponse.isNotEmpty) {
        _questions = _aiService.parseGeneratedQuestions(fullResponse);
        print('解析得到 ${_questions.length} 道题目');

        // 如果AI生成的题目数量不足，添加一些基础题目
        if (_questions.isEmpty) {
          print('解析结果为空，使用备用题目');
          _questions = _generateFallbackQuestions();
        }
      } else {
        print('AI响应为空，使用备用题目');
        throw Exception('AI服务未返回有效数据');
      }
    } catch (e, stackTrace) {
      print('AI生成题目失败: $e');
      print('堆栈跟踪: $stackTrace');

      // 如果AI生成失败，使用备用题目
      _questions = _generateFallbackQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI生成题目失败，使用默认题目'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// 生成备用测试题目（当AI服务不可用时使用）
  List<TestQuestion> _generateFallbackQuestions() {
    return [
      TestQuestion(
        id: const Uuid().v4(),
        questionText: '在过去的两周里，您感到情绪低落、沮丧或绝望的频率如何？',
        type: QuestionType.singleChoice,
        category: 'emotion',
        options: ['从不', '偶尔', '经常', '总是'],
        order: 1,
      ),
      TestQuestion(
        id: const Uuid().v4(),
        questionText: '您对日常活动的兴趣或乐趣如何？',
        type: QuestionType.singleChoice,
        category: 'emotion',
        options: ['很有兴趣', '有一些兴趣', '兴趣不大', '完全没有兴趣'],
        order: 2,
      ),
      TestQuestion(
        id: const Uuid().v4(),
        questionText: '您的睡眠质量如何？',
        type: QuestionType.singleChoice,
        category: 'sleep',
        options: ['很好', '一般', '较差', '很差'],
        order: 3,
      ),
      TestQuestion(
        id: const Uuid().v4(),
        questionText: '您感到紧张、焦虑或烦躁的频率如何？',
        type: QuestionType.singleChoice,
        category: 'stress',
        options: ['从不', '偶尔', '经常', '总是'],
        order: 4,
      ),
      TestQuestion(
        id: const Uuid().v4(),
        questionText: '您对自己的整体生活满意度如何？',
        type: QuestionType.scale,
        category: 'lifestyle',
        scaleMin: 1,
        scaleMax: 10,
        order: 5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafeAreaScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_testSession == null || _questions.isEmpty) {
      return SafeAreaScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              const Text(
                '加载测试失败',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请返回重试',
                style: TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeAreaScaffold(
      appBar: AppBar(
        title: Text(
          '心理健康测试 (${_currentQuestionIndex + 1}/${_questions.length})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF64748B),
          ),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          TextButton(
            onPressed: () => _showExitDialog(),
            child: const Text(
              '退出',
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '进度：${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                ),
              ],
            ),
          ),

          // 题目内容
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(_questions[index]);
              },
            ),
          ),

          // 导航按钮
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('上一题'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: _isSubmitting
                        ? '提交中...'
                        : (_currentQuestionIndex == _questions.length - 1
                            ? '提交测试'
                            : '下一题'),
                    onPressed: _isSubmitting
                        ? null
                        : (_currentQuestionIndex == _questions.length - 1
                            ? _submitTest
                            : _nextQuestion),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TestQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 题目类型标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: question.type.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                question.type.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: question.type.color,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 题目文本
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
            // 根据题目类型显示是否为必答题
            if (question.type != QuestionType.text)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '* 必答题',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // 答题区域
            _buildAnswerArea(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerArea(TestQuestion question) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceOptions(question);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question);
      case QuestionType.scale:
        return _buildScaleOptions(question);
      case QuestionType.text:
        return _buildTextInput(question);
    }
  }

  Widget _buildSingleChoiceOptions(TestQuestion question) {
    return Column(
      children: question.options!.map((option) {
        final isSelected = question.userAnswer == option;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectSingleOption(question, option),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4A90E2).withOpacity(0.1)
                    : const Color(0xFFF8FAFC),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A90E2)
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A90E2)
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF4A90E2)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF64748B),
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(TestQuestion question) {
    return Column(
      children: question.options!.map((option) {
        final selectedAnswers = question.userAnswer?.split(',') ?? [];
        final isSelected = selectedAnswers.contains(option);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _toggleMultipleOption(question, option),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4A90E2).withOpacity(0.1)
                    : const Color(0xFFF8FAFC),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A90E2)
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A90E2)
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF4A90E2)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF64748B),
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScaleOptions(TestQuestion question) {
    final currentValue = question.userAnswer != null
        ? int.tryParse(question.userAnswer!) ?? (question.scaleMin ?? 1)
        : (question.scaleMin ?? 1);
    final min = question.scaleMin ?? 1;
    final max = question.scaleMax ?? 10;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              currentValue.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A90E2),
              ),
            ),
            Text(
              max.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Slider(
          value: currentValue.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: const Color(0xFF4A90E2),
          inactiveColor: const Color(0xFFE2E8F0),
          onChanged: (value) => _updateScaleValue(question, value.round()),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            return Text(
              value.toString(),
              style: TextStyle(
                fontSize: 12,
                color: value == currentValue
                    ? const Color(0xFF4A90E2)
                    : const Color(0xFF9CA3AF),
                fontWeight:
                    value == currentValue ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTextInput(TestQuestion question) {
    return TextField(
      maxLines: 4,
      decoration: InputDecoration(
        hintText: '请输入您的回答...',
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4A90E2),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      onChanged: (value) => _updateTextAnswer(question, value),
    );
  }

  void _selectSingleOption(TestQuestion question, String option) {
    setState(() {
      final questionIndex = _questions.indexOf(question);
      _questions[questionIndex] = question.copyWith(userAnswer: option);
      _testSession = _testSession!.updateAnswer(question.id, option);
    });
  }

  void _toggleMultipleOption(TestQuestion question, String option) {
    setState(() {
      final currentAnswers = question.userAnswer?.split(',') ?? [];
      if (currentAnswers.contains(option)) {
        currentAnswers.remove(option);
      } else {
        currentAnswers.add(option);
      }

      final questionIndex = _questions.indexOf(question);
      _questions[questionIndex] = question.copyWith(
        userAnswer: currentAnswers.join(','),
      );
      _testSession =
          _testSession!.updateAnswer(question.id, currentAnswers.join(','));
    });
  }

  void _updateScaleValue(TestQuestion question, int value) {
    setState(() {
      final questionIndex = _questions.indexOf(question);
      _questions[questionIndex] =
          question.copyWith(userAnswer: value.toString());
      _testSession = _testSession!.updateAnswer(question.id, value.toString());
    });
  }

  void _updateTextAnswer(TestQuestion question, String value) {
    final questionIndex = _questions.indexOf(question);
    _questions[questionIndex] = question.copyWith(userAnswer: value);
    _testSession = _testSession!.updateAnswer(question.id, value);
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    final currentQuestion = _questions[_currentQuestionIndex];

    // 检查必答题是否已回答（文本题为可选，其他为必答）
    if (currentQuestion.type != QuestionType.text &&
        !currentQuestion.isAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请回答当前题目后再继续'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitTest() async {
    // 检查所有必答题是否已回答（文本题为可选，其他为必答）
    final unansweredRequired = _questions
        .where((q) => q.type != QuestionType.text && !q.isAnswered)
        .toList();

    if (unansweredRequired.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请完成所有必答题后再提交'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 完成测试会话
      final completedSession = _testSession!.complete();
      await _storageService.saveTestSession(completedSession);

      // 导航到结果页面
      if (mounted) {
        context.go('/test-results?sessionId=${completedSession.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交测试失败：$e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出测试吗？当前进度将会保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text(
              '退出',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
