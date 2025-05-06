import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/entities/user.dart';
import 'package:flutter/material.dart';

class UserListWidget extends StatelessWidget {
  final User user;
  final Function openProfileModal;
  const UserListWidget({
    super.key,
    required this.user,
    required this.openProfileModal,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onTap: () {
        openProfileModal(context, user);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                user.profilePicture!,
                fit: BoxFit.cover,
                width: 54,
                height: 54,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/no_image.png',
                    fit: BoxFit.cover,
                    width: 54,
                    height: 54,
                  );
                },
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.softGrayColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
