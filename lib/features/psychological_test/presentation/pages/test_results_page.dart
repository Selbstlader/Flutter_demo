import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

import '../../models/test_question.dart';
import '../../models/test_session.dart';
import '../../models/user_info.dart';
import '../../models/mental_health_report.dart';
import '../../services/psychological_ai_service.dart';
import '../../../../core/services/storage_service.dart';

class TestResultsPage extends StatefulWidget {
  final String sessionId;

  const TestResultsPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<TestResultsPage> createState() => _TestResultsPageState();
}

class _TestResultsPageState extends State<TestResultsPage> {
  bool _isLoading = true;
  bool _isGeneratingAI = false;
  MentalHealthReport? _aiAnalysis;
  String? _error;
  final PsychologicalAIService _aiService = PsychologicalAIService();
  final StorageService _storageService = StorageService.instance;
  TestSession? _testSession;
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 加载测试会话数据
      final sessionData =
          await _storageService.getTestSession(widget.sessionId);
      if (sessionData != null) {
        _testSession = sessionData is TestSession
            ? sessionData
            : TestSession.fromJson(sessionData);
      }

      if (_testSession == null) {
        throw Exception('测试会话不存在');
      }

      // 加载用户信息
      final userInfoData =
          await _storageService.getUserInfo(_testSession!.userInfoId);
      if (userInfoData != null) {
        _userInfo = userInfoData is UserInfo
            ? userInfoData
            : UserInfo.fromJson(userInfoData);
      }

      if (_userInfo == null) {
        throw Exception('用户信息不存在');
      }

