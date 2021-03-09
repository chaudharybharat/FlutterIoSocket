import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerRemote extends StatefulWidget {
  final String url;
  bool playPause;
  VideoPlayerRemote({this.url, this.playPause});
  @override
  _VideoPlayerRemoteState createState() => _VideoPlayerRemoteState();
}

class _VideoPlayerRemoteState extends State<VideoPlayerRemote> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.url, //to access its parent class constructor or variable
    );
    _controller.addListener(() {
      if (_controller.value.isPlaying && widget.playPause) {
        _data();
      }
      print("====addListener====${widget.playPause}=");
    });
    _controller.setLooping(true); //loop through video
    _controller.initialize();
    //initialize the VideoPlayer
  }

  _data() async {
    setState(() {
      widget.playPause = false;
      _controller.pause();
    });
  }

  @override
  void dispose() {
    print("======dispose=======");
    _controller.dispose(); //dispose the VideoPlayer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          // padding: const EdgeInsets.all(20),
          height: 250,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              /*AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child:*/
              VideoPlayer(_controller),
              _PlayPauseOverlay(
                controller: _controller,
                onTap: () {
                  setState(() {
                    widget.playPause = false;
                  });
                },
                ispause: widget.playPause,
              ),
              VideoProgressIndicator(_controller, allowScrubbing: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final Function onTap;
  final bool ispause;
  const _PlayPauseOverlay({Key key, this.controller, this.onTap, this.ispause})
      : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 70.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            onTap();
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              // If the video is paused, play it.
              controller.play();
            }
            //controller.play();
          },
        ),
      ],
    );
  }
}
