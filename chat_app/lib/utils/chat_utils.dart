import 'package:chat_app/constants/api_config.dart';
import 'package:chat_app/entities/chat.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<Map<String, dynamic>> getChatParams(Chat chat) async {
  String chatName = "Usuario anónimo";
  String chatStatus = "read";
  final storage = FlutterSecureStorage();

  String? storedIdStr = await storage.read(key: 'session_uid');
  if (storedIdStr == null) {
    return {'chatName': chatName, 'chatStatus': chatStatus};
  }

  int storedId = int.parse(storedIdStr);

  for (int i = 0; i < chat.participants.length; i++) {
    if (chat.participants[i] != storedId) {
      chatName = chat.names[i];
    }
  }

  if (chat.status == "unread" && chat.lastSender != storedId) {
    chatStatus = "unread";
  }

  return {'chatName': chatName, 'chatStatus': chatStatus};
}

String getChatParticipantsKey(int senderId, int receptorId) {
  final minId = senderId < receptorId ? senderId : receptorId;
  final maxId = senderId > receptorId ? senderId : receptorId;
  return '${minId}_$maxId';
}

Future<String> getChatImage(String chatkey) async {
  print("key $chatkey");
  String result = "";
  final sessionId = await getUserLoggedUID();
  if (sessionId != null) {
    result = chatkey.replaceAll(sessionId.toString(), "");
    result = result.replaceAll("_", "");
  }
  result =
      "http://${ApiConfig.bucketURI}/chat-app-media/profile-pictures/$result.webp";
  return result;
}

Future<int?> getUserLoggedUID() async {
  final storage = FlutterSecureStorage();
  String? storedIdStr = await storage.read(key: 'session_uid');
  int? storedId = storedIdStr != null ? int.tryParse(storedIdStr) : null;
  return storedId;
}
