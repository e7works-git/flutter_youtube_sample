import 'package:flutter/material.dart';
import 'package:flutter_video/store/channel_store.dart';
import 'package:flutter_video/util/util.dart';
import 'package:flutter_video/vo/chat_item.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatBaseItem extends StatefulWidget {
  final ChatItem data;
  final Widget content;
  final bool showTime;

  const ChatBaseItem(
    this.data,
    this.content, {
    super.key,
    this.showTime = true,
  });

  @override
  State<ChatBaseItem> createState() => _ChatBaseItemState();
}

class _ChatBaseItemState extends State<ChatBaseItem> {
  @override
  Widget build(BuildContext context) {
    var channel = context.read<ChannelStore>().channel;
    bool isWhisper = widget.data.messageType == MessageType.whisper;

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () {
            if (!widget.data.isMe && !widget.data.isDeleteChatting) {
              Util.chatLongPressDialog(context, channel, widget.data);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffeaeaea),
                  border: Border.all(
                    width: 2,
                    color: const Color(0xffeaeaea),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(13),
                  ),
                  child: Image.asset(
                    "assets/profile/profile_img_${widget.data.userInfo?['profile'].toString() ?? '1'}.png",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        widget.data.nickName ?? '홍길동',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color(0xff666666),
                        ),
                      ),
                    ),
                    if (isWhisper)
                      Text(
                        widget.data.isMe ? '님에게' : '님이',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color(0xff666666),
                        ),
                      ),
                    const SizedBox(height: 5),
                    widget.content,
                    if (widget.showTime) ...[
                      const SizedBox(height: 5),
                      Text(
                        Util.getCurrentDate(widget.data.messageDt).toString(),
                        style: const TextStyle(
                          color: Color(0xffbbbbbb),
                          fontSize: 10.0,
                        ),
                      ),
                    ]
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
