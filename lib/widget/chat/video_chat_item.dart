import 'package:flutter/material.dart';
import 'package:flutter_youtube/vo/chat_item.dart';
import 'package:flutter_youtube/widget/chat/chat_base_item.dart';
import 'package:flutter_youtube/widget/chat/file_chat_item.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

import 'video_player_screen.dart';

class VideoChatItem extends StatelessWidget {
  final ChatItem data;
  final FileModel file;
  final bool isUnsupported;

  const VideoChatItem(
    this.data,
    this.isUnsupported, {
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return isUnsupported
        ? FileChatItem(
            data,
            file: file,
          )
        : ChatBaseItem(
            data,
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: VideoPlayerScreen(file: file),
            ),
          );
  }
}
