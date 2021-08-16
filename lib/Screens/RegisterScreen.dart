import 'package:flutter/material.dart';
import 'package:newsFlutter/Utils/AuthService.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/Widgets.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  TextEditingController _confirmPassController = new TextEditingController();

  AuthService _authService = new AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(left: 8),
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: nav_bar_color),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 40, right: 40,top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t2_white, width: 4)),
                      child: Image(image: AssetImage('images/logo.png'),),
                    ),
                    SizedBox(height: 10),
                 /*   T9EditTextStyle("Full Name", _nameController,
                        isPassword: false),
                    SizedBox(height: 16),
                    T9EditTextStyle("Email", _emailController,
                        isPassword: false),
                    SizedBox(height: 16),
                    T9EditTextStyle("Password", _passController,
                        isPassword: true),
                    SizedBox(height: 16),
                    T9EditTextStyle("Confirm Password", _confirmPassController,
                        isPassword: true), */
                    SizedBox(height: 50),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 120,
                        alignment: Alignment.center,
                        child: T9Button(
                          onPressed: () {
                            this.checkValidations();
                          },
                          textContent: "Register",
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkValidations() {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this._emailController.text);

    if (_nameController.text.length < 2) {
      showAlertDialog("Please enter a valid Name.", context);
      return;
    }

    if (!emailValid) {
      showAlertDialog("Please enter a valid Email-ID.", context);
      return;
    }

    if (_passController.text.length < 6) {
      showAlertDialog("Password should be min. 6 characters/numbers.", context);
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      showAlertDialog("Entered password doesn't match.", context);
      return;
    }

    this.signUp();
  }

  signUp() {
    _authService
        .signUp(
            _emailController.text, _passController.text, _nameController.text)
        .then((value) {
      if (value == "isSuccess") {
        Navigator.pop(context);
        showAlertDialog(
            "You have registered successfully. Please login to continue.",
            context);
      } else {
        showAlertDialog(value, context);
      }
    });
  }
}
