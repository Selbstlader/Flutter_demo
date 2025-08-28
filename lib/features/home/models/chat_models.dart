class ChatMessage {
  final String id;
  final String query;
  final String? answer;
  final String conversationId;
  final Map<String, dynamic>? inputs;
  final List<MessageFile>? messageFiles;
  final List<RetrieverResource>? retrieverResources;
  final int createdAt;
  final bool isUser;

  ChatMessage({
    required this.id,
    required this.query,
    this.answer,
    required this.conversationId,
    this.inputs,
    this.messageFiles,
    this.retrieverResources,
    required this.createdAt,
    required this.isUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      query: json['query'] ?? '',
      answer: json['answer'],
      conversationId: json['conversation_id'] ?? '',
      inputs: json['inputs'],
      messageFiles: json['message_files'] != null
          ? List<MessageFile>.from(
              (json['message_files'] as List).map((e) => MessageFile.fromJson(e as Map<String, dynamic>))
            )
          : null,
      retrieverResources: json['retriever_resources'] != null
          ? List<RetrieverResource>.from(
              (json['retriever_resources'] as List).map((e) => RetrieverResource.fromJson(e as Map<String, dynamic>))
            )
          : null,
      createdAt: json['created_at'] ?? 0,
      isUser: false,
    );
  }
}

class MessageFile {
  final String id;
  final String type;
  final String url;
  final String belongsTo;

  MessageFile({
    required this.id,
    required this.type,
    required this.url,
    required this.belongsTo,
  });

  factory MessageFile.fromJson(Map<String, dynamic> json) {
    return MessageFile(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      belongsTo: json['belongs_to'] ?? '',
    );
  }
}

class RetrieverResource {
  final int position;
  final double score;
  final String content;
  final String datasetId;
  final String datasetName;
  final String documentId;
  final String documentName;

  RetrieverResource({
    required this.position,
    required this.score,
    required this.content,
    required this.datasetId,
    required this.datasetName,
    required this.documentId,
    required this.documentName,
  });

  factory RetrieverResource.fromJson(Map<String, dynamic> json) {
    return RetrieverResource(
      position: json['position'] ?? 0,
      score: (json['score'] ?? 0.0).toDouble(),
      content: json['content'] ?? '',
      datasetId: json['dataset_id'] ?? '',
      datasetName: json['dataset_name'] ?? '',
      documentId: json['document_id'] ?? '',
      documentName: json['document_name'] ?? '',
    );
  }
}

class Conversation {
  final String id;
  final String name;
  final Map<String, dynamic>? inputs;
  final String status;
  final String? introduction;
  final int createdAt;
  final int updatedAt;

  Conversation({
    required this.id,
    required this.name,
    this.inputs,
    required this.status,
    this.introduction,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      inputs: json['inputs'],
      status: json['status'] ?? '',
      introduction: json['introduction'],
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
    );
  }
}

class ChatMessageSendRequest {
  final String query;
  final Map<String, dynamic>? inputs;
  final String? user;
  final List<FileInfo>? files;
  final String? originalText;
  final String responseMode;
  final String? conversationId;
  final bool autoGenerateName;

  ChatMessageSendRequest({
    required this.query,
    this.inputs,
    this.user,
    this.files,
    this.originalText,
    this.responseMode = 'streaming',
    this.conversationId,
    this.autoGenerateName = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'inputs': inputs ?? {},
      'user': user,
      'files': files?.map((e) => e.toJson()).toList(),
      'original_text': originalText ?? query,
      'response_mode': responseMode,
      'conversation_id': conversationId,
      'auto_generate_name': autoGenerateName,
    };
  }
}

class FileInfo {
  final String type;
  final String? url;
  final String transferMethod;
  final String? uploadFileId;

  FileInfo({
    required this.type,
    this.url,
    required this.transferMethod,
    this.uploadFileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'transfer_method': transferMethod,
      'upload_file_id': uploadFileId,
    };
  }
}

class MessageHistoryResponse {
  final int limit;
  final List<ChatMessage> data;
  final bool hasMore;

  MessageHistoryResponse({
    required this.limit,
    required this.data,
    required this.hasMore,
  });

  factory MessageHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MessageHistoryResponse(
      limit: json['limit'] ?? 0,
      data: json['data'] != null
          ? List<ChatMessage>.from(
              (json['data'] as List).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            )
          : <ChatMessage>[],
      hasMore: json['has_more'] ?? false,
    );
  }
}

class ConversationListResponse {
  final int limit;
  final List<Conversation> data;
  final bool hasMore;

  ConversationListResponse({
    required this.limit,
    required this.data,
    required this.hasMore,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    return ConversationListResponse(
      limit: json['limit'] ?? 0,
      data: json['data'] != null
          ? List<Conversation>.from(
              (json['data'] as List).map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            )
          : <Conversation>[],
      hasMore: json['has_more'] ?? false,
    );
  }
}

class SuggestedQuestionsResponse {
  final String result;
  final List<String> data;

  SuggestedQuestionsResponse({
    required this.result,
    required this.data,
  });

  factory SuggestedQuestionsResponse.fromJson(Map<String, dynamic> json) {
    return SuggestedQuestionsResponse(
      result: json['result'] ?? '',
      data: json['data'] != null
          ? List<String>.from(json['data'])
          : <String>[],
    );
  }
}