import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:social_media_app_project/model/user_model.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view_model/firestore_model.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';

import '../res/components/comment_card.dart';

class ReelCommentView extends StatefulWidget {
  final Map<String, dynamic> snap;
  const ReelCommentView({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<ReelCommentView> createState() => _ReelCommentViewState();
}

class _ReelCommentViewState extends State<ReelCommentView> {
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Comments',
          style: GoogleFonts.lato(color: AppColors.color3),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reels')
            .doc(widget.snap['reelId'])
            .collection(
                'comments') // we can use orderBy(date) if we would have used datePublished element
            .snapshots(),
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
                return CommentCard(
                  snap: snapshot.data!.docs[index].data(),
                );
              });
        },
      ),
      bottomNavigationBar: SafeArea(
          child: Container(
        height: kToolbarHeight,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user!.photoUrl),
              radius: 13,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                      hintText: 'Comment as ${user.username}',
                      border: InputBorder.none),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                // comment logic
                await FirestoreModel().postReelComment(
                  widget.snap['reelId'],
                  // this is the users who do stuff thats why use used state management user
                  commentController.text,
                  user.uid,
                  user.username,
                  user.photoUrl,
                );
                setState(() {
                  commentController.text =
                      ""; // after posting the comment i want to make sure the comment text field is empty
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: const Text(
                  'Post',
                  style: TextStyle(color: AppColors.color3, fontSize: 15),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
