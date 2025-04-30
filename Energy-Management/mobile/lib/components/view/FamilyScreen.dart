import 'package:energymanagement/components/view/ChatBot.dart';
import 'package:energymanagement/components/view/ChatVideoScreen.dart';
import 'package:energymanagement/riverpod/auth_data_provider.dart';
import 'package:flutter/material.dart';

// //TODO: Create chat page state and view model
// //TODO: handle search for people in state!
// //TODO: add button that dropdown and add people through email or QR
// //TODO: remove un-use attribute: isOnline, lastMessage, ....
//
// class FamilyScreen extends StatefulWidget {
//   const FamilyScreen({super.key});
//
//   @override
//   State<FamilyScreen> createState() => _ContactSelectionScreenState();
// }
//
// class _ContactSelectionScreenState extends State<FamilyScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final List<Contact> _allContacts = Contact.sampleContacts;
//   late List<Contact> _filteredContacts;
//   late TabController _tabController;
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _filteredContacts = List.from(_allContacts);
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   void _filterContacts(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredContacts = List.from(_allContacts);
//       } else {
//         _filteredContacts = _allContacts
//             .where((contact) =>
//             contact.name.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }
//
//   void _navigateToChat(Contact contact) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatVideoScreen(
//           contactName: contact.name,
//           contactAvatar: contact.avatarUrl,
//         ),
//       ),
//     );
//   }
//
//   void _navigateToBotChat() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ChatBotScreen(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Contacts",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(onPressed: (){
//             //TODO: handle search for people using QR
//             //TODO: check for QR scanning logic
//           }, icon: const Icon(Icons.settings)),
//           IconButton(onPressed: (){
//             Navigator.pushNamed(context, "qr-scan");
//           }, icon: const Icon(Icons.qr_code_scanner))
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(100),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: "Search contacts...",
//                     prefixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                   onChanged: _filterContacts,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: _buildContactList(_filteredContacts),
//     );
//   }
//
//   Widget _buildContactList(List<Contact> contacts) {
//     // Show support bot only if search is empty
//     final showSupportBot = _searchQuery.isEmpty;
//
//     if (!showSupportBot && contacts.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "No contacts found",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.only(bottom: 16),
//       itemCount: showSupportBot ? contacts.length + 1 : contacts.length,
//       itemBuilder: (context, index) {
//         // Support bot is always the first item
//         if (showSupportBot && index == 0) {
//           return _buildSupportBotTile();
//         }
//
//         // Adjust index to account for the support bot
//         final contactIndex = showSupportBot ? index - 1 : index;
//         final contact = contacts[contactIndex];
//         return _buildContactTile(contact);
//       },
//     );
//   }
//
//   Widget _buildSupportBotTile() {
//     return Container(
//       margin: const EdgeInsets.only(top: 8, bottom: 8),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: CircleAvatar(
//           radius: 28,
//           backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//           child: Icon(
//             Icons.support_agent,
//             size: 32,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//         ),
//         title: const Text(
//           "Support Bot",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: const Padding(
//           padding: EdgeInsets.only(top: 4),
//           child: Text(
//             "Get help anytime you need",
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: 14,
//             ),
//           ),
//         ),
//         trailing: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Text(
//             "24/7",
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.primary,
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//         ),
//         onTap: _navigateToBotChat,
//       ),
//     );
//   }
//
//   Widget _buildContactTile(Contact contact) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       leading: Stack(
//         children: [
//           CircleAvatar(
//             radius: 28,
//             backgroundImage: NetworkImage(contact.avatarUrl),
//           ),
//           if (contact.isOnline)
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 width: 14,
//                 height: 14,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Theme.of(context).scaffoldBackgroundColor,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       title: Text(
//         contact.name,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//       subtitle: contact.lastMessage != null
//           ? Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Text(
//           contact.lastMessage!,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 14,
//           ),
//         ),
//       )
//           : null,
//       trailing: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (contact.lastMessageTime != null)
//             Text(
//               _formatLastMessageTime(contact.lastMessageTime!),
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//             ),
//           const SizedBox(height: 4),
//           if (contact.unreadCount > 0)
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary,
//                 shape: BoxShape.circle,
//               ),
//               child: Text(
//                 contact.unreadCount.toString(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       onTap: () => _navigateToChat(contact),
//     );
//   }
//
//   String _formatLastMessageTime(DateTime time) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate = DateTime(time.year, time.month, time.day);
//
//     if (messageDate == today) {
//       return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
//     } else if (messageDate == yesterday) {
//       return "Yesterday";
//     } else {
//       return "${time.day}/${time.month}/${time.year}";
//     }
//   }
// }
//
//
// class Contact {
//   final String name;
//   final String avatarUrl;
//   final bool isOnline;
//   final String? lastMessage;
//   final DateTime? lastMessageTime;
//   final int unreadCount;
//   final bool isFavorite;
//
//   Contact({
//     required this.name,
//     required this.avatarUrl,
//     this.isOnline = false,
//     this.lastMessage,
//     this.lastMessageTime,
//     this.unreadCount = 0,
//     this.isFavorite = false,
//   });
//
//   static List<Contact> sampleContacts = [
//     Contact(
//       name: "Sarah Johnson",
//       avatarUrl: "https://randomuser.me/api/portraits/women/44.jpg",
//       isOnline: true,
//       lastMessage: "Looking forward to our call!",
//       lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
//       unreadCount: 2,
//       isFavorite: true,
//     ),
//     Contact(
//       name: "Michael Chen",
//       avatarUrl: "https://randomuser.me/api/portraits/men/32.jpg",
//       isOnline: true,
//       lastMessage: "Can we discuss the project tomorrow?",
//       lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
//       unreadCount: 0,
//       isFavorite: true,
//     ),
//     Contact(
//       name: "Emma Wilson",
//       avatarUrl: "https://randomuser.me/api/portraits/women/22.jpg",
//       isOnline: false,
//       lastMessage: "Thanks for the update!",
//       lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
//       unreadCount: 0,
//       isFavorite: false,
//     ),
//     Contact(
//       name: "James Rodriguez",
//       avatarUrl: "https://randomuser.me/api/portraits/men/67.jpg",
//       isOnline: false,
//       lastMessage: "Let's catch up soon",
//       lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
//       unreadCount: 0,
//       isFavorite: true,
//     ),
//     Contact(
//       name: "Olivia Parker",
//       avatarUrl: "https://randomuser.me/api/portraits/women/17.jpg",
//       isOnline: true,
//       lastMessage: null,
//       lastMessageTime: null,
//       unreadCount: 0,
//       isFavorite: false,
//     ),
//     Contact(
//       name: "Daniel Kim",
//       avatarUrl: "https://randomuser.me/api/portraits/men/51.jpg",
//       isOnline: false,
//       lastMessage: "The meeting went well",
//       lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
//       unreadCount: 0,
//       isFavorite: false,
//     ),
//     Contact(
//       name: "Sophia Martinez",
//       avatarUrl: "https://randomuser.me/api/portraits/women/90.jpg",
//       isOnline: false,
//       lastMessage: null,
//       lastMessageTime: null,
//       unreadCount: 0,
//       isFavorite: false,
//     ),
//     Contact(
//       name: "Ethan Thompson",
//       avatarUrl: "https://randomuser.me/api/portraits/men/41.jpg",
//       isOnline: true,
//       lastMessage: "I'll send you the files",
//       lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
//       unreadCount: 0,
//       isFavorite: false,
//     ),
//     Contact(
//       name: "Ava Williams",
//       avatarUrl: "https://randomuser.me/api/portraits/women/63.jpg",
//       isOnline: false,
//       lastMessage: "See you at the conference",
//       lastMessageTime: DateTime.now().subtract(const Duration(days: 4)),
//       unreadCount: 0,
//       isFavorite: true,
//     ),
//     Contact(
//       name: "Noah Garcia",
//       avatarUrl: "https://randomuser.me/api/portraits/men/29.jpg",
//       isOnline: false,
//       lastMessage: null,
//       lastMessageTime: null,
//       unreadCount: 0,
//       isFavorite: false,
//     ),
//   ];
// }
//
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:energymanagement/components/models/ChatUser.dart';
import 'package:energymanagement/riverpod/chat_provider.dart';
import 'package:energymanagement/components/Ultilities/socket_service.dart';


class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToChat(ChatUser chatUser, String myUserId) {
    final socketService = SocketService();

    if (!socketService.isConnected) {
      socketService.connect(myUserId); // 🛠 Kết nối trước
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatVideoScreen(
          peerUser: chatUser,
          myUserId: myUserId,
        ),
      ),
    );
  }


  void _navigateToBotChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatBotScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatUsersAsync = ref.watch(chatUsersProvider);
    // final myUser = ref.watch(authProvider);
    final socketService = SocketService();
    socketService.sendTestMessage("Hello from Flutter!");
    socketService.listenTestResponse();


    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          IconButton(onPressed: () {
            Navigator.pushNamed(context, "qr-scan");
          }, icon: const Icon(Icons.qr_code_scanner))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: chatUsersAsync.when(
        data: (chatUsers) {
          final filtered = chatUsers.where((user) =>
              user.userData.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          return ListView.builder(
            itemCount: filtered.length + 1, // thêm 1 cho Support Bot
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildSupportBotTile();
              }
              final user = filtered[index - 1];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.userData.avatar),
                ),
                title: Text(user.userData.name),
                subtitle: user.lastMessage != null ? Text(
                  user.lastMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ) : null,
                trailing: user.unreadCount > 0
                    ? CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${user.unreadCount}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                )
                    : null,
                onTap: () {
                  final myUser = ref.read(authProvider);
                  if (myUser?.userId != null) {
                    _navigateToChat(user, myUser!.userId!);
                  } else {
                    // fallback: show error/toast
                  }
                },

              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading contacts')),
      ),
    );
  }

  Widget _buildSupportBotTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.2),
        child: const Icon(Icons.support_agent, color: Colors.blue),
      ),
      title: const Text("Support Bot"),
      subtitle: const Text("Get help anytime you need"),
      trailing: const Text("24/7"),
      onTap: _navigateToBotChat,
    );
  }
}
