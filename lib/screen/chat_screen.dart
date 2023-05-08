import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_youtube/main.dart';
import 'package:flutter_youtube/store/channel_store.dart';
import 'package:flutter_youtube/store/emoji_store.dart';
import 'package:flutter_youtube/store/player_store.dart';
import 'package:flutter_youtube/util/logger.dart';
import 'package:flutter_youtube/util/util.dart';
import 'package:flutter_youtube/vo/chat_item.dart';
import 'package:flutter_youtube/widget/chat/chat_notice_item.dart';
import 'package:flutter_youtube/widget/chat/emoji_chat_item.dart';
import 'package:flutter_youtube/widget/chat/emoji_images.dart';
import 'package:flutter_youtube/widget/chat/emoji_list.dart';
import 'package:flutter_youtube/widget/chat/file_chat_item.dart';
import 'package:flutter_youtube/widget/chat/image_chat_item.dart';
import 'package:flutter_youtube/widget/chat/text_chat_item.dart';
import 'package:flutter_youtube/widget/chat/user_join_item.dart';
import 'package:flutter_youtube/widget/chat/user_leave_item.dart';
import 'package:flutter_youtube/widget/chat/video_chat_item.dart';
import 'package:flutter_youtube/widget/chat/whisper_chat_item.dart';
import 'package:flutter_youtube/widget/common/anchor.dart';
import 'package:flutter_youtube/widget/common/heart_icon.dart';
import 'package:flutter_youtube/widget/common/youtube_player.dart';
import 'package:flutter_youtube/widget/drawer/right_drawer.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/constants.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late final Channel channel;
  late final PlayerStore playerStore;

  var inputController = TextEditingController();
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _focus = FocusNode();
  var currentScrollPosition = false;
  var emojiActive = false;
  ChatRoomModel? roomInfo;
  TargetDrawer target = TargetDrawer.Help;
  var rowHeight = 50.0;

  @override
  void initState() {
    channel = Provider.of<ChannelStore>(context, listen: false).channel!;
    playerStore = Provider.of<PlayerStore>(context, listen: false);
    VChatCloudApi.getRoomInfo(roomId: roomId).then((value) {
      setState(() {
        roomInfo = value;
      });
    });
    inputController.addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          rowHeight = rowKey.currentContext?.size?.height ?? 50.0;
        });
      });
    });
    _focus.onKey = (node, event) {
      if (event is RawKeyDownEvent && !Util.isMobile) {
        if (event.isShiftPressed && event.logicalKey.keyLabel == 'Enter') {
          return KeyEventResult.ignored;
        } else if (event.logicalKey.keyLabel == 'Enter') {
          sendMessage();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };
    _scrollController.addListener(() {
      scrollController();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focus.dispose();
    channel.leave();
    super.dispose();
  }

  void scrollController() {
    if (_scrollController.offset <= 300) {
      setState(() {
        currentScrollPosition = false;
      });
    } else if (currentScrollPosition == false) {
      setState(() {
        currentScrollPosition = true;
      });
    }
  }

  void clientListHandler() {
    logger.d('client list clicked');
    setState(() {
      target = TargetDrawer.ClientList;
      _scaffoldKey.currentState!.openEndDrawer();
      unfocus();
    });
  }

  void fileBoxHandler() {
    logger.d('file box clicked');
    setState(() {
      target = TargetDrawer.FileBox;
      _scaffoldKey.currentState!.openEndDrawer();
      unfocus();
    });
  }

  void helpHandler() {
    logger.d('help clicked');
    setState(() {
      target = TargetDrawer.Help;
      _scaffoldKey.currentState!.openEndDrawer();
      unfocus();
    });
  }

  void backHandler() {
    Navigator.pop(context);
  }

  void fileUploadMethod() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    bool isDialogOpened = false;

    void dialog() async {
      isDialogOpened = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      isDialogOpened = false;
    }

    if (result != null && context.mounted) {
      dialog();

      try {
        var file = result.files.single;

        if (Util.isWeb) {
          await channel.sendFile(UploadFileModel(
            bytes: file.bytes,
            name: file.name,
          ));
        } else {
          await channel.sendFile(UploadFileModel(
            file: File(file.path!),
          ));
        }
        moveScrollBottom();
      } catch (e) {
        if (e is VChatCloudError) {
          Util.showToast(e.message);
        } else {
          Util.showToast("알 수 없는 오류가 발생했습니다.");
        }
      } finally {
        if (context.mounted && isDialogOpened) {
          Navigator.pop(context);
        }
      }
    }
  }

  void uploadHandler() async {
    if (await Util.filePermissionCheck()) {
      fileUploadMethod();
    } else {
      var granted = await Util.requestFileWrite();
      if (granted) {
        uploadHandler();
      }
    }
  }

  void emojiHandler() {
    _focus.unfocus();
    setState(() {
      emojiActive = !emojiActive;
    });
  }

  void moveScrollBottom() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(0);
      setState(() {});
    });
  }

  void unfocus() {
    _focus.unfocus();
    setState(() {
      emojiActive = false;
    });
  }

  void sendMessage() {
    if (!Util.isMobile) {
      _focus.requestFocus();
    }
    if (inputController.text.trim().isEmpty) return;

    channel.sendMessage(inputController.text);
    inputController.clear();

    moveScrollBottom();
  }

  bool get messageIsEmpty => inputController.text.trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    var chatLog = Provider.of<ChannelStore>(context).chatLog;
    var clientList = Provider.of<ChannelStore>(context).clientList;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: RightDrawer(
            target: target,
          ),
          endDrawerEnableOpenDragGesture: false,
          body: Container(
            color: const Color(0xffffffff),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (Util.isMobile || Util.isWeb)
                  const YoutubePlayer('https://youtu.be/eS-wNZQyuc8')
                else
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "미지원 기기입니다.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xffdddddd)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        iconSize: 20,
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.blue.shade900,
                        ),
                        splashRadius: 20,
                        onPressed: backHandler,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roomInfo?.roomNm ?? "로딩중입니다...",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xff666666),
                              ),
                            ),
                            Row(
                              children: [
                                Anchor(
                                  onTap: clientListHandler,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.blue.shade800,
                                        size: 14,
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        clientList.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff999999),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                const HeartIcon(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 22,
                        child: IconButton(
                          onPressed: fileBoxHandler,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.inbox,
                            color: Color(0xffCCCCCC),
                          ),
                          splashRadius: 18,
                        ),
                      ),
                      SizedBox(
                        width: 22,
                        child: IconButton(
                          onPressed: helpHandler,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.help_outline,
                            color: Color(0xffCCCCCC),
                          ),
                          splashRadius: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: unfocus,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        chatBuilder(chatLog),
                        if (currentScrollPosition)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: FloatingActionButton.small(
                              onPressed: () {
                                _scrollController.jumpTo(0);
                                setState(() {
                                  currentScrollPosition = false;
                                });
                              },
                              tooltip: "Scroll to Bottom",
                              child: const Icon(Icons.arrow_downward),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                bottomBarBuilder(),
                if (emojiActive) emojiBuilder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget emojiBuilder() {
    var emoji = Provider.of<EmojiStore>(context);
    emoji.initEmojiList();
    emoji.initChildEmojiList();

    return Column(
      children: const [
        EmojiImages(),
        EmojiList(),
      ],
    );
  }

  Widget bottomBarBuilder() {
    return Container(
      color: const Color(0xffeeeeee),
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                TextField(
                  key: rowKey,
                  focusNode: _focus,
                  controller: inputController,
                  minLines: 1,
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  cursorColor: const Color(0xff2a61be),
                  onTap: () {
                    setState(() {
                      emojiActive = false;
                    });
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                        color: Color(0xffe3e3e3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide.none),
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  onEditingComplete: sendMessage,
                ),
                Positioned(
                  left: 8,
                  child: SizedBox(
                    width: 20,
                    child: IconButton(
                      onPressed: fileUploadMethod,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      color: Colors.grey[500],
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  child: SizedBox(
                    width: 20,
                    child: IconButton(
                      onPressed: emojiHandler,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      color:
                          (emojiActive) ? Colors.blue[700] : Colors.grey[500],
                      icon: const Icon(
                        Icons.emoji_emotions,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Anchor(
            onTap: sendMessage,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 30,
              height: 30,
              child: messageIsEmpty
                  ? SvgPicture.asset("assets/chat/send_disable.svg")
                  : SvgPicture.asset("assets/chat/send.svg"),
            ),
          )
        ],
      ),
    );
  }

  Widget chatBuilder(List<ChatItem> chatLog) {
    bool isUnSupported = Util.isWeb ||
        (!Util.isWeb && Platform.isWindows ||
            Platform.isMacOS ||
            Platform.isLinux ||
            Platform.isFuchsia);
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(15),
        reverse: true,
        child: Column(
          children: [
            ...chatLog.asMap().entries.expand(
              (entry) {
                var log = entry.value;
                FileModel? file;
                if (log.mimeType == MimeType.file) {
                  try {
                    if (log.message is String) {
                      file = FileModel.fromJson(json.decode(log.message)[0]);
                    } else {
                      file = FileModel.fromJson(log.message[0]);
                    }
                  } catch (e) {
                    if (log.message is String) {
                      file = FileModel.fromHistoryJson(
                          json.decode(log.message)[0]);
                    } else {
                      file = FileModel.fromHistoryJson(log.message[0]);
                    }
                  }
                }

                return [
                  const SizedBox(height: 20),
                  if (log.messageType == MessageType.join)
                    UserJoinItem(log)
                  else if (log.messageType == MessageType.leave)
                    UserLeaveItem(log)
                  else if (log.messageType == MessageType.notice)
                    ChatNoticeItem(log)
                  else if (log.messageType == MessageType.whisper)
                    WhisperChatItem(
                      log,
                    )
                  else if (log.messageType == MessageType.custom)
                    const Text("커스텀")
                  else if (log.mimeType == MimeType.emojiImg)
                    EmojiChatItem(
                      log,
                    )
                  else if (file != null)
                    if (imgTypeList.contains(file.fileExt))
                      ImageChatItem(
                        log,
                        file: file,
                      )
                    else if (videoTypeList.contains(file.fileExt) &&
                        !isUnSupported)
                      VideoChatItem(
                        log,
                        isUnSupported,
                        file: file,
                      )
                    else
                      FileChatItem(
                        log,
                        file: file,
                      )
                  else
                    TextChatItem(
                      log,
                    ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
