import 'package:flutter/material.dart';
import 'package:flutter_youtube/util/util.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayer extends StatefulWidget {
  final String? youtubeUrl;
  const YoutubePlayer(this.youtubeUrl, {super.key});

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late YoutubePlayerController _controller;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: YoutubePlayerController.convertUrlToId(widget.youtubeUrl!)!,
      params: YoutubePlayerParams(
        interfaceLanguage: 'ko',
        loop: true,
        color: 'transparent',
        strictRelatedVideos: true,
        showFullscreenButton: !Util.isWeb,
      ),
      autoPlay: true,
    );
    _controller.setFullScreenListener((value) {
      setState(() {
        isFullScreen = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        color: Colors.black,
        child: YoutubePlayerControllerProvider(
          controller: _controller,
          child: YoutubePlayerScaffold(
            controller: _controller,
            aspectRatio:
                Util.isMobile ? 16 / 9 : size.width / (size.height * 0.4),
            builder: (context, player) => player,
          ),
        ),
      ),
    );
  }
}
