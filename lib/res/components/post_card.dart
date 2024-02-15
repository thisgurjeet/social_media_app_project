import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app_project/model/user_model.dart';
import 'package:social_media_app_project/res/components/like_animation.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view/comment_view.dart';
import 'package:social_media_app_project/view_model/firestore_model.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic>
      snap; // snap argument will use when we want to show the firebase storage data to the ui in real tme
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;

  int commentLen = 0;

  @override
  void initState() {
    // fetching the comments from the database
    getComments();
    super.initState();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();

      // instead of get we can use snapshots() and remove QuerySnapshot snap

      commentLen = snap.docs.length;
    } catch (e) {
      e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      child: Column(children: [
        const SizedBox(
          height: 1,
        ),
        Container(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          height: MediaQuery.of(context).size.height * 0.075,
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17.5,
                backgroundImage: NetworkImage(widget.snap['profImage']),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.snap['username'],
                style: GoogleFonts.lato(
                    color: AppColors.color3,
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(),
              ),
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shrinkWrap: true,
                                  children: [
                                    'Delete',
                                  ]
                                      .map((e) => InkWell(
                                            onTap: () {
                                              FirestoreModel().deletePost(
                                                widget.snap['postId'],
                                              );
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              child: Text(e),
                                            ),
                                          ))
                                      .toList()),
                            ));
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.color3,
                    size: 25,
                  ))
            ],
          ),
        ),
// Image Section
        GestureDetector(
          onDoubleTap: () async {
            setState(() {
              isLikeAnimating = true;
            });
            await FirestoreModel().likePost(
                widget.snap['postId'], user!.uid, widget.snap['likes']);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Post Section
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: Image.network(
                  widget.snap['postUrl'],
                  fit: BoxFit.cover,
                ),
              ),
              // Like animation
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                // we only show animated like if it is animating thats why 1
                opacity: isLikeAnimating ? 1 : 0,
                child: LikeAnimation(
                  isAnimating: isLikeAnimating,
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  onEnd: () {
                    setState(() {
                      isLikeAnimating = false;
                    });
                  },
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ),
            ],
          ),
        ),
        // LIKE COMMENT SECTION
        Container(
          height: MediaQuery.of(context).size.height * 0.05,
          // decoration: BoxDecoration(color: AppColors.color1),
          padding: const EdgeInsets.only(left: 5, right: 10),
          child: Row(
            children: [
              LikeAnimation(
                // we will only animate if it contains user uid
                isAnimating: widget.snap['likes']?.contains(user?.uid) ?? false,
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreModel().likePost(
                        widget.snap['postId'], user!.uid, widget.snap['likes']);
                  },
                  icon: widget.snap['likes']?.contains(user?.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: AppColors.color3,
                          size: 30,
                        )
                      : const Icon(Icons.favorite_outline,
                          color: AppColors.color3, size: 30),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommentScreen(
                              // passing snap as arguments
                              snap: widget.snap,
                            )));
                  },
                  icon: const Icon(
                    Icons.comment_bank_outlined,
                    color: AppColors.color3,
                    size: 30,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share_sharp,
                    color: AppColors.color3,
                    size: 30,
                  )),
              Expanded(child: Container()),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.bookmark_border,
                    color: AppColors.color3,
                    size: 30,
                  )),
            ],
          ),
        ),
        // Rest
        Container(
          height: MediaQuery.of(context).size.height * 0.14,
          // decoration: const BoxDecoration(color: Colors.blue),
          padding: const EdgeInsets.only(left: 15, right: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.snap['likes']?.length ?? 0} likes',
                  // '4,234 likes',
                  style: GoogleFonts.lato(
                      color: AppColors.color3,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      widget.snap['username'],
                      style: GoogleFonts.lato(
                          color: AppColors.color3,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          showAboutDialog(context: context);
                        },
                        child: Text(
                          widget.snap['caption'],
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 1.9,
                ),
                Text(
                  DateFormat.yMMMd()
                      .format(widget.snap['datePublished'].toDate()),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: AppColors.color3),
                ),
                const SizedBox(
                  height: 2,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CommentScreen(snap: widget.snap)));
                  },
                  child: Text(
                    'View all $commentLen comments',
                    style:
                        const TextStyle(fontSize: 16, color: AppColors.color3),
                  ),
                ),
                const SizedBox(
                  height: 1.3,
                ),
              ]),
        )
      ]),
    );
  }
}
