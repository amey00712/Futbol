import 'package:flutter/material.dart';
import 'package:newsFlutter/Screens/DashboardScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/User.dart' as UserData;
import 'package:newsFlutter/Utils/AuthService.dart';

class OtpScreen extends StatefulWidget {
  final String mobNumber;
  final String fullName;
  final String selectedCountryCode;

  OtpScreen({this.mobNumber, this.fullName,this.selectedCountryCode});

  @override
  _OtpViewState createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpScreen> {
  var verificationID = "";
  FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService _authService = new AuthService();

  TextEditingController _firstController = new TextEditingController();
  TextEditingController _secondController = new TextEditingController();
  TextEditingController _thirdController = new TextEditingController();
  TextEditingController _fourthController = new TextEditingController();
  TextEditingController _fifthController = new TextEditingController();
  TextEditingController _sixthController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.loginViaPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xfff7f6fb),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                'Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Enter your OTP code number",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 28,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _textFieldOTP(_firstController,
                            first: true, last: false),
                        _textFieldOTP(_secondController,
                            first: false, last: false),
                        _textFieldOTP(_thirdController,
                            first: false, last: false),
                        _textFieldOTP(_fourthController,
                            first: false, last: false),
                        _textFieldOTP(_fifthController,
                            first: false, last: false),
                        _textFieldOTP(_sixthController,
                            first: false, last: true),
                      ],
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          this.validateOtp();
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(nav_bar_color),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text(
                            'Verify',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              /*   SizedBox(
                height: 18,
              ),
              Text(
                "Didn't you receive any code?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                "Resend New Code",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ), */
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldOTP(TextEditingController tf, {bool first, last}) {
    return Container(
      height: 60,
      width: 50,
      child: TextField(
        controller: tf,
        autofocus: true,
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.length == 0 && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
        showCursor: false,
        readOnly: false,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counter: Offstage(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.black12),
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: nav_bar_color),
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  loginViaPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "${widget.selectedCountryCode}${widget.mobNumber}",
      verificationCompleted: (PhoneAuthCredential credential) {
        print(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verificationId, int resendToken) {
        this.verificationID = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  validateOtp() {
    var otp =
        "${_firstController.text}${_secondController.text}${_thirdController.text}${_fourthController.text}${_fifthController.text}${_sixthController.text}";

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: this.verificationID, smsCode: otp);

    _auth.signInWithCredential(credential).then((value) {
      if (widget.fullName != "") {
        _authService.saveDataToDatabase(
            value.user.uid, widget.fullName, "", widget.mobNumber, "", "phone");
      }

      UserData.User.saveLogIn(true);
      UserData.User.saveUserID(value.user.uid);
      this.moveToNextScreen(context);
    }).catchError((e) {});
  }

  // action to be performed after OTP validation is success
  void moveToNextScreen(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DashboardScreen()));
  }
}
