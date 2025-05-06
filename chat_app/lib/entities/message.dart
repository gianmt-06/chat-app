import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Message {
  final int senderId;
  final String content;
  final int status;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.content,
    required this.status,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'] as int,
      content: json['content'] as String,
      status: json['status'] as int,
      timestamp: json['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'status': status,
      'timestamp': timestamp,
    };
  }

    Future<bool> isMine() async {
      final storage = FlutterSecureStorage();
      String? storedIdStr = await storage.read(key: 'session_uid');
      if (storedIdStr == null) return false;

      if (storedIdStr == senderId.toString()) return true;

      return false;
    }
  }
