import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addInitialBotMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addInitialBotMessages() {
    // Add welcome messages from the bot
    _messages.add(
      ChatMessage(
        text: "Hello! I'm your support assistant. How can I help you today?",
        isFromUser: false,
        timestamp: DateTime.now(),
      ),
    );

    _messages.add(
      ChatMessage(
        text: "You can ask me about how to use the app, account issues, or any other questions you might have.",
        isFromUser: false,
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
      ),
    );

    // Scroll to bottom after messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: _messageController.text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate bot response after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final botResponse = _generateBotResponse(userMessage.text);

        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: botResponse,
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        });

        _scrollToBottom();
      }
    });
  }

  String _generateBotResponse(String userMessage) {
    // Simple rule-based responses for demo purposes
    final lowerCaseMessage = userMessage.toLowerCase();

    if (lowerCaseMessage.contains('hello') ||
        lowerCaseMessage.contains('hi') ||
        lowerCaseMessage.contains('hey')) {
      return "Hello! How can I assist you today?";
    } else if (lowerCaseMessage.contains('help') ||
        lowerCaseMessage.contains('support')) {
      return "I'm here to help! You can ask me about how to use the app, account issues, or any other questions you might have.";
    } else if (lowerCaseMessage.contains('account') ||
        lowerCaseMessage.contains('login') ||
        lowerCaseMessage.contains('sign in')) {
      return "For account issues, please make sure you're using the correct email and password. If you've forgotten your password, you can reset it from the login screen. Need more help with this?";
    } else if (lowerCaseMessage.contains('video call') ||
        lowerCaseMessage.contains('call')) {
      return "To start a video call, first open a chat with a contact, then tap the video camera icon in the top right corner of the chat screen.";
    } else if (lowerCaseMessage.contains('contact') ||
        lowerCaseMessage.contains('add friend') ||
        lowerCaseMessage.contains('new contact')) {
      return "To add a new contact, go to the Contacts tab, tap the + button in the top right, and enter their details or search by username/phone number.";
    } else if (lowerCaseMessage.contains('thank')) {
      return "You're welcome! Is there anything else I can help you with?";
    } else if (lowerCaseMessage.contains('bye') ||
        lowerCaseMessage.contains('goodbye')) {
      return "Goodbye! Feel free to chat with me anytime you need assistance.";
    } else {
      // Generate a more generic response for other queries
      final genericResponses = [
        "I understand you're asking about '${userMessage.split(' ').take(3).join(' ')}...'. Could you provide more details so I can better assist you?",
        "That's an interesting question. Let me help you with that. Could you elaborate a bit more?",
        "I'd be happy to help with that. Can you give me some more information?",
        "I'm not sure I fully understand your question. Could you rephrase it or provide more details?",
        "Let me see if I can help with that. What specifically about '${userMessage.split(' ').take(2).join(' ')}' do you need assistance with?",
      ];

      return genericResponses[math.Random().nextInt(genericResponses.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.support_agent,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Support Bot",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Online",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info about the bot
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About Support Bot"),
                  content: const Text(
                    "This is a simple support bot to help you with common questions about the app. "
                        "In a real app, this would be connected to a more sophisticated AI system.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          // Show typing indicator
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(),
            const SizedBox(width: 4),
            _buildDot(),
            const SizedBox(width: 4),
            _buildDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isFromUser
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: message.isFromUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isFromUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isFromUser ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                color: message.isFromUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black54,
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });
}

