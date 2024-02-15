import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app_project/model/reel_model.dart';
import 'package:uuid/uuid.dart';

import 'package:social_media_app_project/model/post_model.dart';
import 'package:social_media_app_project/view_model/storage_model.dart';

class FirestoreModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // uploading post to database
  Future<String> uploadPost(
    String caption,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occured";
    try {
      String photoUrl =
          await StorageModel().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();

      Post post = Post(
          caption: caption,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          likes: [],
          profImage: profImage);

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (e) {
      e.toString();
    }
    return res;
  }

// uploading reel to database
  Future<String> uploadReel(
    String caption,
    XFile file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occured";
    try {
      // Convert File to XFile
      XFile xFile = XFile(file.path);
      String reelUrl = await StorageModel().uploadReelToStorage(xFile);

      String reelId = const Uuid().v1();

      Reel reel = Reel(
          caption: caption,
          uid: uid,
          username: username,
          reelId: reelId,
          datePublished: DateTime.now(),
          reelUrl: reelUrl,
          likes: [],
          profImage: profImage);

      _firestore.collection('reels').doc(reelId).set(reel.toJson());
      res = "success";
    } catch (e) {
      e.toString();
    }
    return res;
  }

// function to like reel
  Future<void> likeReel(String reelId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('reels').doc(reelId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('reels').doc(reelId).update({
          'likes': FieldValue.arrayUnion([uid]) // adding like
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // function to like post
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      // first we are checking if the like is already liked, then we just remove it
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          // update is used when you need to change only one parameter in firestore database
          'likes': FieldValue.arrayRemove([uid]) // removing like
        });
      }
      // in else condition we are liking the post
      else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]) // adding like
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

// function to post reel comment
  Future<void> postReelComment(String reelId, String text, String uid,
      String name, String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('reels')
            .doc(reelId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'user': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'commentLikes': []
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'user': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'commentLikes': []
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> deleteReel(String reelId) async {
    try {
      await _firestore.collection('reels').doc(reelId).delete();
    } catch (e) {
      e.toString();
    }
  }

  // function to write follow user
  Future<void> followUser(
    String uid, // our uid
    String followId, // uid of the user we are going to follow
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
// accessing user(my) following list
      List following = snap['following'];
// if we are alreasy following the user, if my following already contains the other users follow id
      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        // we have to follow the user
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> likeComment(
    String postId,
    String commentId,
    String uid,
    List<dynamic> commentLikes,
  ) async {
    try {
      if (commentLikes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'commentLikes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'commentLikes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print('Error updating commentLikes: $e');
      // Handle the error as needed
    }
  }
}
