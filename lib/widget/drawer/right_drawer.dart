import 'package:flutter/material.dart';
import 'package:flutter_video/widget/drawer/client_list_screen.dart';
import 'package:flutter_video/widget/drawer/file_box_screen.dart';
import 'package:flutter_video/widget/drawer/help_screen.dart';

class RightDrawer extends StatefulWidget {
  final TargetDrawer target;
  const RightDrawer({super.key, required this.target});

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  void closeHelp() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    late final Widget target;

    setState(() {
      switch (widget.target) {
        case TargetDrawer.ClientList:
          target = const ClientListScreen();
          break;
        case TargetDrawer.FileBox:
          target = const FileBoxScreen();
          break;
        case TargetDrawer.Help:
        default:
          target = const HelpScreen();
          break;
      }
    });

    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(15),
        ),
        child: Drawer(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 45,
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.target.title,
                      style: const TextStyle(
                        color: Color(0xff333333),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    IconButton(
                      onPressed: closeHelp,
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xff2A5DA9),
                      ),
                      iconSize: 18,
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: target,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TargetDrawer {
  Help("help", "도움말"),
  ClientList("clientList", "채팅 참여자 목록"),
  FileBox("fileBox", "파일 모아보기");

  final String target;
  final String title;
  const TargetDrawer(this.target, this.title);
}
