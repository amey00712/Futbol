import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsFlutter/Models/DashboardModel.dart';
import 'package:newsFlutter/Screens/DetailScreen.dart';
import 'package:newsFlutter/Screens/ProfileScreen.dart';
import 'package:newsFlutter/Screens/SideMenu.dart';
import 'package:newsFlutter/Screens/VideoPlayer.dart';
import 'package:newsFlutter/Utils/AdManager.dart';
import 'package:newsFlutter/Utils/ApiManager.dart';
import 'package:newsFlutter/Utils/BannerAdWidget.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/Constants.dart';
import 'package:newsFlutter/Utils/User.dart';
//import 'package:newsFlutter/Utils/RemoteConfigService.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:newsFlutter/Utils/BottomBar.dart';
import 'package:newsFlutter/Utils/SliderWidget.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List homeData;
  List articlesData;
  List videosData;
  List transverseData;
  String headerImage;
  TabController _tabController;
  var showBannerAd = false;
  var showVideoAd = false;
  var showNativeAd = false;
  var showNewDesign = false;
  var isUnderMaintainance = false;

  var adClicks = "";
  var profImg = "";

  GenThumbnailImage futureImage;
  int selectedIndex = 0;

  List<SliderModel> sliders = new List<SliderModel>();

  var counter = 0;

  RemoteConfig _remoteConfig = RemoteConfig.instance;

  void getRemoteConfigInstance() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(seconds: 1),
    ));
    await _remoteConfig.fetchAndActivate();

    this.showBannerAd = _remoteConfig.getBool('showBannerAd');
    this.showVideoAd = _remoteConfig.getBool('showVideoAd');
    this.showNativeAd = _remoteConfig.getBool('showNativeAd');
    this.showNewDesign = _remoteConfig.getBool('showNewDesign');
    this.adClicks = _remoteConfig.getString("adClicks");
    this.isUnderMaintainance = _remoteConfig.getBool('isUnderMaintainance');
  }

  void initVideoAd(bool click) {
    if (showVideoAd) {
      if (click) {
        counter = counter + 1;
      }

      if (counter % int.parse(this.adClicks) == 0) {
        //    RewardedVideoAd.instance.show();
      } else {
        //   RewardedVideoAd.instance.load(adUnitId: RewardedVideoAd.testAdUnitId);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // FirebaseAdMob.instance.initialize(appId: AdManager.appId);

    WidgetsBinding.instance.addObserver(this);

    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();

    this.getRemoteConfigInstance();

    _tabController = new TabController(length: 4, vsync: this);
    _tabController.addListener(_setActiveTabIndex);

    this.callAPI();

    User.getUserID().then((value) {
      User.getUserData(value).then((data) {
        setState(() {
          this.profImg = data.value["photo"];
        });
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print('Application paused');
        break;
      case AppLifecycleState.resumed:
        print('Application resume');
        print(isFromPushNotification);
        if (isFromPushNotification) {
          print("Push notification ID: $pushNotificationID");
          print("Push notification type: $pushNotificationType");
          this.getPushNotificationData(
              pushNotificationID, pushNotificationType);
        }
        break;
      case AppLifecycleState.detached:
        print('Application detached');
        break;
      case AppLifecycleState.inactive:
        print('Application inactive');
        break;
    }
  }

  void getPushNotificationData(String id, String type) {
    this.callAPI();

    var dataArr = [];

    if (type == "data") {
      dataArr = this.homeData;
    } else if (type == "article") {
      dataArr = this.articlesData;
    } else if (type == "videos") {
      dataArr = this.videosData;
    } else if (type == "transverse") {
      dataArr = this.transverseData;
    } else {
      for (int i = 0; i < sliders.length; i++) {
        dataArr[i]["files_id"] = sliders[i].files_id;
        dataArr[i]["files_content"] = sliders[i].files_content;
        dataArr[i]["files_name"] = sliders[i].files_name;
        dataArr[i]["files_thumb"] = sliders[i].files_thumb;
        dataArr[i]["files_title"] = sliders[i].files_title;
        dataArr[i]["files_type"] = sliders[i].files_type;
        dataArr[i]["post_appurl"] = sliders[i].post_appurl;
      }
    }

    for (int i = 0; i < dataArr.length; i++) {
      print(dataArr[i]["files_id"]);

      if (id == dataArr[i]["files_id"]) {
        if (dataArr[i]["files_type"] == "vid") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoApp(
                  url: dataArr[i]["files_name"],
                ),
              ));
        } else {
          this.moveToDetailScreen(
              dataArr[i]["files_content"], dataArr[i]["files_thumb"]);
        }
      }
    }
  }

  void _setActiveTabIndex() {
    setState(() {
      selectedIndex = _tabController.index;
    });
  }

  Future<void> refreshList() async {
    setState(() {
      this.callAPI();
    });

    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
    final tabs = [
      homeWidget(),
      articleWidget(),
      videoWidget(),
      transverseWidget(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 15,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              child: getImg(),
            ),
          ),
        ],
        title: Container(
          height: 46,
          width: 38,
          child: Image.asset(
            "images/headerImage.png",
            fit: BoxFit.fill,
          ),
        ),
        backgroundColor: nav_bar_color,
      ),
      body: this.isUnderMaintainance == true
          ? Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_gmailerrorred_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                  Text(
                    'The app is currently undergoing maintenance.',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Container(
              color: background_color,
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: tabs,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BubbleBottomBar(
                      backgroundColor: Colors.transparent,
                      opacity: .4,
                      currentIndex: selectedIndex,
                      elevation: 8,
                      onTap: (index) {
                        setState(() {
                          selectedIndex = index;
                          _tabController.index = selectedIndex;
                        });
                      },
                      //new
                      // hasNotch: false,
                      //new
                      //  hasInk: true,
                      //new, gives a cute ink effect
                      inkColor: nav_bar_color,
                      //optional, uses theme color if not specified
                      items: <BubbleBottomBarItem>[
                        tab("images/homeIcon.png", "Home"),
                        tab("images/newsIcon.png", "News"),
                        tab("images/videoIcon.png", "Videos"),
                        tab("images/transferIcon.png", "Transfers"),
                      ],
                    ),
                  ),

                  // if (!bannerIsLoaded)
                  if (showBannerAd)
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        child: BannerAdWidget(AdSize.banner),
                      ),
                    ),
                ],
              ),
            ),
      drawer: T2Drawer(),
    );
  }

  Widget getImg() {
    if (this.profImg != "") {
      return CircleAvatar(
        radius: 15,
        backgroundColor: nav_bar_color,
        backgroundImage: NetworkImage(this.profImg),
      );
    } else {
      return Icon(Icons.person_rounded);
    }
  }

  void callAPI() async {
    final res = await ApiManager().get("getfiles.php");

    if (res["status"] == "true") {
      setState(() {
        this.homeData = res["data"];
        this.articlesData = res["article"];
        this.videosData = res["videos"];
        this.transverseData = res["transverse"];

        sliders = new List<SliderModel>();

        for (int i = 0; i < res["header"].length; i++) {
          this.sliders.add(SliderModel.fromJSON(res["header"][i]));
        }
      });
    }
  }

  Widget homeWithHeaderImage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            height: MediaQuery.of(context).size.height / 2 - 20,
            child: this.headerImage == null
                ? Image.network("")
                : Image.network(
                    headerImage,
                    fit: BoxFit.cover,
                  ),
          ),
          homeWidget(),
        ],
      ),
    );
  }

  Widget homeWidget() {
    return getHomeBody();
  }

  Widget getHomeHeaderView() {
    if (sliders.length != 0) {
      return T5SliderWidget(sliders);
    } else {
      return Container();
    }
  }

  Widget getHomeBody() {
    return Container(
      padding: EdgeInsets.only(bottom: 50),
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: ListView.builder(
            itemCount: homeData == null ? 0 : homeData.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return getHomeHeaderView();
              } else {
                return Padding(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                  child: this.homeData[index - 1]["files_type"] == "himg" ||
                          this.homeData[index - 1]["files_type"] == "hvid"
                      ? this.getHeaderImg(
                          this.homeData[index - 1]["files_thumb"],
                          this.homeData[index - 1]["files_name"],
                          this.homeData[index - 1]["files_title"],
                          this.homeData[index - 1]["files_content"],
                          this.homeData[index - 1]["files_type"],
                          this.homeData[index - 1]["post_srcimg"],
                          this.homeData[index - 1]["post_appurl"])
                      : this.getHomeContainer(
                          this.homeData[index - 1]["files_type"],
                          this.homeData[index - 1]["files_name"],
                          this.homeData[index - 1]["files_title"],
                          this.homeData[index - 1]["files_content"],
                          this.homeData[index - 1]["files_thumb"],
                          this.homeData[index - 1]["post_srcimg"],
                          this.homeData[index - 1]["post_appurl"]),
                );
              }
            }),
      ),
    );
  }

  double getHeightAccordingly() {
    var height = MediaQuery.of(context).size.height;

    if (height < 1020) {
      return height / 2 - 140;
    } else if (height >= 1020) {
      return height / 2 - 100;
    } else {
      return 290;
    }
  }

  void showVideoAdd() {
    counter = counter + 1;

    /*  if (counter % 4 == 0) {
      RewardedVideoAd.instance.show();
    } else {
      RewardedVideoAd.instance.load(adUnitId: RewardedVideoAd.testAdUnitId);
    } */
  }

  void moveToDetailScreen(String content, String img) {
    // this.disposeBannerAd();
    // this.initVideoAd(true);

    //this.showVideoAdd();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailScreen(
                  htmlData: content,
                  imgLink: img,
                  showAd: this.showNativeAd,
                ))).then((value) {
      // this.initBannerAd(adWidget: adWidget);
    });
  }

  BoxFit getImageType() {
    return BoxFit.contain;
  }

  Widget getHeaderImg(String thumb, String img, String name, String content,
      String type, String creditImg, String link) {
    return GestureDetector(
      onTap: () {
        if (link != "") {
          launch(link);
        } else {
          if (type != "himg") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoApp(
                          url: img,
                        )));
          } else {
            this.moveToDetailScreen(content, img);
          }
        }
      },
      child: Container(
        height: 300,
        margin: EdgeInsets.only(top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return Container(
                    height: 300,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            thumb == "" ? img : thumb,
                            fit: getImageType(),
                          ),
                        ),
                        if (type != "himg")
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 95,
              padding: EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (creditImg != "")
                    Container(
                      height: 23,
                      child: Image.network(
                        creditImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (creditImg != "")
                    SizedBox(
                      height: 5,
                    ),
                  Text(name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: text_color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getHomeContainer(String type, String imgStr, String text,
      String content, String thumbImg, String creditImg, String link) {
    if (type == "Article" || type == "Transverse") {
      return getImageContainerForHome(
          thumbImg, imgStr, text, content, creditImg, link);
    } else if (type == "vid") {
      return getHomeVideoContainer(thumbImg, imgStr, text, creditImg, link);
    } else if (type == "evid") {
      return getHomeEvidContainer(imgStr, text, thumbImg);
    } else {
      return getImageContainer("", imgStr, text, content, false);
    }
  }

  Widget getImageContainerForHome(String thumbImg, String imgStr, String text,
      String content, String creditImg, String link) {
    return GestureDetector(
      onTap: () {
        if (link != "") {
          launch(link);
        } else {
          this.moveToDetailScreen(content, imgStr);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.width / 3,
        //color: Colors.white,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: background_color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            this.detailText(text, creditImg),
            Container(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.width / 3,
                padding: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    thumbImg == "" ? imgStr : thumbImg,
                    fit: BoxFit.cover,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 600 ? 'phone' : 'tablet';
  }

  double getFontSize() {
    if (getDeviceType() == "phone") {
      return 18;
    } else {
      return 24;
    }
  }

  Widget detailText(String text, String creditImg) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (creditImg != "")
              Container(
                color: Colors.green,
                height: 20,
                child: Image.network(
                  creditImg,
                  fit: BoxFit.cover,
                ),
              ),
            if (creditImg != "")
              SizedBox(
                height: 5,
              ),
            Text(text,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(
                    fontSize: getFontSize(),
                    fontWeight: FontWeight.bold,
                    color: text_color)),
          ],
        ),
      ),
    );
  }

  Widget headerText(String text) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: text_color)),
      ),
    );
  }

  Widget getHomeVideoContainer(String thumbImg, String imgStr, String text,
      String creditImg, String link) {
    final dim = MediaQuery.of(context).size.width / 3;

    return GestureDetector(
      onTap: () {
        if (link != "") {
          launch(link);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoApp(
                  url: imgStr,
                ),
              ));
        }
      },
      child: Container(
        height: dim,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: background_color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            this.detailText(text, creditImg),
            Container(
              height: dim,
              width: dim,
              padding: EdgeInsets.all(5),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        thumbImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getHomeEvidContainer(String imgStr, String text, String thumbImg) {
    final dim = MediaQuery.of(context).size.width / 3;

    return Center(
      child: GestureDetector(onTap: () {
        this.moveToDetailScreen(imgStr, "");
      }, child: Container(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: constraints.maxWidth,
                      width: constraints.maxWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          thumbImg,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ],
                ),
                descText(text),
              ],
            );
          },
        ),
      )),
    );
  }

  Widget getEvidContainer(
      String imgStr, String text, String content, bool showText) {
    return Center(
      child: GestureDetector(
        onTap: () {
          this.moveToDetailScreen(content, "");
        },
        child: Container(

            // height: MediaQuery.of(context).size.width / 3 ,
            // width: MediaQuery.of(context).size.width ,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Image.network(
                    imgStr,
                    fit: BoxFit.cover,
                  ),
                ),
                showText == false ? Text("") : descText(text),
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget articleWidget() {
    if (showNewDesign == true) {
      return articleNew();
    } else {
      return articleOld();
    }
  }

  Widget articleOld() {
    final double itemHeight = 200;
    final double itemWidth = MediaQuery.of(context).size.width / 3;

    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 50),
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: GridView.builder(
          // physics: NeverScrollableScrollPhysics(),
          // shrinkWrap: true,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
              childAspectRatio: (itemWidth / itemHeight)),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, index) {
            return this.getVideoWidget(
              this.articlesData[index]["files_type"],
              this.articlesData[index]["files_name"],
              this.articlesData[index]["files_title"],
              this.articlesData[index]["files_content"],
              this.articlesData[index]["files_thumb"],
            );
          },
          itemCount: this.articlesData == null ? 0 : this.articlesData.length,
        ),
      ),
    );
  }

  Widget articleNew() {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Container(
      padding: EdgeInsets.only(bottom: 50),
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: ListView.builder(
            itemCount: articlesData == null ? 0 : articlesData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: this.articlesData[index]["files_type"] == "himg" ||
                        this.articlesData[index]["files_type"] == "hvid"
                    ? this.getHeaderImg(
                        this.articlesData[index]["files_thumb"],
                        this.articlesData[index]["files_name"],
                        this.articlesData[index]["files_title"],
                        this.articlesData[index]["files_content"],
                        this.articlesData[index]["files_type"],
                        this.articlesData[index]["post_srcimg"],
                        this.articlesData[index]["post_appurl"])
                    : this.getHomeContainer(
                        this.articlesData[index]["files_type"],
                        this.articlesData[index]["files_name"],
                        this.articlesData[index]["files_title"],
                        this.articlesData[index]["files_content"],
                        this.articlesData[index]["files_thumb"],
                        this.articlesData[index]["post_srcimg"],
                        this.articlesData[index]["post_appurl"]),
              );
            }),
      ),
    );
  }
  /* Widget articleWidget() {
    /* final double itemHeight = 200;
    final double itemWidth = MediaQuery.of(context).size.width / 3; */

    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Container(
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: ListView.builder(
            itemCount: articlesData == null ? 0 : articlesData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: this.articlesData[index]["files_type"] == "himg" ||
                        this.articlesData[index]["files_type"] == "hvid"
                    ? this.getHeaderImg(
                        this.articlesData[index]["files_thumb"],
                        this.articlesData[index]["files_name"],
                        this.articlesData[index]["files_title"],
                        this.articlesData[index]["files_content"],
                        this.articlesData[index]["files_type"],
                        this.articlesData[index]["post_srcimg"],
                        this.articlesData[index]["post_appurl"])
                    : this.getHomeContainer(
                        this.articlesData[index]["files_type"],
                        this.articlesData[index]["files_name"],
                        this.articlesData[index]["files_title"],
                        this.articlesData[index]["files_content"],
                        this.articlesData[index]["files_thumb"],
                        this.articlesData[index]["post_srcimg"],
                        this.articlesData[index]["post_appurl"]),
              );
            }),
      ),
    );
  } */

  Widget getImageContainer(String thumbImg, String imgStr, String text,
      String content, bool showText) {
    return Center(
      child: GestureDetector(
        onTap: () {
          this.moveToDetailScreen(content, imgStr);
        },
        child: Container(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      thumbImg == "" ? imgStr : thumbImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                showText == false ? Text("") : descText(text),
              ],
            );
          },
        )),
      ),
    );
  }

  double getFontSizeTwo() {
    if (getDeviceType() == "phone") {
      return 16;
    } else {
      return 19;
    }
  }

  Widget descText(String t) {
    return Flexible(
      child: Container(
          padding: EdgeInsets.all(5),
          child: Text(
            t,
            maxLines: 2,
            style: TextStyle(
                fontSize: getFontSizeTwo(),
                color: text_color,
                fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget videoWidget() {
    if (showNewDesign == true) {
      return videoNew();
    } else {
      return videoOld();
    }
  }

  Widget videoOld() {
    final double itemHeight = 200;
    final double itemWidth = MediaQuery.of(context).size.width / 3;
    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 50),
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: GridView.builder(
          // physics: NeverScrollableScrollPhysics(),
          // shrinkWrap: true,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
              childAspectRatio: (itemWidth / itemHeight)),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, index) {
            return this.getVideoWidget(
              this.videosData[index]["files_type"],
              this.videosData[index]["files_name"],
              this.videosData[index]["files_title"],
              this.videosData[index]["files_content"],
              this.videosData[index]["files_thumb"],
            );
          },
          itemCount: this.videosData == null ? 0 : this.videosData.length,
        ),
      ),
    );
  }

  Widget videoNew() {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Container(
      padding: EdgeInsets.only(bottom: 50),
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: ListView.builder(
            itemCount: videosData == null ? 0 : videosData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: this.videosData[index]["files_type"] == "himg" ||
                        this.videosData[index]["files_type"] == "hvid"
                    ? this.getHeaderImg(
                        this.videosData[index]["files_thumb"],
                        this.videosData[index]["files_name"],
                        this.videosData[index]["files_title"],
                        this.videosData[index]["files_content"],
                        this.videosData[index]["files_type"],
                        this.videosData[index]["post_srcimg"],
                        this.videosData[index]["post_appurl"])
                    : this.getHomeContainer(
                        this.videosData[index]["files_type"],
                        this.videosData[index]["files_name"],
                        this.videosData[index]["files_title"],
                        this.videosData[index]["files_content"],
                        this.videosData[index]["files_thumb"],
                        this.videosData[index]["post_srcimg"],
                        this.videosData[index]["post_appurl"]),
              );
            }),
      ),
    );
  }

