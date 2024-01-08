import 'package:flutter/material.dart';
import 'package:flutter_video/util/util.dart';
import 'package:flutter_video/vo/chat_item.dart';
import 'package:flutter_video/widget/chat/open_graph_item.dart';
import 'package:flutter_video/widget/common/anchor.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class TextBox extends StatelessWidget {
  final ChatItem data;
  const TextBox(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    const regex = Util.urlRegex;
    final List<InlineSpan> texts = [];

    data.message.toString().splitMapJoin(RegExp(regex), onMatch: (m) {
      texts.add(
        WidgetSpan(
          child: Anchor(
            onTap: () => Util.openLink(m[0]!),
            child: Text(
              '${m[0]}',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      );
      return '';
    }, onNonMatch: (n) {
      texts.add(
        TextSpan(
          text: n,
          style: TextStyle(
            color: data.isDeleteChatting
                ? const Color(0xff999999)
                : const Color(0xff333333),
            fontWeight:
                data.isDeleteChatting ? FontWeight.w200 : FontWeight.normal,
            fontSize: 14.0,
          ),
        ),
      );
      return '';
    });
    var firstUrl = RegExp(regex).firstMatch(data.message);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: (data.messageType == MessageType.whisper)
                  ? Text(
                      data.message,
                      style: const TextStyle(
                        color: Color(0xff333333),
                        fontSize: 14.0,
                      ),
                    )
                  : Text.rich(TextSpan(children: texts)),
            ),
            if (firstUrl != null) OpenGraphItem(firstUrl.group(0)!)
          ],
        ),
      ],
    );
  }
}
