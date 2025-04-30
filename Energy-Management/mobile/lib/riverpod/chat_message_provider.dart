import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:energymanagement/components/models/ChatMessage.dart';

final chatMessagesProvider = StateNotifierProvider.family<ChatMessageNotifier, List<ChatMessage>, String>((ref, roomId) {
  return ChatMessageNotifier(roomId: roomId);
});

class ChatMessageNotifier extends StateNotifier<List<ChatMessage>> {
  final String roomId;

  ChatMessageNotifier({required this.roomId}) : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}
