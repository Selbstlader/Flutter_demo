import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../models/chat_models.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  // 发送消息（流式响应）
  Stream<String> sendMessageStream(ChatMessageSendRequest request) {
    return _apiClient.postStream(
      '/admin-api/dify/chat/send-message-stream',
      request.toJson(),
    );
  }

  // 获取会话列表
  Future<ApiResponse<ConversationListResponse>> getConversations({
    String? lastId,
    int? limit,
  }) async {
    String endpoint = '/admin-api/dify/chat/conversations';
    final params = <String, String>{};
    
    if (lastId != null) params['lastId'] = lastId;
    if (limit != null) params['limit'] = limit.toString();
    
    if (params.isNotEmpty) {
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      endpoint += '?$query';
    }

    return await _apiClient.get<ConversationListResponse>(
      endpoint,
      fromJson: (json) => ConversationListResponse.fromJson(json),
    );
  }

  // 获取消息历史
  Future<ApiResponse<MessageHistoryResponse>> getMessageHistory({
    required String conversationId,
    String? firstId,
    int? limit,
  }) async {
    String endpoint = '/admin-api/dify/chat/messages';
    final params = <String, String>{'conversationId': conversationId};
    
    if (firstId != null) params['firstId'] = firstId;
    if (limit != null) params['limit'] = limit.toString();
    
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    endpoint += '?$query';

    return await _apiClient.get<MessageHistoryResponse>(
      endpoint,
      fromJson: (json) => MessageHistoryResponse.fromJson(json),
    );
  }

  // 获取建议问题
  Future<ApiResponse<SuggestedQuestionsResponse>> getSuggestedQuestions(
    String messageId,
  ) async {
    return await _apiClient.get<SuggestedQuestionsResponse>(
      '/admin-api/dify/chat/messages/$messageId/suggested',
      fromJson: (json) => SuggestedQuestionsResponse.fromJson(json),
    );
  }

  // 解析流式响应数据
  Map<String, dynamic>? parseStreamData(String chunk) {
    try {
      // 处理 Server-Sent Events 格式
      if (chunk.startsWith('data: ')) {
        final jsonStr = chunk.substring(6).trim();
        if (jsonStr.isEmpty || jsonStr == '[DONE]') {
          return null;
        }
        return jsonDecode(jsonStr);
      }
      return null;
    } catch (e) {
      print('解析流式数据失败: $e');
      return null;
    }
  }
}