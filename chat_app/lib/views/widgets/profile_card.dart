import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/entities/chat.dart';
import 'package:chat_app/entities/user.dart';
import 'package:chat_app/utils/chat_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class ProfileCard extends StatefulWidget {
  final User user;
  final bool showChatOption;
  const ProfileCard({
    super.key,
    required this.user,
    required this.showChatOption,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.network(
                  widget.user.profilePicture!,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/no_image.png',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Text(
                "${widget.user.name} ${widget.user.lastName}",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                widget.user.rol,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                ),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.smartphone, size: 17),
                      SizedBox(width: 5),
                      Text(
                        widget.user.phoneNumber,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.atSign, size: 17),
                      SizedBox(width: 5),
                      Text(
                        widget.user.email,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w200,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              widget.showChatOption
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(
                          '/chat',
                          extra: Chat(
                            id: "",
                            lastMessage: "",
                            participantsKey: getChatParticipantsKey(
                              _userId,
                              widget.user.id!,
                            ),
                            participants: [widget.user.id!, _userId],
                            names: [widget.user.name, _userId.toString()],
                            updatedAt: Timestamp.now(),
                            lastSender: _userId,
                            status: "unread",
                          ),
                        );
                      },
                      icon: Icon(
                        LucideIcons.messageCircle,
                        size: 18,
                        color: ColorConstants.whiteColor,
                      ),
                      label: Text(
                        "Ir al Chat",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }
}
