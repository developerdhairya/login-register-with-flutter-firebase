import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:vartaa_messenger/providers/user_avatar_provider.dart';
import 'package:vartaa_messenger/services/cloud_storage_service.dart';
import 'package:vartaa_messenger/services/firestore_service.dart';
import 'package:vartaa_messenger/services/navigation_service.dart';
import 'package:vartaa_messenger/services/registration_service.dart';
import 'package:vartaa_messenger/services/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

class AuthProvider extends ChangeNotifier {
  late User user;

  AuthStatus? status;

  late FirebaseAuth _auth;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    isUserAuthenticated();
  }

  void _autoLogin() {
    if (status == AuthStatus.Authenticated) {
      NavigationService.instance.navigateToReplacement("/home");
    }
  }

  void isUserAuthenticated() async {
    if (_auth.currentUser != null) {
      user = _auth.currentUser!;
      status = AuthStatus.Authenticated;
      notifyListeners();
      _autoLogin();
    }
  }

  Future<void> loginUserWithEmailAndPassword(
      String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      user = _result.user!;
      status = AuthStatus.Authenticated;
      SnackBarService.instance.showSnackBarSuccess("Welcome,${user.email}");
      //Update Last Seen
      //Navigate to Home Page
    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackBarError("Error Authenticating");
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(
      String _email, String _password, String _username) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      user = await AuthService.instance.registerUser(_email, _password, _username);
      status = AuthStatus.Authenticated;

    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackBarError("Error Authenticating");
    }
    notifyListeners();
  }
}
