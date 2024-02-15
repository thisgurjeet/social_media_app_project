import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app_project/res/components/post_card.dart';
import 'package:social_media_app_project/res/utils/colors.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 235, 243, 234),
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.telegram,
              color: AppColors.color3,
              size: 28,
            ),
          ),
        ],
        title: Text(
          'LoopLoom',
          style: GoogleFonts.lato(
            color: AppColors.color3,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return PostCard(
                snap: snapshot.data!.docs[index].data(),
              );
            },
          );
        },
      ),
    );
  }
}
