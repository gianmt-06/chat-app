import 'package:chat_app/entities/chat.dart';
import 'package:chat_app/utils/chat_utils.dart';
import 'package:chat_app/views/widgets/chat_list_widgets/chat_item_list_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    int? storedId = await getUserLoggedUID();
    if (storedId != null) {
      setState(() {
        _userId = storedId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: _userId)
              .orderBy('updatedAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('Obteniendo la lista de chats...'));
          default:
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final chats = snapshot.data!.docs;
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                itemCount: chats.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 5);
                },
                itemBuilder: (context, index) {
                  final doc = chats[index];
                  final chat = doc.data() as Map<String, dynamic>;
                  final chatId = doc.id;
                  return ChatItemListWidget(chat: Chat.fromJson(chatId, chat));
                },
              );
            }
        }
      },
    );
  }
}
