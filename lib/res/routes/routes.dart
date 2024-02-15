import 'package:flutter/material.dart';
import 'package:social_media_app_project/res/routes/route_name.dart';
import 'package:social_media_app_project/view/home_view.dart';
import 'package:social_media_app_project/view/login_view.dart';
import 'package:social_media_app_project/view/signup_view.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.login:
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginView());
      case RoutesName.signup:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SignupView());
      case RoutesName.home:
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeView());

      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(child: Text('No Routes')),
          );
        });
    }
  }
}
