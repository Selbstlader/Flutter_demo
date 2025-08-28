class DeepSeekConfig {
  static const String baseURL = "https://api.deepseek.com";
  static const String apiKey = "sk-a8e4ee88516f40e6a2dc3776d3254846";
  static const bool dangerouslyAllowBrowser = true;
  
  // 模型配置
  static const String model = "deepseek-chat";
  static const bool stream = true;
  static const int maxTokens = 8192;
  static const double temperature = 0.6;
  
  // 重试配置
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}