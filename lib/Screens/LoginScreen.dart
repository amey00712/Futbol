import 'dart:io';
import 'package:flutter/material.dart';
import 'package:newsFlutter/Screens/DashboardScreen.dart';
import 'package:newsFlutter/Screens/MobileLoginScreen.dart';
import 'package:newsFlutter/Utils/AuthService.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/User.dart';
import 'package:newsFlutter/Utils/Widgets.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthService _authService = new AuthService();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  checkValidations() {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this._emailController.text);

    if (!emailValid) {
      showAlertDialog("Please enter a valid Email-ID.", context);
    } else if (_passwordController.text.length < 4) {
      showAlertDialog("Please enter a valid Password.", context);
    } else {
      this.signIn();
    }
  }

  signIn() {
    _authService
        .signIn(_emailController.text, _passwordController.text)
        .then((value) {
      if (value == "isSuccess") {
        User.saveLogIn(true);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        showAlertDialog(value, context);
      }
    });
  }

  signInWithGoogle() async {
    var _userData = await _authService.signInWithGoogle();

    if (_userData != null) {
      _authService.saveDataToDatabase(
          _userData.user.uid,
          _userData.user.displayName,
          _userData.user.email,
          "",
          _userData.user.photoURL,
          "google");
      User.saveLogIn(true);
      User.saveUserID(_userData.user.uid);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    }
  }

  signInWithFacebook() async {
    var _userData = await _authService.signInWithFacebook();

    if (_userData != null) {
      print(_userData);
      _authService.saveDataToDatabase(
          _userData.user.uid,
          _userData.user.displayName,
          _userData.user.email,
          "",
          _userData.user.photoURL,
          "facebook");
      User.saveLogIn(true);
      User.saveUserID(_userData.user.uid);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    }
  }

  signInWithApple() async {
    var _userData = await _authService.signInWithApple();

    if (_userData != null) {
      _authService.saveDataToDatabase(
          _userData.user.uid,
          _userData.user.displayName,
          _userData.user.email,
          "",
          _userData.user.photoURL,
          "apple");
      User.saveLogIn(true);
      User.saveUserID(_userData.user.uid);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t2_white, width: 4)),
              child: Image(
                image: AssetImage('images/logo.png'),
              ),
            ),
            if (Platform.isIOS)
              GestureDetector(
                onTap: () {
                  this.signInWithApple();
                },
                child: this.getLoginRows("Apple", "images/appleIcon.png"),
              ),
            GestureDetector(
                onTap: () {
                  this.signInWithGoogle();
                },
                child: this.getLoginRows("Google", "images/googleIcon.png")),
            GestureDetector(
                onTap: () {
                  this.signInWithFacebook();
                },
                child:
                    this.getLoginRows("Facebook", "images/facebookIcon.png")),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MobileLoginScreen()));
                },
                child: this.getLoginRows("Phone Number", "images/phoneIcon.png")),
          ],
        ),
      ),
    );
  }

  Widget getLoginRows(String title, String img) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: nav_bar_color, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 18),
            child: Container(
              height: 30,
              width: 30,
              child: Image(
                image: AssetImage(img),
              ),
            ),
          ),
          text("Sign in with $title", textColor: nav_bar_color,fontSize: 15.0,fontWeight: FontWeight.bold),
          Container(
            width: 32,
          ),
        ],
      ),
    );
  }
}
