import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app_project/model/reel_model.dart';
import 'package:social_media_app_project/model/user_model.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view/feed_view.dart';
import 'package:social_media_app_project/view/reel_feed_view.dart';

import 'package:social_media_app_project/view_model/auth_model.dart';
import 'package:social_media_app_project/view_model/firestore_model.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';
import 'package:video_player/video_player.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({super.key});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  Uint8List?
      _file; // if this image file is null we will show a add post button else we will show a screen to post image to firebase
  XFile? _xFile;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _reelCaptionController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = false;

  //  initializing the video controller
  @override
  void initState() {
    super.initState();
    if (_xFile != null) {
      _videoPlayerController = VideoPlayerController.file(File(_xFile!.path))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  void _handleVideo(XFile? xFile) {
    if (xFile != null) {
      _xFile = xFile;
      _videoPlayerController = VideoPlayerController.file(File(_xFile!.path))
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
          // method to play video again and again
          _videoPlayerController!.addListener(_onVideoCompleted);
        });
    }
  }

// Listener method for video completion
  void _onVideoCompleted() {
    if (_videoPlayerController!.value.position >=
        _videoPlayerController!.value.duration) {
      // Replay the video from the beginning
      _videoPlayerController!.seekTo(Duration.zero);
      _videoPlayerController!.play();
    }
  }

// function to post video to database
  void postReelToDatabase(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreModel().uploadReel(
          _reelCaptionController.text, _xFile!, uid, username, profImage);
      print(_reelCaptionController);
      if (res == "success") {
        setState(() {
          _isLoading = false;
          const SnackBar(content: Text('Posted!'));
          clearReel();
        });
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ReelFeedView()));
      } else {
        setState(() {
          _isLoading = false;
        });
        SnackBar(content: Text(res.toString()));
      }
    } catch (e) {
      print(e);
    }
  }

  //  function to post image to database
  void postImageToDatabase(
      String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreModel().uploadPost(
          _captionController.text, _file!, uid, username, profImage);

      if (res == "success") {
        setState(() {
          _isLoading = false;
          const SnackBar(content: Text('Posted!'));
          clearImage();
        });
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const FeedView()));
      } else {
        setState(() {
          _isLoading = false;
        });
        SnackBar(content: Text(res.toString()));
      }
    } catch (e) {
      e.toString();
    }
  }

  // function for dialog box and selecting image from sources
  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text(
              'Create a Post',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color3),
            ),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 10),
                child: const Text(
                  'Take a photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.color3,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file =
                      await AuthModel().pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 20),
                child: const Text(
                  'Choose from gallery',
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file =
                      await AuthModel().pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
            ],
          );
        });
  }

  // function for dialog box and a reel picker
  _selectReel(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text(
              'Create a Reel',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color3),
            ),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 10),
                child: const Text(
                  'Film from camera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.color3,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  XFile? xFile =
                      await ImagePicker().pickVideo(source: ImageSource.camera);
                  _handleVideo(xFile);
                  setState(() {
                    _xFile = xFile;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 20),
                child: const Text(
                  'Choose from gallery',
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.color3,
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  XFile? xFile = await ImagePicker()
                      .pickVideo(source: ImageSource.gallery);
                  _handleVideo(xFile);
                  setState(() {
                    _xFile = xFile;
                  });
                },
              ),
            ],
          );
        });
  }

