import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:social_media_app_project/model/user_model.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view/profile_view.dart';
import 'package:social_media_app_project/view_model/auth_model.dart';
import 'package:social_media_app_project/view_model/storage_model.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';

class EditProfileView extends StatefulWidget {
  final Map<String, dynamic> snap;
  const EditProfileView({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  Uint8List? image;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController myNameController = TextEditingController();

  selectImage() async {
    Uint8List im = await AuthModel().pickImage(ImageSource.gallery);
    setState(() {
      image = im;
    });
  }

  @override
  void initState() {
    super.initState();
    usernameController =
        TextEditingController(text: widget.snap['username'] ?? '');
    bioController = TextEditingController(text: widget.snap['bio'] ?? '');
    myNameController = TextEditingController(text: widget.snap['myname'] ?? '');
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void saveDetails() async {
    try {
      print("Save Details function called");
      String newUsername = usernameController.text.trim();
      String newBio = bioController.text.trim();
      String myname = myNameController.text.trim();
      print("New Username: $newUsername");
      print("New Bio: $newBio");
      print("New Name: $myname");

      // Check if the current user is not null
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Make sure an image is selected
        if (image != null) {
          String newPhotoUrl = await StorageModel()
              .uploadImageToStorage('profilePics', image!, false);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({
            'username': newUsername,
            'bio': newBio,
            'name': myname,
            'photoUrl': newPhotoUrl,
          });
        } else {
          // If no image is selected, update only username and bio
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'username': newUsername, 'bio': newBio, 'name': myname});
        }
      } else {
        print("Error: Current user is null");
      }
    } catch (e) {
      print("Error updating user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // var getUserName = widget.snap['username'];
    // var getUserBio = widget.snap['bio'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null
                        ? MemoryImage(image!)
                        : NetworkImage(widget.snap['photoUrl'])
                            as ImageProvider<Object>?),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0025,
                ),
                TextButton(
                    onPressed: selectImage,
                    child: const Text(
                      'Edit Profile Avatar',
                      style: TextStyle(color: AppColors.color3, fontSize: 13),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: myNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      contentPadding: EdgeInsets.only(
                        left: 8,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 8,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: TextField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 8, top: 5),
                      border: InputBorder.none,
                    ),
                    maxLines: 5,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: InkWell(
                    onTap: () {
                      saveDetails();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileView(uid: widget.snap['uid']),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(color: AppColors.color3),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: const Center(
                        child: Text(
                          'Save Details',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
