import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  static String _userID = "USER_ID";
  static String _isLoggedIn = "IS_LOGGED_IN";

  static void logoutUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  static void saveUserID(String userID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userID, userID);
  }

  static void saveLogIn(bool isLogIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isLoggedIn, isLogIn);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isLoggedIn) ?? false;
  }

  static Future<String> getUserID() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_userID);
  }

  static Future<DataSnapshot> getUserData(String uid) async {
    DatabaseReference _userRef =
        FirebaseDatabase.instance.reference().child('users');

    var data = await _userRef.child(uid).get();
    return data;
  }

  static Future<bool> isRegistered(String number) async {

var val = false;
    var users = await FirebaseDatabase.instance
        .reference()
        .child("users")
        .once();

    Map<dynamic, dynamic> userData = await users.value;

    userData.forEach((key, value) {
      if (number == value['phone'].toString()) {
        val = true;
      }

    });

    return val;
    /* FirebaseDatabase.instance
        .reference()
        .child("users")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> users = snapshot.value;

      users.forEach((key, value) {
        if (number == value['phone'].toString()) {}
      });
    }); */
  }

  static Future<bool> updateUserData(
      String uid, Map<String, dynamic> userData) async {
    DatabaseReference _userRef =
        FirebaseDatabase.instance.reference().child('users');

    await _userRef.child(uid).update(userData);
    return true;
  }
}
