import 'package:flutter/foundation.dart';

class User {
  final String name;
  final String email;
  final String profilePictureUrl;

  User({
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });
}

class UserProvider with ChangeNotifier {
  late User _currentUser;

  User get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
