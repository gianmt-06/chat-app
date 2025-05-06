import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/models/auth_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utils/chat_utils.dart';
import 'package:chat_app/views/widgets/profile_card.dart';
import 'package:chat_app/views/widgets/utils/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CurrentUserProfileScreen extends StatefulWidget {
  const CurrentUserProfileScreen({super.key});

  @override
  State<CurrentUserProfileScreen> createState() =>
      _CurrentUserProfileScreenState();
}

class _CurrentUserProfileScreenState extends State<CurrentUserProfileScreen> {
  int _userId = -1;
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    int? storedId = await getUserLoggedUID();
    if (storedId != null) {
      setState(() {
        _userId = storedId;
      });
    }
  }

  Future<void> _logout() async {
    AuthModel authModel = AuthModel();
    await authModel.logout();
    if (!mounted) return;
    context.go('/main');
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = UserModel();
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Expanded(
        child: FutureBuilder(
          future: userModel.getUser(_userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: Text('Cargando el perfil de usuario...'));
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ProfileCard(user: snapshot.data!, showChatOption: false),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onTap: () {
                                context.push('/config');
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                LucideIcons.cog,
                                                color: Colors.black,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "Configuraciones",
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(LucideIcons.arrowRight),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: ButtonWidget(
                                    buttonColor: ColorConstants.whiteColor,
                                    textColor: Colors.redAccent,
                                    onPressed: () async {
                                      await _logout();
                                    },
                                    text: "Cerrar Sesión",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 50),

                      // Expanded(child: Container()),
                    ],
                  );
                }
            }
          },
        ),
      ),
    );
  }
}
