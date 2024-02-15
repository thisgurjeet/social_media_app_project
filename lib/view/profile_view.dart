import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:social_media_app_project/res/components/follow_button.dart';
import 'package:social_media_app_project/res/components/settings_drawer.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view/edit_profile_view.dart';
import 'package:social_media_app_project/view/login_view.dart';
import 'package:social_media_app_project/view_model/auth_model.dart';
import 'package:social_media_app_project/view_model/firestore_model.dart';
import 'package:video_player/video_player.dart';

class ProfileView extends StatefulWidget {
  final String uid;
  const ProfileView({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late VideoPlayerController _controller;

  var userData = {};

  int postLen = 0;
  int reelLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  @override

// getting data from firebase database
  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post length
      // var postSnap = await FirebaseFirestore.instance
      //     .collection('posts')
      //     .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      //     .get();
// get post length
      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid',
              isEqualTo:
                  widget.uid) // Use widget.uid instead of currentUser!.uid
          .get();

      var reelSnap = await FirebaseFirestore.instance
          .collection('reels')
          .where('uid', isEqualTo: widget.uid)
          .get();
      // get reel length
      reelLen = reelSnap.docs.length;

      // get post length
      postLen = postSnap.docs.length;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      e.toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 13),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            children: [
                              SimpleDialogOption(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    left: 20,
                                    right: 20,
                                    bottom: 10,
                                  ),
                                  child: const Text(
                                    'Sign out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.color3,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await AuthModel().signOut();
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginView()));
                                  }),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: AppColors.color3,
                    ),
                  ),
                )
              ],
              centerTitle: false,
              backgroundColor: const Color.fromARGB(255, 235, 243, 234),
              title: Text(
                userData['username'],
                style: GoogleFonts.lato(color: AppColors.color3),
              ),
            ),
            body: ListView(children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(userData['photoUrl']),
                          radius: 40.5,
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(postLen, "posts"),
                                buildStatColumn(followers, "followers"),
                                buildStatColumn(following, "following"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // managing the button states
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? FollowButton(
                                        backgroundColor: Colors.white,
                                        text: 'Edit Profile',
                                        textColor: AppColors.color3,
                                        borderColor: AppColors.color3,
                                        function: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfileView(
                                                        snap: userData as Map<
                                                            String, dynamic>,
                                                      )));

                                          // await AuthModel().signOut();
                                          // Navigator.of(context).pushReplacement(
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             const LoginView()));
                                        },
                                      )
                                    : isFollowing
                                        ? FollowButton(
                                            backgroundColor: Colors.white,
                                            text: 'Unfollow',
                                            textColor: AppColors.color3,
                                            borderColor: AppColors.color3,
                                            function: () async {
                                              await FirestoreModel().followUser(
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  userData['uid']);
                                              setState(() {
                                                isFollowing = false;
                                                followers--;
                                              });
                                            },
                                          )
                                        : FollowButton(
                                            backgroundColor: AppColors.color3,
                                            text: 'Follow',
                                            textColor: Colors.white,
                                            borderColor: AppColors.color3,
                                            function: () async {
                                              await FirestoreModel().followUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userData['uid'],
                                              );
                                              setState(() {
                                                isFollowing = true;
                                                followers++;
                                              });
                                            },
                                          )
                              ],
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 15),
                    child: Text('@' + userData['username'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.color3)),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 1),
                      child: userData['name'] != null
                          ? Text(userData['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: AppColors.color3))
                          : null),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 0.75),
                    child: Text(
                      userData['bio'],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const Divider(),
                  DefaultTabController(
                    length: 2, // Number of tabs
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(
                              icon: Icon(
                                Icons.grid_on,
                                color: AppColors.color3,
                              ),
                            ),
                            Tab(
                                icon: Icon(
                              Icons.video_collection_outlined,
                              color: AppColors.color3,
                            )), // Add additional tabs as needed
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height -
                              200, // Adjust height as needed
                          child: TabBarView(
                            children: [
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('uid', isEqualTo: widget.uid)
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return GridView.builder(
                                    itemCount: snapshot.data!.docs.length,
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 1.5,
                                      mainAxisExtent: 150,
                                      childAspectRatio: 1,
                                    ),
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot snap =
                                          snapshot.data!.docs[index];
                                      return Container(
                                        child: Image(
                                          image: NetworkImage(snap['postUrl']),
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              // Add TabBarView for Reels or other content
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('reels')
                                    .where('uid', isEqualTo: widget.uid)
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return GridView.builder(
                                    itemCount: snapshot.data!.docs.length,
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 1.5,
                                      mainAxisExtent: 150,
                                      childAspectRatio: 1,
                                    ),
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot snap =
                                          snapshot.data!.docs[index];
                                      // Create a VideoPlayerController from the video URL
                                      // ignore: deprecated_member_use
                                      VideoPlayerController controller =
                                          VideoPlayerController.network(
                                        snap[
                                            'reelUrl'], // Assuming 'videoUrl' is the field containing the video URL
                                      );
                                      return Container(
                                        child: FutureBuilder(
                                          future: controller.initialize(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              // If the VideoPlayerController has finished initializing, show the video
                                              return AspectRatio(
                                                aspectRatio: controller
                                                    .value.aspectRatio,
                                                child: VideoPlayer(controller),
                                              );
                                            } else {
                                              // Otherwise, show a loading indicator
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ]),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.color3),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.color3),
        ),
      ],
    );
  }
}
