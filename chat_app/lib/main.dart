import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/entities/chat.dart';
import 'package:chat_app/router/router.dart';
import 'package:chat_app/services/firebase_service.dart';
import 'package:chat_app/utils/chat_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await FirebaseService().init();
  final prefs = await SharedPreferences.getInstance();
  final fingerprintPreference = prefs.getBool('fingerprint_auth') ?? false;

  runApp(
    MyApp(initialLocation: fingerprintPreference ? '/fingerprint' : '/home'),
  );
}

class MyApp extends StatefulWidget {
  final String initialLocation;
  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> setupInteractedMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print("handleeeeee");
    print("${message.data['route']}");
    if (message.data['route'] != '') {
      try {
        int senderId = int.parse(message.data['senderId']);
        int receptorId = int.parse(message.data['receptorId']);

        final chat = Chat(
          id: message.data['chatId'],
          lastMessage: "e",
          participantsKey: getChatParticipantsKey(receptorId, senderId),
          participants: [senderId, receptorId],
          names: [message.data['senderName'], ""],
          updatedAt: Timestamp.now(),
          lastSender: senderId,
          status: "unread",
        );

        print("chat ${chat.toJson()}");
        print(navigatorKey.currentContext);
        Future.delayed(Duration(milliseconds: 500), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            context.pushNamed('chat', extra: chat);
          }
        });
      } catch (e) {
        print("eRRRORORORRO");
        print(e.toString());
      }
    }
  }

  @override
  void initState() {
    setupInteractedMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChatApp',
      routerConfig: appRouter(widget.initialLocation, navigatorKey),
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ColorConstants.softGrayColor,
          selectionColor: const Color.fromARGB(59, 44, 128, 255),
          selectionHandleColor: ColorConstants.mainColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, elevation: 0),
      ),
    );
  }
}
