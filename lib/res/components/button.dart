import 'package:flutter/material.dart';
import 'package:social_media_app_project/res/utils/colors.dart';

class Button extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const Button({Key? key, required this.onTap, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 200,
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.color2,
                    Color.fromARGB(255, 212, 250, 197)
                  ])),
          child: Center(
            child: child,
          )),
    );
  }
}
