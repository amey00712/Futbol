import 'package:flutter/material.dart';
import 'package:newsFlutter/Utils/AuthService.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/Constants.dart';
import 'package:newsFlutter/Utils/User.dart' as UserData;
import 'package:newsFlutter/Utils/Widgets.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:app_settings/app_settings.dart';

import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  var name = "";
  var email = "";
  var profImg = "";
  var type = "";
  var phone = "";
  var isFetched = false;
  var switchValue = false;
  AuthService _authService = new AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //this.setSwitch();
    UserData.User.getUserID().then((value) {
      UserData.User.getUserData(value).then((data) {
        setState(() {
          this.isFetched = true;
          this.name = data.value["name"];
          this.email = data.value["email"];
          this.profImg = data.value["photo"];
          this.type = data.value["loggedInVia"];
          this.phone = data.value["phone"];
          this.switchValue = data.value["allowPromotionalEmail"];
        });
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //this.setSwitch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: nav_bar_color,
        centerTitle: true,
        title: Text('Profile'),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 15,
            ),
            child: GestureDetector(
              onTap: () {
                this.logoutUser(context);
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: this.isFetched
          ? this.type == "phone"
              ? mobileScreen()
              : socialScreen()
          : Container(),
    );
  }

  Widget mobileScreen() {
    return Container(
      margin: EdgeInsets.only(left: 40, right: 40, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.person_rounded,
              size: 100,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          text("Full Name"),
          SizedBox(height: 10),
          this.getTF(this.name ?? ""),
          SizedBox(height: 20),
          text("Mobile No."),
          SizedBox(height: 10),
          this.getTF(this.phone ?? ""),
          this.notificationView(),
        ],
      ),
    );
  }

  Widget notificationView() {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text("Promotional Emails",
                textColor: nav_bar_color, fontWeight: FontWeight.bold),
            Switch(
                value: this.switchValue,
                onChanged: (val) {
                  // AppSettings.openNotificationSettings();
                  this.switchValue = val;

                  UserData.User.getUserID().then((value) {
                    _authService.updatePromotionalSwitch(value, val);
                    setState(() {});
                  });
                }),
          ],
        ),
      ],
    );
  }

  void setSwitch() {
    setState(() {
      this.getCheckNotificationPermStatus().then((value) {
        this.switchValue = value;
      });
    });
  }

  Future<bool> getCheckNotificationPermStatus() {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return false;
        case PermissionStatus.granted:
          return true;
        case PermissionStatus.unknown:
          return false;
        default:
          return null;
      }
    });
  }

  Widget socialScreen() {
    return Stack(
      children: <Widget>[
        Center(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 40, right: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  this.getImage(),
                  this.getFullName(),
                  SizedBox(height: 20),
                  text("Email"),
                  SizedBox(height: 10),
                  this.getTF(this.email ?? ""),
                  this.notificationView(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getFullName() {
    if (this.type != "apple") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          text("Full Name"),
          SizedBox(height: 10),
          this.getTF(this.name ?? ""),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget getImage() {
    var link = this.profImg;

    if (this.type == "facebook") {
      link = link + "?width=140&height=140";
    }
    return Align(
      alignment: Alignment.center,
      child: this.profImg != ""
          ? CircleAvatar(
              radius: 70,
              backgroundColor: nav_bar_color,
              backgroundImage: NetworkImage(link),
            )
          : Icon(
              Icons.person_rounded,
              size: 100,
              color: Colors.grey,
            ),
    );
  }

  Widget getTF(String text) {
    return Container(
      decoration:
          boxDecoration(radius: 40, showShadow: true, bgColor: t2_white),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController()..text = text,
        style: TextStyle(
            fontSize: textSizeMedium,
            fontFamily: fontRegular,
            color: Colors.grey),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(24, 18, 24, 18),
          // hintText: hintText,
          filled: true,
          fillColor: t2_white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: t2_white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: t2_white, width: 0.0),
          ),
        ),
      ),
    );
  }

  logoutUser(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {},
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        UserData.User.logoutUser();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Are you sure you want to log out?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
