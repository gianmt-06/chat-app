import 'dart:convert';

import 'package:chat_app/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/io.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IOWebSocketChannel channel;
  String uid = "";

  factory SocketService() => _instance;

  SocketService._internal();

  Future<void> connect() async {
    channel = IOWebSocketChannel.connect(
      'ws://${ApiConfig.socketsURI}/register',
    );

    final storage = FlutterSecureStorage();
    String? storedIdStr = await storage.read(key: 'session_uid');
    uid = storedIdStr!;

    channel.sink.add(
      jsonEncode({"type": "online", "userId": storedIdStr.toString()}),
    );
  }

  Future<void> sendChatConnection(String chatKey, String status) async {
    try {
      final storage = FlutterSecureStorage();
      String? storedIdStr = await storage.read(key: 'session_uid');
      channel.sink.add(
        jsonEncode({
          "type": "chat",
          "action": status,
          "userId": storedIdStr,
          "participantsKey": chatKey,
        }),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> sendTypingSignal(String chatKey) async {
    final storage = FlutterSecureStorage();
    String? storedIdStr = await storage.read(key: 'session_uid');
    channel.sink.add(
      jsonEncode({
        "type": "typing",
        "userId": storedIdStr,
        "participantsKey": chatKey,
      }),
    );
  }

  Future<void> listenData(Function callback) async {
    channel.stream.listen((data) {
      callback(data);
    });
  }

  void close() {
    channel.sink.close();
  }
}
