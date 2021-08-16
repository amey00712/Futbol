import 'package:flutter/material.dart';
import 'package:newsFlutter/Screens/DashboardScreen.dart';
import 'dart:async';
import 'package:newsFlutter/Screens/LoginScreen.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/User.dart' as UserData;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //final FirebaseMessaging _messaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 3), () => goToNextScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: nav_bar_color,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.width / 4,
          width: MediaQuery.of(context).size.width / 4,
          child: Image.asset(
            "images/headerImage.png",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<void> goToNextScreen() async {
    UserData.User.isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }
}
