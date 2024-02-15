import 'package:flutter/foundation.dart';
import 'package:social_media_app_project/model/user_model.dart';
import 'package:social_media_app_project/view_model/auth_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  final AuthModel _authModel = AuthModel();
  User? get getUser => _user;

  // refresh user to manage states
  Future<void> refreshUser() async {
    User? user = await _authModel.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
