import 'package:flutter/material.dart';
import 'package:flutter_video/vo/chat_item.dart';
import 'package:flutter_video/widget/chat/chat_base_item.dart';

class EmojiChatItem extends StatelessWidget {
  const EmojiChatItem(
    this.data, {
    super.key,
  });
  final ChatItem data;

  @override
  Widget build(BuildContext context) {
    return ChatBaseItem(
      data,
      SizedBox(
        width: 90,
        child: Image.asset(
          'assets/${data.message}',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
