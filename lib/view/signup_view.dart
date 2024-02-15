import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app_project/res/components/button.dart';
import 'package:social_media_app_project/res/components/text_input_field.dart';
import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view/home_view.dart';
import 'package:social_media_app_project/view/login_view.dart';
import 'package:social_media_app_project/view_model/auth_model.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  Uint8List? image;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // function to pick image
  selectImage() async {
    Uint8List im = await AuthModel().pickImage(ImageSource.gallery);
    setState(() {
      image = im;
    });
  }

  void signupUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await AuthModel().signupUser(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        bio: bioController.text,
        file: image!);
    setState(() {
      isLoading = false;
    });
    if (res != 'success') {
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          decoration: const BoxDecoration(color: AppColors.color4),
          child: Stack(
            children: [
              Positioned(
                top: height * 0.20, // Adjust this value to move the widget down
                left: 0.0,
                right: 0.0,
                child: Container(
                  height: height,
                  width: double
                      .infinity, // Set the height of the positioned container
                  decoration: BoxDecoration(
                      color: AppColors.color3,
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Sign up',
                            style: GoogleFonts.lato(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          SizedBox(
                            height: height * 0.05,
                          ),
                          // image
                          Center(
                            child: Stack(
                              children: [
                                image != null
                                    ? CircleAvatar(
                                        radius: 45,
                                        backgroundImage: MemoryImage(image!),
                                      )
                                    : ClipOval(
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundColor: Colors
                                              .white, // Set the background color to match the filter color
                                          child: ColorFiltered(
                                            colorFilter: const ColorFilter.mode(
                                              AppColors
                                                  .color2, // Replace with the color you want
                                              BlendMode
                                                  .color, // You can use different blend modes
                                            ),
                                            child: Image.asset(
                                                'assets/images/user.png'),
                                          ),
                                        ),
                                      ),
                                Positioned(
                                  bottom: -10,
                                  left: 55,
                                  child: IconButton(
                                    onPressed: () {
                                      selectImage();
                                    },
                                    icon: const Icon(
                                      Icons.add_a_photo,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.045,
                          ),
                          TextEntryField(
                              controller: usernameController,
                              hintText: '   Create a username',
                              keyboardType: TextInputType.text),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          TextEntryField(
                              controller: emailController,
                              hintText: '   Enter your email',
                              keyboardType: TextInputType.emailAddress),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          TextEntryField(
                              controller: passwordController,
                              hintText: '   Create a password',
                              isObscure: true,
                              keyboardType: TextInputType.visiblePassword),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          TextEntryField(
                              controller: bioController,
                              hintText: '   Add a bio',
                              keyboardType: TextInputType.text),
                          SizedBox(
                            height: height * 0.1,
                          ),
                          Button(
                              onTap: () => signupUser(),
                              child: Center(
                                child: isLoading == true
                                    ? const Center(
                                        child: SizedBox(
                                            height: 28,
                                            width: 28,
                                            child: CircularProgressIndicator(
                                              color: AppColors.color3,
                                            )),
                                      )
                                    : const Text(
                                        'Sign up',
                                        style: TextStyle(
                                            color: AppColors.color3,
                                            fontSize: 17),
                                      ),
                              )),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginView()));
                            },
                            child: const Text(
                              'Already have an account? Login',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
