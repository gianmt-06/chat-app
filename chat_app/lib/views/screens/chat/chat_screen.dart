import 'dart:async';
import 'dart:convert';

import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/entities/chat.dart';
import 'package:chat_app/entities/message.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/firestore_chats.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/utils/chat_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreDatabase _database = FirestoreDatabase();
  final ChatModel _chatModel = ChatModel();
  Color _color = Colors.amber;
  List<ChatMessage> messages = [];
  final List<ChatUser> _typingUsers = [];

  ChatUser _user = ChatUser(id: '-1');
  int _userId = -1;
  String _chatName = "";
  String _chatImgPath = "";

  @override
  void initState() {
    super.initState();
    manageSocketConnection();
    _loadUserId();
    if (widget.chat.id != '') {
      _chatModel.readMessage(widget.chat.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
    SocketService().sendChatConnection(widget.chat.participantsKey, "bye");
    SocketService().close();
  }

  final Map<String, Timer> _typingTimers = {};

  Future<void> manageSocketConnection() async {
    await SocketService().connect();
    await SocketService().sendChatConnection(
      widget.chat.participantsKey,
      "hello",
    );

    SocketService().channel.stream.listen(
      (data) {
        data = jsonDecode(data);
        if (data["typing"] != null) {
          String typingUserId = data["typing"];
          ChatUser typingUser = ChatUser(id: data["typing"]);
          if (!_typingUsers.any((user) => user.id == typingUserId)) {
            setState(() {
              _typingUsers.add(typingUser);
            });
          }

          _typingTimers[typingUserId]?.cancel();

          _typingTimers[typingUserId] = Timer(Duration(seconds: 2), () {
            setState(() {
              _typingUsers.removeWhere((user) => user.id == typingUserId);
            });
            _typingTimers.remove(typingUserId);
          });
        } else if (data["inChat"] != null) {
          if (data["inChat"]) {
            setState(() {
              _color = Colors.lightGreen;
            });
          } else {
            setState(() {
              _color = Colors.redAccent;
            });
          }
        }
      },
      onError: (error) {
        debugPrint('ERROR: $error');
      },
      onDone: () {
        debugPrint('Conexión cerrada');
      },
    );
  }

  Future<void> _loadUserId() async {
    int? storedId = await getUserLoggedUID();
    var storedChatParams = await getChatParams(widget.chat);
    var chatImg = await getChatImage(widget.chat.participantsKey);
    String storedChatName = storedChatParams['chatName'];

    if (storedId != null) {
      setState(() {
        _user = ChatUser(id: storedId.toString());
        _userId = storedId;
        if (_chatName == "") _chatName = storedChatName;
        if (_chatImgPath == "") _chatImgPath = chatImg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  _chatImgPath,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/no_image.png',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Text(
                _chatName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: ColorConstants.blackColor),
          onPressed: () {
            context.go('/home');
          },
        ),
        shape: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 240, 240, 240),
            width: 1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(radius: 7, backgroundColor: _color),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: _database.getChatMessages(widget.chat.participantsKey),
          builder: (context, snapshot) {
            List<ChatMessage> chatMessages = [];

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final docs = snapshot.data!.docs;

              List<Message> messages =
                  docs
                      .map(
                        (doc) => Message.fromJson(
                          doc.data() as Map<String, dynamic>,
                        ),
                      )
                      .toList();

              chatMessages =
                  messages
                      .map(
                        (message) => ChatMessage(
                          user: ChatUser(id: message.senderId.toString()),
                          text: message.content,
                          createdAt: message.timestamp.toDate(),
                        ),
                      )
                      .toList();
            }

            return DashChat(
              currentUser: _user,
              typingUsers: _typingUsers,
              onSend: (ChatMessage m) async {
                int? id = await getUserLoggedUID();

                if (id != null) {
                  chatMessages.add(
                    ChatMessage(
                      user: ChatUser(id: id.toString()),
                      createdAt: Timestamp.now().toDate(),
                    ),
                  );
                  setState(() {});
                }

                await _chatModel.sendMessage(
                  m.text,
                  widget.chat.getReceptorId(_userId),
                );
                setState(() {});
              },
              messageOptions: MessageOptions(
                showOtherUsersAvatar: false,
                showTime: true,
                currentUserContainerColor: ColorConstants.mainColor,
              ),
              inputOptions: InputOptions(
                alwaysShowSend: true,
                leading: [
                  IconButton(onPressed: () {}, icon: Icon(LucideIcons.plus)),
                ],
                inputToolbarStyle: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: const Color.fromARGB(255, 240, 240, 240),
                      width: 1.0,
                    ),
                  ),
                ),
                inputTextStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
                sendButtonBuilder: (send) {
                  return IconButton(
                    onPressed: send,
                    icon: Icon(LucideIcons.send),
                  );
                },
                onTextChange: (value) {
                  SocketService().sendTypingSignal(widget.chat.participantsKey);
                },
              ),
              messages: chatMessages,
            );
          },
        ),
      ),
    );
  }
}
