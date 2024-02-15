import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app_project/model/user_model.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view_model/firestore_model.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  const CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(widget.snap['profilePic']?.toString() ?? ""),
            radius: 18,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.snap['user'] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.color3,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  '${widget.snap['text']}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          // to like the comment
          Column(
            children: [
              IconButton(
                onPressed: () async {
                  // Assuming you have access to postId, commentId, uid, and likesList
                  // DocumentSnapshot<Map<String, dynamic>> snap =
                  //     await FirebaseFirestore.instance
                  //         .collection('posts')
                  //         .doc('postId')
                  //         .collection('comments')
                  //         .doc('commentId')
                  //         .get();

                  await FirestoreModel().likeComment(
                    widget.snap['postId'],
                    widget.snap['commentId'],
                    widget.snap['uid'],
                    widget.snap['commentLikes'] ??
                        [], // Use empty list if 'commentLikes' is null
                  );
                  setState(() {});
                  // You may need to update the widget's state or refresh the UI here
                },
                icon: (widget.snap['commentLikes']?.contains(user?.uid) == true)
                    ? const Icon(
                        Icons.favorite,
                        color: AppColors.color3,
                      )
                    : const Icon(
                        Icons.favorite_outline,
                        color: AppColors.color3,
                      ),
              ),
              // Text('${widget.snap['commentLikes']?.length ?? ""}'),
            ],
          ),
        ],
      ),
    );
  }
}
