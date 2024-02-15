import 'package:flutter/material.dart';
import 'package:social_media_app_project/res/utils/colors.dart';

class TextEntryField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isObscure;
  final TextInputType keyboardType;
  const TextEntryField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.isObscure = false,
    required this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: AppColors.color4, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 5),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
