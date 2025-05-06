import 'package:chat_app/constants/api_config.dart';
import 'package:chat_app/utils/chat_utils.dart';
import 'package:chat_app/views/screens/home/chat_list_screen.dart';
import 'package:chat_app/views/screens/home/user_list_screen.dart';
import 'package:chat_app/views/screens/home/user_profile_screen.dart';
import 'package:chat_app/views/widgets/utils/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildMainAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  ChatListScreen(),
                  UserListScreen(),
                  CurrentUserProfileScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        controller: _tabController,
      ),
    );
  }

  AppBar _buildMainAppBar() {
    return AppBar(
      title: Text(
        "ChatApp",
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        FutureBuilder(
          future: getUserLoggedUID(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: IconButton(
                  onPressed: () {},
                  icon: ClipOval(
                    child: Image.network(
                      "http://${ApiConfig.bucketURI}/chat-app-media/profile-pictures/${snapshot.data}.webp",
                      fit: BoxFit.cover,
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/no_image.png',
                          fit: BoxFit.cover,
                          width: 30,
                          height: 30,
                        );
                      },
                    ),
                  ),
                ),
              );
            } else {
              return Center();
            }
          },
        ),
      ],
    );
  }
}
