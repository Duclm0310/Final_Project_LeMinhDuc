// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'dart:math' as math;
//
// import '../models/ChatMessage.dart';
//
// class ChatVideoScreen extends StatefulWidget {
//   final String contactName;
//   final String contactAvatar;
//
//   const ChatVideoScreen({
//     super.key,
//     this.contactName = "Sarah Johnson",
//     this.contactAvatar = "https://randomuser.me/api/portraits/women/44.jpg",
//   });
//
//   @override
//   State<ChatVideoScreen> createState() => _ChatVideoScreenState();
// }
//
// class _ChatVideoScreenState extends State<ChatVideoScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<ChatMessage> _messages = [];
//   bool _isInVideoCall = false;
//   bool _isMuted = false;
//   bool _isCameraOff = false;
//   bool _isSpeakerOn = true;
//   late AnimationController _callAnimationController;
//   late Animation<double> _callAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialMessages();
//
//     _callAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//
//     _callAnimation = CurvedAnimation(
//       parent: _callAnimationController,
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _callAnimationController.dispose();
//     super.dispose();
//   }
//
//   void _loadInitialMessages() {
//     // Sample messages for demonstration
//     final sampleMessages = [
//       ChatMessage(
//         fromUID: "other",
//         toUID: "isMe", // boolean from isMe
//         message: "Hi there! How are you doing today?",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
//       ),
//       ChatMessage(
//         fromUID: "isMe",
//         toUID: "other", // boolean from isMe
//         message: "I'm doing great, thanks for asking! How about you?",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 55)),
//       ),
//       ChatMessage(
//         fromUID: "other",
//         toUID: "isMe", // boolean from isMe
//         message: "Pretty good! I was wondering if you'd like to discuss the project over a video call?",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 45)),
//       ),
//       ChatMessage(
//         fromUID: "isMe",
//         toUID: "other", // boolean from isMe
//         message: "That sounds like a great idea. When would be a good time for you?",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 30)),
//       ),
//       ChatMessage(
//         fromUID: "other",
//         toUID: "isMe", // boolean from isMe
//         message: "How about tomorrow at 2 PM?",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
//       ),
//       ChatMessage(
//         fromUID: "isMe",
//         toUID: "other", // boolean from isMe
//         message: "Perfect! I'll add it to my calendar.",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(days: 1, minutes: 55)),
//       ),
//       ChatMessage(
//         fromUID: "other",
//         toUID: "isMe", // boolean from isMe
//         message: "Great! I'll send you the meeting details shortly.",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(days: 1, minutes: 50)),
//       ),
//       ChatMessage(
//         fromUID: "isMe",
//         toUID: "other", // boolean from isMe
//         message: "Looking forward to our call!",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(minutes: 30)),
//       ),
//       ChatMessage(
//         fromUID: "other",
//         toUID: "isMe", // boolean from isMe
//         message: "Me too! Let's connect now if you're available.",
//         messageType: "text",
//         sendTime: DateTime.now().subtract(const Duration(minutes: 5)),
//       ),
//     ];
//
//     setState(() {
//       _messages.addAll(sampleMessages);
//     });
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToBottom();
//     });
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;
//
//     final newMessage = ChatMessage(
//       fromUID: "isMe",
//       toUID: "other", // boolean from isMe
//       message: _messageController.text.trim(),
//       messageType: "text",
//       sendTime: DateTime.now(),
//     );
//
//     setState(() {
//       _messages.add(newMessage);
//       _messageController.clear();
//     });
//
//     _scrollToBottom();
//
//     if (!_isInVideoCall && math.Random().nextDouble() > 0.3) {
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           final replyMessage = ChatMessage(
//             fromUID: "other",
//             toUID: "isMe", // boolean from isMe
//             message: _getRandomReply(),
//             messageType: "text",
//             sendTime: DateTime.now(),
//           );
//
//           setState(() {
//             _messages.add(replyMessage);
//           });
//
//           _scrollToBottom();
//         }
//       });
//     }
//   }
//
//   String _getRandomReply() {
//     final replies = [
//       "That's interesting!",
//       "I see what you mean.",
//       "Could you tell me more about that?",
//       "I agree with you.",
//       "Let's discuss this further on our call.",
//       "Good point!",
//       "I hadn't thought of it that way.",
//       "Thanks for sharing that.",
//       "I'll look into it.",
//       "Let's connect on video to discuss this in detail.",
//     ];
//
//     return replies[math.Random().nextInt(replies.length)];
//   }
//
//   void _toggleVideoCall() {
//     HapticFeedback.mediumImpact();
//     setState(() {
//       _isInVideoCall = !_isInVideoCall;
//     });
//
//     if (_isInVideoCall) {
//       _callAnimationController.forward();
//     } else {
//       _callAnimationController.reverse();
//
//       // Add a system message when call ends
//       final callEndedMessage = ChatMessage(
//         fromUID: "server",
//         toUID: "server", // boolean from isMe
//         message: "Video call ended • ${_formatDuration(const Duration(minutes: 5, seconds: 23))}",
//         messageType: "text",
//         sendTime: DateTime.now(),
//       );
//
//       setState(() {
//         _messages.add(callEndedMessage);
//       });
//
//       _scrollToBottom();
//     }
//   }
//
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$twoDigitMinutes:$twoDigitSeconds";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Stack(
//         children: [
//           // Chat UI
//           Column(
//             children: [
//               Expanded(
//                 child: _buildMessageList(),
//               ),
//               if (!_isInVideoCall) _buildMessageInput(),
//             ],
//           ),
//
//           // Video call overlay
//           AnimatedBuilder(
//             animation: _callAnimation,
//             builder: (context, child) {
//               return Positioned.fill(
//                 child: IgnorePointer(
//                   ignoring: !_isInVideoCall,
//                   child: Opacity(
//                     opacity: _callAnimation.value,
//                     child: _buildVideoCallUI(),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   AppBar _buildAppBar() {
//     return AppBar(
//       leadingWidth: 30,
//       title: Row(
//         children: [
//           CircleAvatar(
//             backgroundImage: NetworkImage(widget.contactAvatar),
//             radius: 20,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.contactName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   _isInVideoCall ? "On call" : "Online",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: _isInVideoCall
//                         ? Colors.red
//                         : Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: Icon(
//             _isInVideoCall ? Icons.call_end : Icons.videocam,
//             color: _isInVideoCall ? Colors.red : Theme.of(context).colorScheme.primary,
//           ),
//           onPressed: _toggleVideoCall,
//         ),
//         IconButton(
//           icon: const Icon(Icons.more_vert),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMessageList() {
//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       itemCount: _messages.length,
//       itemBuilder: (context, index) {
//         final message = _messages[index];
//         final showTimestamp = index == 0 ||
//             !_isSameDay(message.sendTime, _messages[index - 1].sendTime);
//
//         return Column(
//           children: [
//             if (showTimestamp) _buildDateSeparator(message.sendTime),
//             _buildMessageBubble(message),
//           ],
//         );
//       },
//     );
//   }
//
//   bool _isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }
//
//   Widget _buildDateSeparator(DateTime date) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       child: Row(
//         children: [
//           const Expanded(child: Divider()),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               _formatMessageDate(date),
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const Expanded(child: Divider()),
//         ],
//       ),
//     );
//   }
//
//   String _formatMessageDate(DateTime date) {
//     final now = DateTime.now();
//     if (date.year == now.year && date.month == now.month) {
//       if (date.day == now.day) {
//         return "Today";
//       } else if (date.day == now.day - 1) {
//         return "Yesterday";
//       }
//     }
//     return DateFormat.MMMd().format(date);
//   }
//
//   Widget _buildMessageBubble(ChatMessage message) {
//     if (message.fromUID == "server") {
//       return Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               message.message,
//               style: TextStyle(
//                 color: Colors.grey[800],
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Align(
//       alignment: message.fromUID == "isMe" ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         decoration: BoxDecoration(
//           color: message.fromUID == "isMe"
//               ? Theme.of(context).colorScheme.primary
//               : Colors.grey[200],
//           borderRadius: BorderRadius.circular(16).copyWith(
//             bottomRight: message.fromUID == "isMe" ? const Radius.circular(4) : null,
//             bottomLeft: !(message.fromUID == "isMe") ? const Radius.circular(4) : null,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 message.message,
//                 style: TextStyle(
//                   color: message.fromUID == "isMe" ? Colors.white : Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 DateFormat.jm().format(message.sendTime),
//                 style: TextStyle(
//                   color: message.fromUID == "isMe"
//                       ? Colors.white.withOpacity(0.7)
//                       : Colors.black54,
//                   fontSize: 10,
//                 ),
//                 textAlign: TextAlign.right,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.attach_file),
//               onPressed: () {},
//             ),
//             Expanded(
//               child: TextField(
//                 controller: _messageController,
//                 decoration: InputDecoration(
//                   hintText: "Type a message...",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                 ),
//                 textCapitalization: TextCapitalization.sentences,
//                 minLines: 1,
//                 maxLines: 5,
//               ),
//             ),
//             const SizedBox(width: 8),
//             CircleAvatar(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               child: IconButton(
//                 icon: const Icon(Icons.send, color: Colors.white),
//                 onPressed: _sendMessage,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVideoCallUI() {
//     return Container(
//       color: Colors.black,
//       child: Stack(
//         children: [
//           // Remote video (full screen)
//           Positioned.fill(
//             child: Image.network(
//               'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           // Local video (picture-in-picture)
//           Positioned(
//             top: 16,
//             right: 16,
//             child: Container(
//               width: 120,
//               height: 180,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white, width: 2),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: _isCameraOff
//                     ? Container(
//                   color: Colors.grey[800],
//                   child: const Center(
//                     child: Icon(
//                       Icons.videocam_off,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//                   ),
//                 )
//                     : Image.network(
//                   'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//
//           // Call duration
//           Positioned(
//             top: 16,
//             left: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Text(
//                 "05:23",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//
//           // Call controls
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Text(
//                   widget.contactName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black54,
//                         blurRadius: 10,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildCallControlButton(
//                       icon: _isMuted ? Icons.mic_off : Icons.mic,
//                       label: _isMuted ? "Unmute" : "Mute",
//                       onPressed: () {
//                         setState(() {
//                           _isMuted = !_isMuted;
//                         });
//                       },
//                     ),
//                     _buildCallControlButton(
//                       icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
//                       label: _isCameraOff ? "Camera On" : "Camera Off",
//                       onPressed: () {
//                         setState(() {
//                           _isCameraOff = !_isCameraOff;
//                         });
//                       },
//                     ),
//                     _buildCallControlButton(
//                       icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
//                       label: _isSpeakerOn ? "Speaker" : "Earpiece",
//                       onPressed: () {
//                         setState(() {
//                           _isSpeakerOn = !_isSpeakerOn;
//                         });
//                       },
//                     ),
//                     _buildCallControlButton(
//                       icon: Icons.call_end,
//                       label: "End",
//                       backgroundColor: Colors.red,
//                       onPressed: _toggleVideoCall,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Chat toggle button
//           Positioned(
//             bottom: 40,
//             right: 16,
//             child: FloatingActionButton(
//               mini: true,
//               backgroundColor: Colors.white,
//               child: const Icon(
//                 Icons.chat,
//                 color: Colors.black87,
//               ),
//               onPressed: () {
//                 _toggleVideoCall();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCallControlButton({
//     required IconData icon,
//     required String label,
//     Color? backgroundColor,
//     required VoidCallback onPressed,
//   }) {
//     return Column(
//       children: [
//         CircleAvatar(
//           radius: 28,
//           backgroundColor: backgroundColor ?? Colors.grey[800],
//           child: IconButton(
//             icon: Icon(icon, color: Colors.white, size: 28),
//             onPressed: onPressed,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//             shadows: [
//               Shadow(
//                 color: Colors.black54,
//                 blurRadius: 5,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:energymanagement/components/models/ChatUser.dart';
import 'package:energymanagement/components/models/ChatMessage.dart';
import 'package:energymanagement/components/Ultilities/socket_service.dart';
import 'package:energymanagement/riverpod/chat_message_provider.dart';

class ChatVideoScreen extends ConsumerStatefulWidget {
  final ChatUser peerUser;
  final String myUserId;

  const ChatVideoScreen({required this.peerUser, required this.myUserId, Key? key}) : super(key: key);

  @override
  ConsumerState<ChatVideoScreen> createState() => _ChatVideoScreenState();
}

class _ChatVideoScreenState extends ConsumerState<ChatVideoScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final String roomId;

  @override
  void initState() {
    super.initState();
    final users = [widget.myUserId, widget.peerUser.userData.userId!];
    users.sort(); // sort theo bảng chữ cái
    roomId = users.join('_');


    // Lắng nghe tin nhắn từ socket
    SocketService().listenToMessages((data) {
      final msg = ChatMessage.fromJson(data, widget.myUserId);
      ref.read(chatMessagesProvider(roomId).notifier).addMessage(msg);
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Gửi socket
    SocketService().listenToMessages((data) {
      final msg = ChatMessage.fromJson(data, widget.myUserId);
      ref.read(chatMessagesProvider(roomId).notifier).addMessage(msg);
    });

    // Cập nhật local
    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Tạm thời, khi backend trả về mới sync
      senderId: widget.myUserId,
      receiverId: widget.peerUser.userData.userId,
      groupId: null,
      content: content,
      timestamp: DateTime.now(),
      isMe: true,
    );
    ref.read(chatMessagesProvider(roomId).notifier).addMessage(newMsg);

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUser.userData.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg.isMe ? Theme.of(context).colorScheme.primary.withOpacity(0.8) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: msg.isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
