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
      final sessionData = await _storageService.getTestSession(widget.sessionId);
      if (sessionData != null) {
        _testSession = sessionData is TestSession 
            ? sessionData 
            : TestSession.fromJson(sessionData);
      }

      if (_testSession == null) {
        throw Exception('测试会话不存在');
      }

      // 加载用户信息
      final userInfoData = await _storageService.getUserInfo(_testSession!.userInfoId);
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
      final analysisStream = _aiService.generateAnalysis(_userInfo!, _testSession!);
      
      String fullResponse = '';
      await for (final chunk in analysisStream) {
        if (chunk.isNotEmpty) {
          fullResponse += chunk;
          try {
            // 尝试解析完整的JSON响应
            final jsonData = json.decode(fullResponse);
            final report = MentalHealthReport.fromJson(jsonData);
            setState(() {
              _aiAnalysis = report;
              _isGeneratingAI = false;
              _isLoading = false;
            });
            break;
          } catch (e) {
            // 继续等待完整的响应
            continue;
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
          color: _getRiskLevelColor(overallAssessment.riskLevel).withOpacity(0.2),
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
          Text(
            '总分: ${overallAssessment.totalScore}',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
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
          _buildDimensionItem('人际关系', dimensionalAnalysis.interpersonalRelationships),
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
          _buildInsightSection('背景分析', insights.backgroundAnalysis, Icons.analytics, const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          _buildInsightListSection('潜在风险', insights.potentialRisks, Icons.warning, const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          _buildInsightListSection('优势资源', insights.strengthsAndResources, Icons.trending_up, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildInsightSection(String title, String content, IconData icon, Color color) {
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

  Widget _buildInsightListSection(String title, List<String> items, IconData icon, Color color) {
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
        ...items.map((item) => Padding(
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
        )).toList(),
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
          _buildInsightListSection('改善建议', recommendations.improvementSuggestions, Icons.lightbulb, const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildInsightListSection('维护方法', recommendations.maintenanceMethods, Icons.favorite, const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildInsightSection('专业咨询', recommendations.professionalCounseling, Icons.support_agent, const Color(0xFF8B5CF6)),
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
          _buildInsightListSection('短期目标', actionPlan.shortTermGoals, Icons.flag, const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          _buildInsightListSection('中期目标', actionPlan.mediumTermGoals, Icons.timeline, const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          _buildInsightListSection('长期目标', actionPlan.longTermGoals, Icons.emoji_events, const Color(0xFF10B981)),
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
