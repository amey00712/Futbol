import 'package:flutter/material.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/Constants.dart';
import 'package:newsFlutter/Utils/User.dart';
import 'package:newsFlutter/Utils/Widgets.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'OtpScreen.dart';

class MobileLoginScreen extends StatefulWidget {
  @override
  _MobileLoginScreenState createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _mobileController = new TextEditingController();

  var _showNameField = false;
  var _isValidated = false;
  var _selectedCountry = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: nav_bar_color,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                CountryCodePicker(
                    onChanged: (val) {
                      _selectedCountry = val.toString();
                      print(_selectedCountry);
                    },
                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                    initialSelection: 'IN',
                    showFlagDialog: true,
                    comparator: (a, b) => b.name.compareTo(a.name),
                    //Get the country information relevant to the initial selection
                    onInit: (code) {
                      _selectedCountry = code.dialCode;
                    }),
                Expanded(
                  child: T9EditTextStyle("Mobile no.", _mobileController,
                      TextInputType.number, _showNameField ? true : false,
                      isPassword: false),
                ),
              ],
            ),
            if (_showNameField) this.notRegisteredUI(),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 150,
                alignment: Alignment.center,
                child: T9Button(
                  onPressed: () {
                    if (_mobileController.text == appleNumber) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpScreen(
                            mobNumber: _mobileController.text,
                            fullName: "",
                            selectedCountryCode: _selectedCountry,
                          ),
                        ),
                      );
                    } else {
                      if (_isValidated) {
                        if (_nameController.text.length < 3) {
                          showAlertDialog(
                              "Please enter a valid name.", context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(
                                mobNumber: _mobileController.text,
                                fullName: _nameController.text,
                                selectedCountryCode: _selectedCountry,
                              ),
                            ),
                          );
                        }
                      } else {
                        if (_mobileController.text.length > 9) {
                          User.isRegistered(_mobileController.text)
                              .then((value) {
                            if (!value) {
                              setState(() {
                                _showNameField = true;
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                    mobNumber: _mobileController.text,
                                    fullName: "",
                                    selectedCountryCode: _selectedCountry,
                                  ),
                                ),
                              );
                            }
                          });
                          _isValidated = true;
                        } else {
                          showAlertDialog(
                              "Please enter a valid Mobile number.", context);
                        }
                      }
                    }
                  },
                  textContent: "Request OTP",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loginForAppleTester() {}

  Widget notRegisteredUI() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        T9EditTextStyle("Full Name", _nameController, TextInputType.name, false,
            isPassword: false),
      ],
    );
  }
}
