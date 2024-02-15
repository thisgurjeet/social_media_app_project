import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:social_media_app_project/model/user_model.dart' as model;
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app_project/view_model/storage_model.dart';

class AuthModel {
  final FirebaseAuth auth = FirebaseAuth.instance; // for authentication
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // for database storage

  // pick image function to add profile picture
  pickImage(ImageSource src) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: src);
    if (file != null) {
      return file.readAsBytes();
    }
  }

// getting details of every user
  Future<model.User> getUserDetails() async {
    User currentUser = auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // sign up logic
  Future<String> signupUser({
    required String username,
    required String email,
    required String password,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      // signing up the user
      if (username.isNotEmpty ||
          email.isNotEmpty ||
          password.isNotEmpty ||
          bio.isNotEmpty) {
        UserCredential cred = await auth.createUserWithEmailAndPassword(
            email: email, password: password);

// extracting profile image url
        String photoUrl = await StorageModel()
            .uploadImageToStorage('profilePics', file, false);
        // storing the user in our firebase database
        model.User user = model.User(
            username: username,
            name: '',
            uid: cred.user!.uid,
            email: email,
            photoUrl: photoUrl,
            bio: bio,
            followers: [],
            following: []);

        await firestore.collection('users').doc(cred.user!.uid).set(user
            .toJson()); // set is used to create a new entry in firebase database

        res = 'success';
      } else {
        res = 'Please enter all the details';
      }
    } catch (e) {
      print(e.toString());
    }
    return res;
  }

  // logging in the user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = 'Some error occured';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter all the details';
      }
    } catch (e) {
      print(e.toString());
    }
    return res;
  }

  // signout function
  Future<void> signOut() async {
    await auth.signOut();
  }
}
