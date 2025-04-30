import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  late IO.Socket socket;
  bool isConnected = false;

  SocketService._internal();

  void connect(String userId) {
    socket = IO.io('http://192.168.63.101:3001', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      isConnected = true;
      print('🔗 Socket connected');
      socket.emit('join', {'userId': userId});
    });

    socket.onDisconnect((_) {
      isConnected = false;
      print('❌ Socket disconnected');
    });
  }

  void sendPrivateMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    socket.emit('send_private_message', {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  void listenToMessages(Function(Map<String, dynamic>) onMessage) {
    socket.on('receive_private_message', (data) {
      onMessage(data);
    });
  }

  void sendTestMessage(String message) {
    socket.emit('test_message', {'msg': message});
  }

  void listenTestResponse() {
    socket.on('test_response', (data) {
      print('📩 Test response from server: $data');
    });
  }



  void dispose() {
    socket.dispose();
  }
}
