import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app_project/res/components/button.dart';
import 'package:social_media_app_project/res/components/text_input_field.dart';

import 'package:social_media_app_project/res/utils/colors.dart';
import 'package:social_media_app_project/view/home_view.dart';
import 'package:social_media_app_project/view/signup_view.dart';
import 'package:social_media_app_project/view_model/auth_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await AuthModel().loginUser(
        email: emailController.text, password: passwordController.text);

    setState(() {
      isLoading = false;
    });
    if (res == 'success') {
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
                          horizontal: 20, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Log in',
                            style: GoogleFonts.lato(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          SizedBox(
                            height: height * 0.35,
                            child: const Image(
                                image:
                                    AssetImage('assets/images/Login-bro.png')),
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
                              hintText: '   Enter your password',
                              isObscure: true,
                              keyboardType: TextInputType.text),
                          SizedBox(
                            height: height * 0.075,
                          ),
                          Button(
                              onTap: () => loginUser(),
                              child: Center(
                                child: isLoading == true
                                    ? const Center(
                                        child: SizedBox(
                                          height: 28,
                                          width: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: AppColors.color3,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Log in',
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
                                      builder: (context) =>
                                          const SignupView()));
                            },
                            child: Container(
                              child: const Text(
                                'Don\'t have an account? Sign up',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
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
