import 'package:flutter/material.dart';
import 'package:newsFlutter/Models/SideMenuModel.dart';
import 'package:newsFlutter/Utils/ApiManager.dart';
import 'package:newsFlutter/Utils/Constants.dart';
import 'package:newsFlutter/Utils/Widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class T2Drawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return T2DrawerState();
  }
}

class T2DrawerState extends State<T2Drawer> {
  var selectedItem = -1;
  List<SideMenuModel> menuList = new List<SideMenuModel>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      child: Drawer(
        elevation: 8,
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.only(top: 20),
          child: ListView.builder(
            itemCount: this.menuList == null ? 0 : menuList.length,
            itemBuilder: (context, i) {
              return getDrawerItem(
                  this.menuList[i].web_img, this.menuList[i].web_title, i);
            },
          ),
        ),
      ),
    );
  }

  void callAPI() async {
    final res = await ApiManager().get("getweblinks.php");

    if (res["status"] == "true") {
      setState(() {
        res["data"].forEach((data) => {
              this.menuList.add(SideMenuModel.fromJSON(data)),
            });
      });
    }
  }

  Widget getDrawerItem(String icon, String name, int pos) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = pos;
        });
      },
      child: Container(
        //color: selectedItem == pos ? t2_colorPrimaryLight : t2_white,
        color: Colors.black,
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: this.displayAccordingly(name, icon,pos),
      ),
    );
  }

  void sendMail(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print("error");
    }
  }

  Widget displayAccordingly(String title, String img,int i) {
    if (title == "" && img != "") {
      return GestureDetector(
        onTap: (){

          this.sendMail(menuList[i].web_link);


        },
        child: Container(
            width: 40,
            height: 40,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Image.network(
                  img,
                  color: Colors.white,
                ))),
      );
    } else if (title != "" && img != "") {
      if (title.contains("@")) {
        return GestureDetector(
            onTap: () {
              this.sendMail("mailto:support@futbolfirst.net");
            },
            child:Row(
              children: <Widget>[
                // SvgPicture.asset(icon, width: 20, height: 20),
            Align(
            alignment: Alignment.centerLeft,
              child: Icon(
                Icons.email,
                color: Colors.white,
                size: 35,
              ),),
                SizedBox(width: 10),
                text(title,
                    textColor: Colors.white,
                    fontSize: textSizeLargeMedium,
                    fontFamily: fontMedium)

                //  text(name, textColor: selectedItem == pos ? t2_colorPrimary : t2TextColorPrimary, fontSize: textSizeLargeMedium, fontFamily: fontMedium)
              ],
            ),
        );
      } else {
        return text(
          title,
          textColor: Colors.white,
          fontSize: 30.0,
          fontFamily: 'Vanguard',
        );
      }
    } else {
      return Row(
        children: <Widget>[
          // SvgPicture.asset(icon, width: 20, height: 20),
          Container(
              width: 35,
              height: 35,
              child: Image.network(
                img,
                fit: BoxFit.fill,
              )),
          SizedBox(width: 20),
          text(title,
              textColor: Colors.white,
              fontSize: textSizeLargeMedium,
              fontFamily: fontMedium)

          //  text(name, textColor: selectedItem == pos ? t2_colorPrimary : t2TextColorPrimary, fontSize: textSizeLargeMedium, fontFamily: fontMedium)
        ],
      );
    }
  }
}
