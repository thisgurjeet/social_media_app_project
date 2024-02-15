import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app_project/view/add_post_view.dart';
import 'package:social_media_app_project/view/feed_view.dart';
import 'package:social_media_app_project/view/profile_view.dart';
import 'package:social_media_app_project/view/reel_feed_view.dart';
import 'package:social_media_app_project/view/search_view.dart';

List pages = [
  const FeedView(),
  const SearchView(),
  const AddPostView(),
  const ReelFeedView(),
  ProfileView(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