/*  Widget videoWidget() {
    /*final double itemHeight = 200;
    final double itemWidth = MediaQuery.of(context).size.width / 3; */

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Container(
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: ListView.builder(
            itemCount: videosData == null ? 0 : videosData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: this.videosData[index]["files_type"] == "himg" ||
                        this.videosData[index]["files_type"] == "hvid"
                    ? this.getHeaderImg(
                        this.videosData[index]["files_thumb"],
                        this.videosData[index]["files_name"],
                        this.videosData[index]["files_title"],
                        this.videosData[index]["files_content"],
                        this.videosData[index]["files_type"],
                        this.videosData[index]["post_srcimg"],
                        this.videosData[index]["post_appurl"])
                    : this.getHomeContainer(
                        this.videosData[index]["files_type"],
                        this.videosData[index]["files_name"],
                        this.videosData[index]["files_title"],
                        this.videosData[index]["files_content"],
                        this.videosData[index]["files_thumb"],
                        this.videosData[index]["post_srcimg"],
                        this.videosData[index]["post_appurl"]),
              );
            }),
      ),
    );
  } */

  Widget getVideoWidget(String type, String imgStr, String text, String content,
      String thumbImg) {
    if (type == "Article" || type == "Transverse") {
      return getImageContainer(thumbImg, imgStr, text, content, true);
    } else if (type == "vid") {
      return getVideoContainer(thumbImg, imgStr, text, true);
    } else if (type == "evid") {
      return getHomeEvidContainer(imgStr, text, thumbImg);
    } else {
      return getImageContainer(thumbImg, imgStr, text, content, false);
    }
  }

  Widget getVideoContainer(
      String thumbImg, String imgStr, String text, bool showText) {
    final height = MediaQuery.of(context).size.width / 3;

    return Center(
      child: GestureDetector(onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoApp(
                url: imgStr,
              ),
            ));
      }, child: Container(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: constraints.maxWidth,
                      width: constraints.maxWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          thumbImg,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ],
                ),
                showText == false ? Text("") : descText(text),
              ],
            );
          },
        ),
      )),
    );
  }

  Widget transverseWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 50),
      child: RefreshIndicator(
        onRefresh: refreshList,
        child: ListView.builder(
            itemCount: transverseData == null ? 0 : transverseData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: this.transverseData[index]["files_type"] == "himg" ||
                        this.transverseData[index]["files_type"] == "hvid"
                    ? this.getHeaderImg(
                        this.transverseData[index]["files_thumb"],
                        this.transverseData[index]["files_name"],
                        this.transverseData[index]["files_title"],
                        this.transverseData[index]["files_content"],
                        this.transverseData[index]["files_type"],
                        this.transverseData[index]["post_srcimg"],
                        this.transverseData[index]["post_appurl"],
                      )
                    : this.getHomeContainer(
                        this.transverseData[index]["files_type"],
                        this.transverseData[index]["files_name"],
                        this.transverseData[index]["files_title"],
                        this.transverseData[index]["files_content"],
                        this.transverseData[index]["files_thumb"],
                        this.transverseData[index]["post_srcimg"],
                        this.transverseData[index]["post_appurl"]),
              );
            }),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: t2_white),
          child: _tabBar),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({Key key, this.thumbnailRequest}) : super(key: key);

  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final _image = snapshot.data.image;
          final _width = snapshot.data.width;
          final _height = snapshot.data.height;
          final _dataSize = snapshot.data.dataSize;
          return Container(
            child: _image,
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.red,
            child: Text(
              "Error:\n${snapshot.error.toString()}",
            ),
          );
        } else {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                /*  Text(
                    "Generating the thumbnail for: ${widget.thumbnailRequest.video}..."),
                SizedBox(
                  height: 10.0,
                ), */
                CircularProgressIndicator(),
              ]);
        }
      },
    );
  }
}

