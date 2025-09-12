import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/chat_message.dart';
import '../../models/user_context.dart';
import '../../services/deepseek_service.dart';
import '../../../../core/utils/error_handler.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final DeepSeekService _deepSeekService = DeepSeekService();
  
  late AnimationController _typingAnimationController;
  StreamSubscription? _streamSubscription;
  bool _isStreaming = false;
  String _currentStreamingId = '';

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      content: '您好！我是AI智能助手，专门为您提供社保和养老金相关咨询服务。\n\n我可以帮助您：\n• 社保政策解读\n• 养老金计算\n• 缴费策略建议\n• 退休规划指导\n\n请问有什么可以帮助您的吗？',
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isStreaming) return;

    // 添加用户消息
    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isStreaming = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // 创建AI消息占位符
    _currentStreamingId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    final aiMessage = ChatMessage(
      id: _currentStreamingId,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    setState(() {
      _messages.add(aiMessage);
    });

    // 开始流式接收响应
    try {
      _streamSubscription?.cancel();
      _streamSubscription = _deepSeekService.sendMessage(messageText).listen(
        _handleStreamChunk,
        onError: (error, stackTrace) => _handleStreamError(error.toString()),
        onDone: _handleStreamComplete,
      );
    } catch (e) {
      _handleStreamError('发送消息失败: ${ErrorHandler.handleError(e, context: 'sendMessage')}');
    }
  }

  void _stopStreaming() {
    if (_isStreaming) {
      _streamSubscription?.cancel();
      
      // 更新当前流式消息状态
      final messageIndex = _messages.indexWhere((msg) => msg.id == _currentStreamingId);
      if (messageIndex != -1) {
        final currentMessage = _messages[messageIndex];
        final stoppedMessage = currentMessage.copyWith(
          content: currentMessage.content.isEmpty 
              ? '对话已被用户终止' 
              : '${currentMessage.content}\n\n[对话已终止]',
          isStreaming: false,
        );

        setState(() {
          _messages[messageIndex] = stoppedMessage;
          _isStreaming = false;
        });
      } else {
        setState(() {
          _isStreaming = false;
        });
      }
    }
  }

  void _handleStreamChunk(String chunk) {
    if (chunk.startsWith('error:')) {
      _handleStreamError(chunk.substring(6));
      return;
    }

    // 更新正在流式传输的AI消息
    final messageIndex = _messages.indexWhere((msg) => msg.id == _currentStreamingId);
    if (messageIndex != -1) {
      final currentMessage = _messages[messageIndex];
      final updatedMessage = currentMessage.copyWith(
        content: currentMessage.content + chunk,
      );

      setState(() {
        _messages[messageIndex] = updatedMessage;
      });

      _scrollToBottom();
    }
  }

  void _handleStreamError(String error) {
    final messageIndex = _messages.indexWhere((msg) => msg.id == _currentStreamingId);
    if (messageIndex != -1) {
      final errorMessage = _messages[messageIndex].copyWith(
        content: '抱歉，发生了错误：$error\n\n请稍后重试或检查网络连接。',
        isStreaming: false,
      );

      setState(() {
        _messages[messageIndex] = errorMessage;
        _isStreaming = false;
      });
    } else {
      // 如果没有找到对应消息，创建新的错误消息
      final errorMessage = ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        content: '抱歉，发生了错误：$error',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
        _isStreaming = false;
      });
    }
    _scrollToBottom();
  }

  void _handleStreamComplete() {
    final messageIndex = _messages.indexWhere((msg) => msg.id == _currentStreamingId);
    if (messageIndex != -1) {
      final completedMessage = _messages[messageIndex].copyWith(
        isStreaming: false,
      );

      setState(() {
        _messages[messageIndex] = completedMessage;
        _isStreaming = false;
      });
    } else {
      setState(() {
        _isStreaming = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF64748B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI智能助手',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Text(
              //   '社保养老金专家',
              //   style: TextStyle(
              //     color: Color(0xFF64748B),
              //     fontSize: 12,
              //     fontWeight: FontWeight.w400,
              //   ),
              // ),
            ],
          ),
        ],
      ),
      actions: [
        if (_isStreaming)
          IconButton(
            icon: const Icon(Icons.stop, color: Color(0xFFEF4444)),
            onPressed: _stopStreaming,
            tooltip: '停止回答',
          ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
          onPressed: () {},
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(isUser: false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                border: message.isUser
                    ? null
                    : Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : const Color(0xFF334155),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (message.isStreaming) ...[
                    const SizedBox(height: 8),
                    _buildStreamingIndicator(),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUser
              ? [const Color(0xFF64748B), const Color(0xFF475569)]
              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isUser ? const Color(0xFF64748B) : const Color(0xFF6366F1)).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildStreamingIndicator() {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_typingAnimationController.value - delay).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -4 * (1 - (animationValue * 2 - 1).abs())),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  hintText: '请输入您的社保或养老金问题...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isStreaming,
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (_isStreaming) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: _stopStreaming,
                tooltip: '停止回答',
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isStreaming
                    ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: _isStreaming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _isStreaming ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}