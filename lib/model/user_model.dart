import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String name;
  final String uid; // unique user id to manage different users
  final String email;
  final String photoUrl;
  final String bio;
  final List followers;
  final List following;

// constructor function
  User(
      {required this.username,
      required this.name,
      required this.uid,
      required this.email,
      required this.photoUrl,
      required this.bio,
      required this.followers,
      required this.following});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      username: snapshot["username"] ?? '',
      name: snapshot["name"] ?? '',
      uid: snapshot["uid"] ?? '',
      email: snapshot["email"] ?? '',
      photoUrl: snapshot["photoUrl"] ?? '',
      bio: snapshot["bio"] ?? '',
      followers: snapshot["followers"] ?? '',
      following: snapshot["following"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "name": name,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following
      };
}
