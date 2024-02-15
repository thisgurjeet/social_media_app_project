import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String caption;
  final String uid;
  final String username;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final likes;
  final String profImage;

  Post(
      {required this.caption,
      required this.uid,
      required this.username,
      required this.postId,
      required this.datePublished,
      required this.postUrl,
      required this.likes,
      required this.profImage});

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      caption: snapshot["caption"] ?? '',
      uid: snapshot["uid"] ?? '',
      username: snapshot["username"] ?? '',
      postId: snapshot["postId"] ?? '',
      datePublished: snapshot["datePublished"] ?? '',
      postUrl: snapshot["postUrl"] ?? '',
      likes: snapshot["likes"] ?? '',
      profImage: snapshot["profImage"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "caption": caption,
        "uid": uid,
        "username": username,
        "postId": postId,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "likes": likes,
        "profImage": profImage
      };
}