      // 开始生成AI分析
      await _generateAIAnalysis();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAIAnalysis() async {
    if (_userInfo == null || _testSession == null) {
      setState(() {
        _error = '缺少必要的数据';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isGeneratingAI = true;
      _error = null;
    });

    try {
      final analysisStream =
          _aiService.generateAnalysis(_userInfo!, _testSession!);

      String fullResponse = '';
      await for (final chunk in analysisStream) {
        if (chunk.isNotEmpty) {
          fullResponse += chunk;
          try {
            // 解析API响应获取完整的JSON结构
            final apiResponse = json.decode(fullResponse);
            LoggerUtil.d('分析API响应: ${apiResponse.toString().length > 100 ? apiResponse.toString().substring(0, 100) + "..." : apiResponse.toString()}');

            Map<String, dynamic>? reportData;

            // 检查是否是直接的report结构
            if (apiResponse is Map<String, dynamic>) {
              if (apiResponse.containsKey('report')) {
                // 如果包含report字段，提取report数据
                reportData = apiResponse['report'] as Map<String, dynamic>;
              } else if (apiResponse.containsKey('overallAssessment') ||
                  apiResponse.containsKey('dimensionalAnalysis') ||
                  apiResponse.containsKey('personalizedInsights')) {
                // 如果直接包含报告字段，说明这就是report数据
                reportData = apiResponse;
              } else {
                // 尝试解析choices格式（兼容原有格式）
                if (apiResponse.containsKey('choices') &&
                    apiResponse['choices'] is List &&
                    (apiResponse['choices'] as List).isNotEmpty) {
                  final firstChoice = (apiResponse['choices'] as List)[0];
                  if (firstChoice is Map<String, dynamic> &&
                      firstChoice.containsKey('message') &&
                      firstChoice['message'] is Map<String, dynamic> &&
                      firstChoice['message']['content'] is String) {
                    final contentString =
                        firstChoice['message']['content'] as String;
                    final contentData = json.decode(contentString);

                    if (contentData is Map<String, dynamic> &&
                        contentData.containsKey('report')) {
                      reportData =
                          contentData['report'] as Map<String, dynamic>;
                    }
                  }
                }
              }
            }

            if (reportData != null) {
              // 修复字段映射和数据转换问题
              final transformedData = _transformApiDataToModel(reportData);
              final report = MentalHealthReport.fromJson(transformedData);

              setState(() {
                _aiAnalysis = report;
                _isGeneratingAI = false;
                _isLoading = false;
              });
              break;
            } else {
              throw Exception('响应数据格式不正确，无法解析报告数据');
            }
          } catch (e) {
            // 如果是JSON解析错误，继续等待完整的响应
            if (e is FormatException) {
              continue;
            } else {
              // 其他错误直接抛出
              rethrow;
            }
          }
        }
      }

      // 如果流结束但没有成功解析，抛出异常
      if (_aiAnalysis == null) {
        throw Exception('AI服务未返回有效数据');
      }
    } catch (e) {
      setState(() {
        _error = '生成AI分析失败: $e';
        _isGeneratingAI = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryAnalysis() async {
    await _loadSessionData();
  }

  /// 将API返回的数据转换为MentalHealthReport模型所需的格式
  Map<String, dynamic> _transformApiDataToModel(Map<String, dynamic> apiData) {
    try {
      // 处理字符串分割为数组的辅助函数
      List<String> _splitStringToList(String? text) {
        if (text == null || text.isEmpty) return [];
        // 按句号、分号或数字序号分割
        final parts = text
            .split(RegExp(r'[.;]|\d+\.\s*'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        return parts.isEmpty ? [text] : parts;
      }

      // 安全获取嵌套Map的辅助函数
      Map<String, dynamic> _safeGetMap(Map<String, dynamic>? data, String key) {
        if (data == null) return <String, dynamic>{};
        final value = data[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
        return <String, dynamic>{};
      }

      // 生成基本信息（从用户信息推导或使用默认值）
      final basicInfo = {
        'age': _userInfo?.age ?? 0,
        'gender': _userInfo?.gender ?? '未知',
        'educationLevel': _userInfo?.education ?? '未知',
        'maritalStatus': _userInfo?.maritalStatus ?? '未知',
        'livingSituation': _userInfo?.livingCondition ?? '未知',
        'occupation': _userInfo?.occupation ?? '未知',
        'assessmentDate': DateTime.now().toIso8601String().split('T')[0],
      };

      // 修复overallAssessment字段映射，处理中英文字段名
      final overallAssessment = _safeGetMap(apiData, 'overallAssessment');
      final overallAssessmentCN = _safeGetMap(apiData, '总体评估');
      final fixedOverallAssessment = {
        'totalScore': overallAssessment['mentalHealthScore'] ??
            overallAssessmentCN['心理健康总体状况评分'] ??
            0,
        'riskLevel': overallAssessment['riskLevel'] ??
            overallAssessmentCN['风险等级评估'] ??
            '未知',
        'mainCharacteristics': overallAssessment['summary'] ??
            overallAssessmentCN['主要心理特征概述'] ??
            '暂无评估',
      };

      // 修复professionalRecommendations字段映射，处理中英文字段名
      final recommendations =
          _safeGetMap(apiData, 'professionalRecommendations');
      final recommendationsCN = _safeGetMap(apiData, '专业建议');
      final fixedRecommendations = {
        'improvementSuggestions': () {
          final suggestions =
              recommendations['suggestions'] ?? recommendationsCN['具体的改善建议'];
          return suggestions is List
              ? List<String>.from(suggestions)
              : <String>[];
        }(),
        'maintenanceMethods': () {
          final methods = recommendations['maintenanceMethods'] ??
              recommendationsCN['推荐的心理健康维护方法'];
          return methods is List ? List<String>.from(methods) : <String>[];
        }(),
        'professionalCounseling': recommendations['counselingAdvice'] ??
            recommendationsCN['是否需要专业心理咨询建议'] ??
            '暂无建议',
      };

      // 修复personalizedInsights字段，处理中英文字段名
      final insights = _safeGetMap(apiData, 'personalizedInsights');
      final insightsCN = _safeGetMap(apiData, '个性化洞察');
      final fixedInsights = {
        'backgroundAnalysis': insights['backgroundAnalysis'] ??
            insightsCN['基于用户背景的个性化分析'] ??
            '暂无分析',
        'potentialRisks': () {
          final risks = insights['riskPoints'] ?? insightsCN['潜在的心理健康风险点'];
          return risks is List ? List<String>.from(risks) : <String>[];
        }(),
        'strengthsAndResources': () {
          final strengths = insights['strengths'] ?? insightsCN['个人优势和资源识别'];
          return strengths is List ? List<String>.from(strengths) : <String>[];
        }(),
      };

      // 修复actionPlan字段，处理中英文字段名
      final actionPlan = _safeGetMap(apiData, 'actionPlan');
      final actionPlanCN = _safeGetMap(apiData, '行动计划');
      final fixedActionPlan = {
        'shortTermGoals': () {
          final goals =
              actionPlan['shortTermGoals'] ?? actionPlanCN['短期目标（1-2周）'];
          return goals is List ? List<String>.from(goals) : <String>[];
        }(),
        'mediumTermGoals': () {
          final goals =
              actionPlan['midTermGoals'] ?? actionPlanCN['中期目标（1-3个月）'];
          return goals is List ? List<String>.from(goals) : <String>[];
        }(),
        'longTermGoals': () {
          final goals =
              actionPlan['longTermGoals'] ?? actionPlanCN['长期目标（3-6个月）'];
          return goals is List ? List<String>.from(goals) : <String>[];
        }(),
      };

      return {
        'basicInformation': basicInfo,
        'overallAssessment': fixedOverallAssessment,
        'dimensionalAnalysis':
            _safeGetMap(apiData, 'dimensionalAnalysis').isNotEmpty
                ? apiData['dimensionalAnalysis']
                : apiData['各维度分析'], // 处理中英文字段名
        'personalizedInsights': fixedInsights,
        'professionalRecommendations': fixedRecommendations,
        'actionPlan': fixedActionPlan,
        'additionalNotes': null,
      };
    } catch (e) {
      // 如果数据转换失败，返回一个基本的默认结构
      LoggerUtil.e('数据转换错误: $e');
      return {
        'basicInformation': {
          'testDate': DateTime.now().toIso8601String(),
          'testType': '心理健康评估',
          'participantId': 'unknown',
        },
        'overallAssessment': {
          'totalScore': 0,
          'level': '未知',
          'mainCharacteristics': ['数据解析失败'],
        },
        'dimensionalAnalysis': {
          'dimensions': [],
        },
        'personalizedInsights': {
          'strengths': ['数据解析失败'],
          'improvementAreas': ['请重新尝试'],
          'personalityTraits': ['未知'],
        },
        'professionalRecommendations': {
          'professionalCounseling': ['建议联系专业人士'],
          'selfHelpStrategies': ['请重新进行测试'],
        },
        'actionPlan': {
          'shortTermGoals': ['重新进行测试'],
          'longTermGoals': ['寻求专业帮助'],
          'dailyPractices': ['保持积极心态'],
          'resources': ['专业心理咨询'],
        },
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI智能分析报告',
          style: TextStyle(
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF64748B),
            ),
            onPressed: _retryAnalysis,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading || _isGeneratingAI) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '正在生成AI分析报告...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retryAnalysis,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_aiAnalysis == null) {
      return const Center(
        child: Text(
          '暂无分析结果',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallResultCard(),
          const SizedBox(height: 20),
          _buildDimensionalAnalysis(),
          const SizedBox(height: 20),
          _buildPersonalizedInsights(),
          const SizedBox(height: 20),
          _buildRecommendations(),
          const SizedBox(height: 20),
          _buildActionPlan(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOverallResultCard() {
    final overallAssessment = _aiAnalysis!.overallAssessment;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getRiskLevelColor(overallAssessment.riskLevel).withOpacity(0.1),
            _getRiskLevelColor(overallAssessment.riskLevel).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _getRiskLevelColor(overallAssessment.riskLevel).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getRiskLevelIcon(overallAssessment.riskLevel),
            size: 48,
            color: _getRiskLevelColor(overallAssessment.riskLevel),
          ),
          const SizedBox(height: 16),
          const Text(
            '总体评估',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            overallAssessment.riskLevel,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _getRiskLevelColor(overallAssessment.riskLevel),
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   '总分: ${overallAssessment.totalScore}',
          //   style: const TextStyle(
          //     fontSize: 18,
          //     color: Color(0xFF374151),
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          const SizedBox(height: 12),
          Text(
            overallAssessment.mainCharacteristics,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionalAnalysis() {
    final dimensionalAnalysis = _aiAnalysis!.dimensionalAnalysis;

    return Container(
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
          const Text(
            '各维度分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildDimensionItem('情绪状态', dimensionalAnalysis.emotionalState),
          const SizedBox(height: 16),
          _buildDimensionItem('压力水平', dimensionalAnalysis.stressLevel),
          const SizedBox(height: 16),
          _buildDimensionItem(
              '人际关系', dimensionalAnalysis.interpersonalRelationships),
          const SizedBox(height: 16),
          _buildDimensionItem('自我认知', dimensionalAnalysis.selfAwareness),
          const SizedBox(height: 16),
          _buildDimensionItem('应对策略', dimensionalAnalysis.copingStrategies),
        ],
      ),
    );
  }

  Widget _buildDimensionItem(String title, DimensionScore dimension) {
    final progress = dimension.score / 100.0;
    final color = _getScoreColor(dimension.score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '${dimension.score}/100',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 8),
        Text(
          dimension.analysis,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedInsights() {
    final insights = _aiAnalysis!.personalizedInsights;

    return Container(
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
          const Text(
            '个性化洞察',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightSection('背景分析', insights.backgroundAnalysis,
              Icons.analytics, const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          _buildInsightListSection('潜在风险', insights.potentialRisks,
              Icons.warning, const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          _buildInsightListSection('优势资源', insights.strengthsAndResources,
              Icons.trending_up, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildInsightSection(
      String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightListSection(
      String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _aiAnalysis!.professionalRecommendations;

    return Container(
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
          const Text(
            '专业建议',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightListSection(
              '改善建议',
              recommendations.improvementSuggestions,
              Icons.lightbulb,
              const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildInsightListSection('维护方法', recommendations.maintenanceMethods,
              Icons.favorite, const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildInsightSection('专业咨询', recommendations.professionalCounseling,
              Icons.support_agent, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildActionPlan() {
    final actionPlan = _aiAnalysis!.actionPlan;

    return Container(
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
          const Text(
            '行动计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightListSection('短期目标', actionPlan.shortTermGoals,
              Icons.flag, const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          _buildInsightListSection('中期目标', actionPlan.mediumTermGoals,
              Icons.timeline, const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          _buildInsightListSection('长期目标', actionPlan.longTermGoals,
              Icons.emoji_events, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('返回测试'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _retryAnalysis,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('重新分析'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _seekProfessionalHelp,
            icon: const Icon(Icons.support_agent),
            label: const Text('寻求专业帮助'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case '低风险':
      case 'low':
        return const Color(0xFF10B981);
      case '中等风险':
      case 'medium':
        return const Color(0xFFF59E0B);
      case '高风险':
      case 'high':
        return const Color(0xFFEF4444);
      case '极高风险':
      case 'critical':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getRiskLevelIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case '低风险':
      case 'low':
        return Icons.sentiment_very_satisfied;
      case '中等风险':
      case 'medium':
        return Icons.sentiment_neutral;
      case '高风险':
      case 'high':
        return Icons.sentiment_dissatisfied;
      case '极高风险':
      case 'critical':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF84CC16);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  void _seekProfessionalHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('寻求专业帮助'),
        content: const Text(
          '如果您感到困扰或需要专业支持，建议您：\n\n'
          '• 联系当地心理健康服务机构\n'
          '• 咨询专业心理咨询师\n'
          '• 拨打心理健康热线\n'
          '• 寻求医生建议\n\n'
          '记住，寻求帮助是勇敢和明智的选择。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }
}
