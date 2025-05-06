import 'package:chat_app/entities/chat.dart';
import 'package:chat_app/views/screens/config/config_screen.dart';
import 'package:chat_app/views/screens/auth/fingerprint_validation.dart';
import 'package:chat_app/views/screens/home_screen.dart';
import 'package:chat_app/views/screens/chat/chat_screen.dart';
import 'package:chat_app/views/screens/auth/login_screen.dart';
import 'package:chat_app/views/screens/main_screen.dart';
import 'package:chat_app/views/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

GoRouter appRouter(
  String initialLocation,
  GlobalKey<NavigatorState> navigatorKey,
) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    redirect: (context, state) async {
      if (state.fullPath == '/home') {
        final secureStorage = FlutterSecureStorage();
        String? token = await secureStorage.read(key: "token");

        if (token == null) {
          return "/main";
        }
      } else {
        return null;
      }
    },
    routes: <RouteBase>[
      GoRoute(path: '/main', builder: (context, state) => MainScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/config', builder: (context, state) => ConfigScreen()),
      GoRoute(
        path: '/fingerprint',
        builder: (context, state) => FingerprintValidation(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          final chat = state.extra;
          print(chat.toString());
          if (chat is! Chat) {
            return const Scaffold(
              body: Center(child: Text('Buscando chat...')),
            );
          }
          return ChatScreen(chat: chat);
        },
      ),
    ],
  );
}
