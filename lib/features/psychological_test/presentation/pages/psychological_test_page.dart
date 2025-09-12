import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PsychologicalTestPage extends StatelessWidget {
  const PsychologicalTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF64748B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '心理健康测试',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 欢迎卡片
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '专业心理健康评估',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '基于AI技术的个性化心理健康测试，帮助您了解自身心理状态',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 功能介绍
              Container(
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
                      '测试特色',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      Icons.person_outline,
                      '个性化评估',
                      '根据您的基本信息生成专属测试题目',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.psychology_outlined,
                      'AI智能分析',
                      '运用先进AI技术提供专业心理分析',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.security,
                      '隐私保护',
                      '所有数据仅存储在本地，保护您的隐私',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.insights,
                      '专业建议',
                      '获得个性化的心理健康改善建议',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 开始测试按钮
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 导航到用户信息收集页面
                    context.go('/user-info-form');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '开始心理健康测试',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 功能按钮行
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () {
              //           context.go('/test-history');
              //         },
              //         icon: const Icon(
              //           Icons.history,
              //           size: 18,
              //         ),
              //         label: const Text('测试历史'),
              //         style: OutlinedButton.styleFrom(
              //           foregroundColor: const Color(0xFF4A90E2),
              //           side: const BorderSide(
              //             color: Color(0xFF4A90E2),
              //           ),
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () {
              //           context.go('/test-settings');
              //         },
              //         icon: const Icon(
              //           Icons.settings,
              //           size: 18,
              //         ),
              //         label: const Text('测试设置'),
              //         style: OutlinedButton.styleFrom(
              //           foregroundColor: const Color(0xFF4A90E2),
              //           side: const BorderSide(
              //             color: Color(0xFF4A90E2),
              //           ),
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 24),

              // 免责声明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '本测试仅供参考，不能替代专业心理咨询。如有严重心理问题，请及时寻求专业帮助。',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A90E2),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
