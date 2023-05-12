import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_youtube/util/util.dart';
import 'package:flutter_youtube/vo/chat_item.dart';
import 'package:flutter_youtube/widget/chat/chat_base_item.dart';
import 'package:flutter_youtube/widget/common/anchor.dart';
import 'package:flutter_youtube/widget/common/text_middle_ellipsis.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class FileChatItem extends StatefulWidget {
  final ChatItem data;
  final FileModel file;
  const FileChatItem(
    this.data, {
    super.key,
    required this.file,
  });

  @override
  State<FileChatItem> createState() => _FileChatItemState();
}

class _FileChatItemState extends State<FileChatItem> {
  bool fileExist = false;

  @override
  void initState() {
    Util.getDownloadPath().then((path) {
      if (Util.isWeb) {
        return Future.value(false);
      } else {
        var checkFile = File(
            "$path$pathSeparator${widget.file.fileKey}_${widget.file.originFileNm}");
        return checkFile.exists();
      }
    }).then((exist) {
      if (exist) {
        setState(() {
          fileExist = true;
        });
      }
    });
    super.initState();
  }

  Future<void> download(BuildContext context) async {
    var granted = await Util.requestFileWrite();
    if (granted) {
      Util.showToast("파일을 저장중입니다.");

      await VChatCloudApi.download(
        file: widget.file,
        downloadPath: await Util.getDownloadPath(),
      );

      Util.showToast("파일이 저장되었습니다.");
      setState(() {
        fileExist = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String sizeText = Util.getSizedText(widget.file.fileSize);
    return ChatBaseItem(
      widget.data,
      SizedBox(
        width: MediaQuery.of(context).size.width - (30 + 26 + 8),
        child: Column(
          children: [
            Container(
              height: 90,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                border: Border.all(
                  color: const Color(0xffe3e3e3),
                ),
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: Row(
                // mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: const Icon(
                      Icons.file_copy,
                      size: 30,
                      color: Color(0xffcccccc),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextMiddleEllipsis(
                            widget.file.originFileNm!,
                            style: const TextStyle(
                              color: Color(0xff333333),
                              fontSize: 14.0,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flex(
                            direction: Axis.vertical,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "유효기간 : ~ ${widget.file.expire}",
                                style: const TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 10.0,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                "용량 : $sizeText",
                                style: const TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    Util.getCurrentDate(widget.data.messageDt).toString(),
                    style: const TextStyle(
                      color: Color(0xffbbbbbb),
                      fontSize: 10.0,
                    ),
                  ),
                  Anchor(
                    onTap: () async {
                      if (fileExist) {
                        var result = await Util.openFile(widget.file);
                        setState(() {});
                      } else {
                        download(context);
                      }
                    },
                    child: Text(
                      fileExist ? "열기" : "저장",
                      style: const TextStyle(
                        color: Color(0xff333333),
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      showTime: false,
    );
  }
}
