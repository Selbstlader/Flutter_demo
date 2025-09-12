class PsychologicalAIConfig {
  static const String baseURL = "https://api.deepseek.com";
  static const String apiKey = "sk-a8e4ee88516f40e6a2dc3776d3254846";
  static const bool dangerouslyAllowBrowser = true;
  
  // 模型配置
  static const String model = "deepseek-chat";
  static const bool stream = false;
  static const int maxTokens = 8192;
  static const double temperature = 0.7; // 心理测试需要更多创造性
  
  // 重试配置
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // 心理测试专用配置
  static const int questionsPerSession = 20; // 每次测试题目数量
  static const int maxQuestionOptions = 5; // 最大选项数量
  static const Duration analysisTimeout = Duration(minutes: 2); // 分析超时时间
  
  // 题目生成配置
  static const Map<String, int> questionTypeDistribution = {
    'single_choice': 8,
    'multiple_choice': 4,
    'scale': 6,
    'text_input': 2,
  };
  
  // 风险等级阈值
  static const Map<String, double> riskThresholds = {
    'low': 0.3,
    'medium': 0.6,
    'high': 0.8,
  };
}