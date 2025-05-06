import 'dart:convert' as convert;

import 'package:chat_app/constants/api_config.dart';
import 'package:chat_app/entities/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserModel {
  Future<List<User>> getAllUsers() async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();

    try {
      String? token = await secureStorage.read(key: "token");
      var url = Uri.http(ApiConfig.apiURI, '/users/', {'q': '{http}'});
      var response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        return Future.value([]);
      }

      var jsonResponse = convert.jsonDecode(response.body) as dynamic;
      var responseFinal = jsonResponse["data"] as List<dynamic>;

      List<User> users =
          responseFinal.map((product) => User.fromJson(product)).toList();

      return Future.value(users);
    } catch (e) {
      return Future.value([]);
    }
  }

  Future<User?> getUser(int uid) async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();

    if (uid == -1) throw Error();
    try {
      String? token = await secureStorage.read(key: "token");
      var url = Uri.http(ApiConfig.apiURI, '/users/id/$uid', {
        'q': '{http}',
      });
      var response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        return Future.value();
      }

      var jsonResponse = convert.jsonDecode(response.body) as dynamic;
      User users = User.fromJson(jsonResponse["data"]);

      return Future.value(users);
    } catch (e) {
      return Future.value();
    }
  }
}