// making the value of file null
  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void clearReel() {
    setState(() {
      _xFile = null;
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoPlayerController
        ?.removeListener(_onVideoCompleted); // Remove listener
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return
        // if the image has not selected yet show this
        _file == null && _xFile == null
            ? Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.color3,
                            width: 1,
                            style: BorderStyle.solid),
                      ),
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.upload_file_sharp,
                            color: AppColors.color3,
                            size: 35,
                          ),
                          const Text(
                            'Upload images from your gallery or camera',
                            style: TextStyle(fontSize: 14),
                          ),
                          Center(
                            child: InkWell(
                              onTap: () => _selectImage(context),
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: AppColors.color2),
                                  child: const Center(
                                    child: Text(
                                      'Upload Image',
                                      style: TextStyle(
                                          color: AppColors.color3,
                                          fontSize: 16.5),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.color3,
                            width: 1,
                            style: BorderStyle.solid),
                      ),
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.upload_file_sharp,
                            color: AppColors.color3,
                            size: 35,
                          ),
                          const Text(
                            'Upload reels from your gallery or camera',
                            style: TextStyle(fontSize: 14),
                          ),
                          Center(
                            child: InkWell(
                              onTap: () => _selectReel(context),
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: AppColors.color2),
                                  child: const Center(
                                    child: Text(
                                      'Upload Reel',
                                      style: TextStyle(
                                          color: AppColors.color3,
                                          fontSize: 16.5),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ))
// show this when image is selected or the image is not null
            : _file != null && _xFile == null
                ? Scaffold(
                    appBar: AppBar(
                      backgroundColor: AppColors.color2,
                      leading: IconButton(
                          onPressed: clearImage,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.color3,
                          )),
                      title: const Text(
                        'Post to',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      centerTitle: false,
                      actions: [
                        TextButton(
                            onPressed: () {
                              postImageToDatabase(
                                  user!.uid, user.username, user.photoUrl);
                            },
                            child: const Text(
                              'Post',
                              style: TextStyle(
                                  color: AppColors.color3,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ))
                      ],
                    ),
                    body: Column(children: [
                      _isLoading
                          ? const LinearProgressIndicator(
                              color: AppColors.color3,
                            )
                          : const Padding(padding: EdgeInsets.only(top: 0)),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22.5,
                            backgroundImage: NetworkImage(user!.photoUrl),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextField(
                              controller: _captionController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Write a Caption...',
                                  hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.color3,
                                      fontWeight: FontWeight.w500)),
                              maxLines: 8,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: AspectRatio(
                              aspectRatio: 487 / 451,
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        // memory image is used to show uint8list files
                                        image: MemoryImage(_file!),
                                        fit: BoxFit.fill,
                                        alignment: FractionalOffset.topCenter)),
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      )
                    ]),
                  )
                :
                // _file == null && _xFile != null
                Scaffold(
                    appBar: AppBar(
                      backgroundColor: AppColors.color2,
                      leading: IconButton(
                          onPressed: clearReel,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.color3,
                          )),
                      title: const Text(
                        'New Reel',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      centerTitle: false,
                      actions: [
                        TextButton(
                            onPressed: () {
                              // logic to post video to firebase database
                              postReelToDatabase(
                                  user!.uid, user.username, user.photoUrl);
                            },
                            child: const Text(
                              'Post',
                              style: TextStyle(
                                  color: AppColors.color3,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ))
                      ],
                    ),
                    body: SingleChildScrollView(
                        child: Column(
                      children: [
                        _isLoading
                            ? const LinearProgressIndicator(
                                color: AppColors.color3,
                              )
                            :
                            // space for video
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 15, bottom: 15),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.75,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15)),
                                  width: double.infinity,
                                  child: _videoPlayerController != null
                                      ? AspectRatio(
                                          aspectRatio: 16 /
                                              9, // Set aspect ratio to 16:9
                                          child: VideoPlayer(
                                              _videoPlayerController!),
                                        )
                                      : Container(),
                                ),
                              ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: CircleAvatar(
                                radius: 22.5,
                                backgroundImage: NetworkImage(user!.photoUrl),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.035,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.76,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors
                                      .grey, // Set the color of the border
                                  width: 1.0, // Set the width of the border
                                ),
                                borderRadius: BorderRadius.circular(
                                    8.0), // Set the border radius
                              ),
                              child: TextField(
                                controller: _reelCaptionController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  border: InputBorder
                                      .none, // Remove the default border of TextField
                                  hintText: 'Add a caption...',
                                  contentPadding: EdgeInsets.all(
                                      8.0), // Adjust content padding as needed
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )),
                  );
  }
}
