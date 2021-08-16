import 'package:flutter/material.dart';
import 'package:newsFlutter/Utils/Colors.dart';

class ImgScreen extends StatefulWidget {

  String imgLink;
  ImgScreen({this.imgLink});

  @override
  _ImgScreenState createState() => _ImgScreenState();
}

class _ImgScreenState extends State<ImgScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: nav_bar_color,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Hero(
            tag: 'imageTag',
            child: Image.network(widget.imgLink),
          ),
        ),
      ),
    );
  }
}