class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest(
      {this.video,
      this.thumbnailPath,
      this.imageFormat,
      this.maxHeight,
      this.maxWidth,
      this.timeMs,
      this.quality});
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;
  const ThumbnailResult({this.image, this.dataSize, this.height, this.width});
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  //WidgetsFlutterBinding.ensureInitialized();
  Uint8List bytes;
  final Completer<ThumbnailResult> completer = Completer();
  if (r.thumbnailPath != null) {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: r.video,
        thumbnailPath: r.thumbnailPath,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);

    final file = File(thumbnailPath);
    bytes = file.readAsBytesSync();
  } else {
    bytes = await VideoThumbnail.thumbnailData(
        video: r.video,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);
  }

  int _imageDataSize = bytes.length;

  final _image = Image.memory(
    bytes,
    fit: BoxFit.fill,
  );
  _image.image
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(ThumbnailResult(
      image: _image,
      dataSize: _imageDataSize,
      height: info.image.height,
      width: info.image.width,
    ));
  }));
  return completer.future;
}

class T5SliderWidget extends StatefulWidget {
  List<SliderModel> mSliderList;

  T5SliderWidget(this.mSliderList);

  @override
  _T5SliderWidgetState createState() => _T5SliderWidgetState();
}

class _T5SliderWidgetState extends State<T5SliderWidget> {
  int currentPage = 0;

