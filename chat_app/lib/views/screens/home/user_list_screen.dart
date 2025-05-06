import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/entities/user.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/views/widgets/profile_card.dart';
import 'package:chat_app/views/widgets/user_list_widgets/user_list_widget.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final userModel = UserModel();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: userModel.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Text('Obteniendo la lista de usuarios...'),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),

                      itemCount: snapshot.data!.length,
                      separatorBuilder: (context, index) => SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        return UserListWidget(
                          user: snapshot.data![index],
                          openProfileModal: openProfileModal,
                        );
                      },
                    );
                  }
              }
            },
          ),
        ),
      ],
    );
  }

  void openProfileModal(BuildContext context, User user) async {
    await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ColorConstants.whiteColor,
      builder: (BuildContext context) {
        return ProfileCard(user: user, showChatOption: true);
      },
    );
  }
}
