import 'dart:convert';
import 'dart:io';

import 'package:chat_app/constants/api_config.dart';
import 'package:chat_app/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel {
  Future<http.Response> login(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage secureStorage = FlutterSecureStorage();

    String? tcm = prefs.getString("TCM");
    try {
      var url = Uri.http(ApiConfig.apiURI, '/auth/login', {'q': '{http}'});
      var body = json.encode({
        "email": email,
        "password": password,
        "TCM": tcm,
      });

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        await secureStorage.write(
          key: "token",
          value: responseBody["data"]["token"],
        );

        User user = User.fromJson(responseBody["data"]["user"]);

        await secureStorage.write(
          key: "session_uid",
          value: user.id!.toString(),
        );
        await secureStorage.write(
          key: "session_email",
          value: user.email.toString(),
        );
      }

      return response;
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(http.Response('server_error', 500));
    }
  }

  Future<http.StreamedResponse> registerUser(
    User user,
    File? profilePicture,
  ) async {
    var uri = Uri.parse("http://${ApiConfig.apiURI}/auth/register");
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = user.email;
    request.fields['password'] = user.password;
    request.fields['name'] = user.name;
    request.fields['lastName'] = user.lastName;
    request.fields['phoneNumber'] = user.phoneNumber;
    request.fields['rol'] = user.rol;

    if (profilePicture != null) {
      var stream = http.ByteStream(profilePicture.openRead());
      var length = await profilePicture.length();

      var multipartFile = http.MultipartFile(
        'profilePicture',
        stream,
        length,
        filename: basename(profilePicture.path),
      );

      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      debugPrint("Imagen y datos enviados correctamente.");
    } else {
      debugPrint("Error al enviar: ${response.statusCode}");
    }
    return response;
  }

  Future<void> logout() async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    SharedPreferences pref = await SharedPreferences.getInstance();

    await secureStorage.delete(key: "token");
    await secureStorage.delete(key: "session_uid");
    await secureStorage.delete(key: "session_email");
    await pref.remove('fingerprint_auth');
    return;
  }
}
