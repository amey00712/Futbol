import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:newsFlutter/Screens/ImgScreen.dart';
import 'package:newsFlutter/Utils/Colors.dart';
import 'package:share/share.dart';
import 'package:newsFlutter/Utils/Widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/style.dart';

class DetailScreen extends StatefulWidget {
  String htmlData;
  String imgLink;
  bool showAd;

  DetailScreen({this.htmlData, this.imgLink, this.showAd});
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  share(BuildContext context) {
    final RenderBox box = context.findRenderObject();

    Share.share(
        "Download iOS App: https://itunes.apple.com/us/app/Fútbol-First/id1542077557?ls=1&mt=8",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var content = widget.htmlData.replaceAll("\"", "\'");
    var content = widget.htmlData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: nav_bar_color,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: GestureDetector(
                onTap: () {
                  share(context);
                },
                child: Icon(
                  shareIcon(),
                  size: 22,
                )),
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Stack(
          children: [
            Column(
              children: [
                if (widget.imgLink != "")
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImgScreen(
                                    imgLink: widget.imgLink,
                                  )));
                    },
                    child: Container(
                      child: Hero(
                        // color: Colors.blue,
                        tag: 'imageTag',
                        child: Image.network(
                          widget.imgLink,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                Padding(
                    padding: EdgeInsets.only(right: 10, left: 10),
                    child: Html(
                      data: content,
                     /* style: {
                        "p": Style(
                          fontSize: FontSize(18.0),
                        ),
                      },*/
                      onLinkTap: (url, _, __, ___) async {
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      onImageTap: (src, _, __, ___) async {
                        if (await canLaunch(src)) {
                          await launch(
                            src,
                          );
                        } else {
                          throw 'Could not launch $src';
                        }
                      },
                    )),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