  double getHeightAccordingly() {
    var height = MediaQuery.of(context).size.height;

    if (height > 926 && height < 1020) {
      return height / 2 - 70;
    } else if (height >= 1020) {
      return height / 2 - 100;
    } else {
      return 290;
    }
  }

  BoxFit getImageType() {
    var height = MediaQuery.of(context).size.height;

    return BoxFit.contain;

    /* if (height > 900 ) {
      return BoxFit.cover;
    }  else {
      return BoxFit.contain;
    } */
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    width = width - 50;
    final Size cardSize = Size(width, width / 1.8);
    this.getHeightAccordingly();
    return Container(
      //height: 290,
      height: getHeightAccordingly(),
      padding: EdgeInsets.only(top: 20),
      child: Column(
        // alignment: Alignment.center,
        children: [
          Flexible(
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              var h = constraints.maxHeight - 5;
              return Container(
                height: h,
                child: CarouselSlider(
                  viewportFraction: 0.9,
                  height: h,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (int i) {
                    setState(() {
                      this.currentPage = i;
                    });
                  },
                  items: widget.mSliderList.map(
                    (slider) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: cardSize.height,
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (slider.post_appurl != "" ||
                                    slider.files_content != "") {
                                  if (slider.post_appurl != "") {
                                    launch(slider.post_appurl);
                                  } else {
                                    if (slider.files_type != "Article") {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VideoApp(
                                                    url: slider.files_name,
                                                  )));
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            htmlData: slider.files_content,
                                            imgLink: slider.files_name,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        slider.files_thumb == ""
                                            ? slider.files_name
                                            : slider.files_thumb,
                                        fit: getImageType(),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: cardSize.height,
                                      ),
                                    ),
                                  ),
                                  if (slider.files_type != "Article")
                                    Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ).toList(),
                ),
              );
            }),
          ),
          SizedBox(
            height: 10,
          ),
          DotsIndicator(
              dotsCount:
                  widget.mSliderList == null || widget.mSliderList.length == 0
                      ? 1
                      : widget.mSliderList.length,
              position: this.currentPage,
              decorator: DotsDecorator(
                color: Colors.grey,
                activeColor: text_color,
              ))
        ],
      ),
    );
  }
}
