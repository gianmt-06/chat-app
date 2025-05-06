import 'dart:convert';

import 'package:chat_app/constants/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChatModel {
  Future<http.Response> sendMessage(String content, int receptorId) async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();

    try {
      String? token = await secureStorage.read(key: "token");
      var url = Uri.http(ApiConfig.apiURI, '/messages/send', {'q': '{http}'});
      var body = json.encode({"content": content, "receptorId": receptorId});

      var response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      return response;
    } catch (e) {
      return Future.value(http.Response('server_error', 500));
    }
  }

  Future<http.Response> readMessage(String chatId) async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();

    try {
      String? token = await secureStorage.read(key: "token");
      var url = Uri.http(ApiConfig.apiURI, '/messages/read/$chatId', {'q': '{http}'});

      var response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      return response;
    } catch (e) {
      return Future.value(http.Response('server_error', 500));
    }
  }
}
