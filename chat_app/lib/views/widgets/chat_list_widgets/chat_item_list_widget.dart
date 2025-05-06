import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/entities/chat.dart';
import 'package:chat_app/utils/chat_utils.dart';
import 'package:chat_app/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatItemListWidget extends StatefulWidget {
  final Chat chat;
  const ChatItemListWidget({super.key, required this.chat});

  @override
  State<ChatItemListWidget> createState() => _ChatItemListWidgetState();
}

class _ChatItemListWidgetState extends State<ChatItemListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      // highlightColor: const Color.fromARGB(19, 44, 128, 255),
      // splashColor: const Color.fromARGB(47, 44, 128, 255),
      onTap: () {
        context.push('/chat', extra: widget.chat);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: getChatImage(widget.chat.participantsKey),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ClipOval(
                    child: Image.network(
                      snapshot.data!,
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
                  );
                } else {
                  return CircleAvatar(
                    radius: 27,
                    backgroundColor: const Color.fromARGB(255, 238, 238, 238),
                  );
                }
              },
            ),

            SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: FutureBuilder(
                future: getChatParams(widget.chat),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!['chatName'],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            (snapshot.data!['chatStatus'] == "read")
                                ? Icon(
                                  LucideIcons.checkCheck,
                                  color: ColorConstants.mainColor,
                                  size: 14,
                                )
                                : Icon(
                                  LucideIcons.check,
                                  color: ColorConstants.softGrayColor,
                                  size: 14,
                                ),
                            SizedBox(width: 5),
                            Text(
                              widget.chat.lastMessage,
                              style:
                                  (snapshot.data!['chatStatus'] == "read")
                                      ? TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        color: ColorConstants.softGrayColor,
                                        fontSize: 13,
                                      )
                                      : TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: ColorConstants.blackColor,
                                        fontSize: 13,
                                      ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Center();
                  }
                },
              ),
            ),
            buildChatDate(widget.chat.updatedAt.toDate()),
          ],
        ),
      ),
    );
  }

  Widget buildChatDate(DateTime date) {
    String text = "";
    if (isToday(date)) {
      text = hourMin(date);
    } else if (isYesterday(date)) {
      text = "Ayer";
    } else {
      text = getDate(date);
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w200,
        color: ColorConstants.softGrayColor,
      ),
    );
  }
}
