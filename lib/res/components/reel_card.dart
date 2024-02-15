import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app_project/model/user_model.dart';
import 'package:social_media_app_project/res/components/like_animation.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view/reel_comment_view.dart';
import 'package:social_media_app_project/view_model/firestore_model.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';
import 'package:video_player/video_player.dart';

class ReelCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  const ReelCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = true;
  bool isLikeAnimating = false;
  int commentLen = 0;

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();

      commentLen = snap.docs.length;
    } catch (e) {
      e.toString();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.network(widget.snap['reelUrl']);
    _initializeVideoPlayer();
    getComments();
  }

  Future<void> _initializeVideoPlayer() async {
    await _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.addListener(_videoListener);
    setState(() {});
    _videoPlayerController.play();
  }

  void _videoListener() {
    if (_videoPlayerController.value.position >=
        _videoPlayerController.value.duration) {
      _videoPlayerController.seekTo(Duration.zero);
      _videoPlayerController.play();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(children: [
          _videoPlayerController.value.isInitialized
              ? GestureDetector(
                  onDoubleTap: () async {
                    setState(() {
                      isLikeAnimating = true;
                    });
                    await FirestoreModel().likeReel(
                        widget.snap['reelId'], user!.uid, widget.snap['likes']);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ),
                )
              : Container(),
          Positioned.fill(
              child: Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
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
          )),
          Positioned(
            bottom: 50,
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 21.5,
                          backgroundImage:
                              NetworkImage(widget.snap['profImage']),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.035,
                        ),
                        Text(
                          widget.snap['username'],
                          style: const TextStyle(
                            fontSize: 17.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      child: Text(
                        widget.snap['caption'],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14.2),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width -
                MediaQuery.of(context).size.width * 0.14,
            bottom: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              children: [
                widget.snap['likes']?.contains(user?.uid)
                    ? const Icon(
                        Icons.favorite,
                        color: AppColors.color3,
                        size: 33,
                      )
                    : const Icon(Icons.favorite_outline,
                        color: Colors.white, size: 33),
                Text(
                  '${widget.snap['likes']?.length ?? 0}',
                  style: const TextStyle(color: Colors.white, fontSize: 13.75),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ReelCommentView(
                              snap: widget.snap,
                            )));
                  },
                  icon: const Icon(
                    Icons.comment_outlined,
                    color: Colors.white,
                    size: 33,
                  ),
                ),
                Text(
                  commentLen.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13.75),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 33,
                ),
                const Text(
                  '0',
                  style: TextStyle(color: Colors.white, fontSize: 13.75),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shrinkWrap: true,
                          children: [
                            'Delete this reel',
                          ]
                              .map((e) => InkWell(
                                    onTap: () {
                                      FirestoreModel().deleteReel(
                                        widget.snap['reelId'],
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      child: Text(e),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 33,
                  ),
                ),
              ],
            ),
          )
        ]));
  }
}
