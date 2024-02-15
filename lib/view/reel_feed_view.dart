import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app_project/res/components/reel_card.dart';

class ReelFeedView extends StatefulWidget {
  const ReelFeedView({Key? key}) : super(key: key);

  @override
  State<ReelFeedView> createState() => _ReelFeedViewState();
}

class _ReelFeedViewState extends State<ReelFeedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('reels').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.custom(
            physics:
                const BouncingScrollPhysics(), // Add BouncingScrollPhysics for smooth scrolling
            childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ReelCard(
                  snap: snapshots.data!.docs[index].data(),
                );
              },
              childCount: snapshots.data!.docs.length,
            ),
          );
        },
      ),
    );
  }
}
