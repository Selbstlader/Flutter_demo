import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/services/connectivity_service.dart';
import '../../../core/config/deepseek_config.dart';
import '../models/user_context.dart';
import '../../../core/utils/network_error_util.dart';
import '../../../core/utils/error_handler.dart';

class DeepSeekService {
  static const String _endpoint = '/chat/completions';
  
  // 默认空上下文，让AI主动询问用户信息
  final UserContext _defaultContext = const UserContext(
    socialSecurityType: '未提供',
    paymentYears: 0,
    pensionBalance: 0.0,
    age: 0,
    region: '未提供',
    monthlyIncome: 0.0,
    employmentStatus: '未提供',
  );

  Stream<String> sendMessage(String message, {UserContext? userContext}) async* {
    final context = userContext ?? _defaultContext;
    
    // 检查网络连接
    final isConnected = await ConnectivityService.isConnected;
    if (!isConnected) {
      yield 'error:网络连接不可用，请检查网络设置';
      return;
    }
    
    int retryCount = 0;
    
    while (retryCount < DeepSeekConfig.maxRetries) {
      try {
        yield* _makeRequest(message, context);
        return;
      } catch (e) {
        retryCount++;
        final errorMsg = ErrorHandler.handleError(e, context: 'DeepSeekService.sendMessage');
        
        if (retryCount >= DeepSeekConfig.maxRetries) {
          yield 'error:$errorMsg (已重试${DeepSeekConfig.maxRetries}次)';
          return;
        }
        
        yield 'error:$errorMsg，正在重试... ($retryCount/${DeepSeekConfig.maxRetries})';
        await Future.delayed(DeepSeekConfig.retryDelay);
      }
    }
  }



  Stream<String> _makeRequest(String message, UserContext context) async* {
    final url = Uri.parse('${DeepSeekConfig.baseURL}$_endpoint');
    
    final systemPrompt = '''你是一个专业的社保和养老金咨询助手。

当前用户信息状态：
${context.toContextString()}

工作原则：
1. 如果用户信息不完整（显示"未提供"或为0），请主动询问相关信息：
   - 社保类型（城镇职工/城乡居民/灵活就业）
   - 年龄和缴费年限
   - 所在地区（影响缴费基数和政策）
   - 月收入水平
   - 当前就业状态
   - 养老金账户余额（如需计算）

2. 根据用户提供的具体信息给出个性化建议
3. 回答要专业、准确，基于最新的社保政策
4. 如涉及具体数额计算，请说明计算依据和假设条件
5. 建议用户咨询当地社保部门获取最准确信息

请用温和、专业的语气与用户交流，循序渐进地收集必要信息。''';

    final requestBody = {
      'model': DeepSeekConfig.model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': message},
      ],
      'stream': DeepSeekConfig.stream,
      'max_tokens': DeepSeekConfig.maxTokens,
      'temperature': DeepSeekConfig.temperature,
    };

    http.Client? client;
    try {
      // 创建带有自定义配置的HTTP客户端
      client = http.Client();
      
      final request = http.Request('POST', url);
      
      // 设置请求头，增加安卓兼容性
      request.headers.addAll({
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${DeepSeekConfig.apiKey}',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'User-Agent': 'Flutter-App/1.0 (Android)',
        'Accept-Encoding': 'gzip, deflate',
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
          final errorMsg = errorData['error']?['message'] ?? errorData['message'] ?? '未知错误';
          throw HttpException('API错误 (${streamedResponse.statusCode}): $errorMsg');
        } catch (e) {
          throw HttpException('HTTP ${streamedResponse.statusCode}: $responseBody');
        }
      }

      // 处理流式响应
      await for (final chunk in streamedResponse.stream
          .timeout(const Duration(seconds: 60))
          .transform(utf8.decoder)) {
        
        final lines = chunk.split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            
            if (data == '[DONE]') {
              return;
            }
            
            try {
              final jsonData = json.decode(data);
              final choices = jsonData['choices'] as List?;
              
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'];
                final content = delta?['content'] as String?;
                
                if (content != null && content.isNotEmpty) {
                  yield content;
                }
              }
            } catch (e) {
              // 忽略JSON解析错误，继续处理下一行
              continue;
            }
          }
        }
      }
    } on TimeoutException catch (e) {
      throw Exception('请求超时: ${ErrorHandler.handleError(e, context: 'DeepSeekService.timeout')}');
    } catch (e) {
      // 使用统一的错误处理
      final errorMessage = ErrorHandler.handleError(e, context: 'DeepSeekService._makeRequest');
      throw Exception('DeepSeek API请求失败: $errorMessage');
    } finally {
      client?.close();
    }
  }
}