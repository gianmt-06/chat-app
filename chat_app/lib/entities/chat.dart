import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String lastMessage;
  final String participantsKey;
  final List<int> participants;
  final List<String> names;
  final Timestamp updatedAt;
  final int lastSender;
  final String status;

  Chat({
    required this.id,
    required this.lastMessage,
    required this.participantsKey,
    required this.participants,
    required this.names,
    required this.updatedAt,
    required this.lastSender,
    required this.status
  });

  factory Chat.fromJson(String id, Map<String, dynamic> json) {
    return Chat(
      id: id,
      lastMessage: json['lastMessage'] as String,
      participantsKey: json['participantsKey'] as String,
      participants: List<int>.from(json['participants']),
      names: List<String>.from(json["namesToShow"]),
      updatedAt: json['updatedAt'] as Timestamp,
      lastSender: json['lastSender'],
      status: json['status'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'participantsKey': participantsKey,
      'participants': participants,
      'names': names,
      'updatedAt': updatedAt,
      'lastSender': lastSender,
      'status': status
    };
  }

  int getReceptorId(int currentUserId) {
    return participants.firstWhere((id) => id != currentUserId);
  }
}
