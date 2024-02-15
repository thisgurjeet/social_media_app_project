import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/res/utils/constants.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int pageIdx = 0;
  @override
  void initState() {
    addData();
    super.initState();
  }

  addData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 235, 243, 234),
        onTap: (idx) {
          setState(() {
            pageIdx = idx;
          });
        },
        selectedItemColor: AppColors.color3,
        unselectedItemColor: AppColors.color2,
        currentIndex: pageIdx,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 30,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_box,
                size: 30,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.video_collection_outlined,
                size: 30,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              label: ''),
        ],
      ),
      body: pages[pageIdx],
    );
  }
}
