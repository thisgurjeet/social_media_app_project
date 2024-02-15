import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app_project/view/edit_profile_view.dart';
import 'package:social_media_app_project/view/home_view.dart';
import 'package:social_media_app_project/view/login_view.dart';
import 'package:social_media_app_project/view/reel_feed_view.dart';
import 'package:social_media_app_project/view_model/user_provider_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyAO5Z3wsHVYAPd1Z429KguwHz9vGxRZtPI',
              appId: '1:438569197251:android:eee6bdfafd86c3bd160c76',
              messagingSenderId: '438569197251',
              projectId: 'social-media-app-705d9',
              storageBucket: 'social-media-app-705d9.appspot.com'))
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            fontFamily: GoogleFonts.lato().fontFamily,
            textTheme: TextTheme(
              displayLarge: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              displayMedium: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              displaySmall: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return const HomeView();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }
              return const LoginView();
            },
          )),
    );
  }
}
