import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_video/vo/chat_item.dart';

class ChatNoticeItem extends StatelessWidget {
  final ChatItem data;
  const ChatNoticeItem(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffeeeeee),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset("assets/chat/ico_entrynotice.svg"),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.message,
              style: const TextStyle(
                color: Color(0xff999999),
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
