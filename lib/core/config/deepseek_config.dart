import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekConfig {
  static const String baseURL = "https://api.deepseek.com";
  static String get apiKey => dotenv.env['DEEPSEEK_API_KEY'] ?? '';
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