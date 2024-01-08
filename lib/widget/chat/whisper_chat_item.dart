import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_video/store/channel_store.dart';
import 'package:flutter_video/util/util.dart';
import 'package:flutter_video/vo/chat_item.dart';
import 'package:provider/provider.dart';

class WhisperChatItem extends StatelessWidget {
  final ChatItem data;
  const WhisperChatItem(
    this.data, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var channel = Provider.of<ChannelStore>(context, listen: false);
    return GestureDetector(
      onLongPress: data.isMe
          ? null
          : () => Util.sendWhisperDialog(context, channel.channel, data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffeeeeee),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/chat/ico_whisper.svg"),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: data.nickName,
                              style: const TextStyle(
                                color: Color(0xff666666),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                            TextSpan(
                              text: data.isMe ? "님에게 귓속말" : "님의 귓속말",
                              style: const TextStyle(
                                color: Color(0xff999999),
                                fontSize: 14.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.message,
                        style: const TextStyle(
                          color: Color(0xff333333),
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            Util.getCurrentDate(data.messageDt).toString(),
            style: const TextStyle(
              color: Color(0xffbbbbbb),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
