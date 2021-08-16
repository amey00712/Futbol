import 'package:newsFlutter/Utils/Colors.dart';
import 'package:newsFlutter/Utils/Widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:share/share.dart';

class VideoApp extends StatefulWidget {
  String url;

  VideoApp({this.url});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            aspectRatio: _controller.value.aspectRatio,
            allowFullScreen: true,
            // Prepare the video to be played and display the first frame
            autoInitialize: true,
            looping: false,
            // Errors can occur for example when trying to play a video
            // from a non-existent URL
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          );
        });
      });
  }
  share(BuildContext context) {
    final RenderBox box = context.findRenderObject();

    Share.share("Download iOS App: https://itunes.apple.com/us/app/Fútbol-First/id1542077557?ls=1&mt=8",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: nav_bar_color,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20,),
            child: GestureDetector(
                onTap: (){
                  share(context);
                },
                child: Icon(shareIcon(),size: 22,)),),
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController,
                ),
              )
            : Container(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
