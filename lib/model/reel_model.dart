import 'package:cloud_firestore/cloud_firestore.dart';

class Reel {
  final String caption;
  final String uid;
  final String username;
  final String reelId;
  final DateTime datePublished;
  final String reelUrl;
  final List likes;
  final String profImage;

  Reel({
    required this.caption,
    required this.uid,
    required this.username,
    required this.reelId,
    required this.datePublished,
    required this.reelUrl,
    required this.likes,
    required this.profImage,
  });

  static Reel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Reel(
      caption: snapshot["caption"] ?? '',
      uid: snapshot["uid"] ?? '',
      username: snapshot["username"] ?? '',
      reelId: snapshot["reelId"] ?? '',
      datePublished: snapshot["datePublished"] ?? '',
      reelUrl: snapshot["reelUrl"] ?? '',
      likes: snapshot["likes"] ?? '',
      profImage: snapshot["profImage"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "caption": caption,
        "uid": uid,
        "username": username,
        "reelId": reelId,
        "datePublished": datePublished,
        "reelUrl": reelUrl,
        "likes": likes,
        "profImage": profImage
      };
}
