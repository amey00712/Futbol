import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:newsFlutter/Utils/User.dart' as UserData;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  /*User userFromFirebase(FirebaseUser user) {
    return user != null ? User(userID: user.uid) : null;
  } */

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }


  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      switch (result.status) {
        case LoginStatus.success:
          final AuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken.token);
          return await FirebaseAuth.instance.signInWithCredential(facebookCredential);

        case LoginStatus.cancelled:
          return null;

        case LoginStatus.failed:
          return null;

        default:
          return null;
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

    Future<String> signIn(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      UserData.User.saveUserID(result.user.uid);

      print(result);
      return "isSuccess";
    } catch (e) {
      print(e);
      if (e.message ==
          "The password is invalid or the user does not have a password.") {
        return "You have entered a wrong Password.";
      } else {
        return "User does not exist. Please register.";
      }
    }
  }

  Future<String> signUp(String email, String password, String name) async {
    DatabaseReference _userRef =
        FirebaseDatabase.instance.reference().child('users');

    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      Map userData = {"name": name, "email": email};

      _userRef.child(result.user.uid).set(userData);

      return "isSuccess";
    } catch (e) {
      print(e.message);
      return e.message;
    }
  }

  /*loginViaPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+919167153542',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } */

  saveDataToDatabase(String uid, String name, String email,String phone ,String photo,String via) {
    DatabaseReference _userRef =
        FirebaseDatabase.instance.reference().child('users');

    Map userData = {"name": name, "email": email, "phone": phone, "photo":photo, "loggedInVia": via};

    _userRef.child(uid).set(userData).then((value) {
      print("success");
    }).catchError((e){
      print(e);
    });
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }
}
