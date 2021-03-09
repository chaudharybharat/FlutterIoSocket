import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io_chat/ui/widgets/MessagesItem.dart';
import 'package:flutter_socket_io_chat/ui/widgets/MessagesItemNew.dart';
import 'package:flutter_socket_io_chat/video_player/VideoPlayerRemote.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../providers/messages_provider.dart';
import '../../models/message.dart';
import '../../constants.dart';
import '../../data/socket_io_manager.dart';
import '../widgets/messages_item_stefull.dart';
import '../widgets/messages_form.dart';

class ChatScreen extends StatefulWidget {
  final String senderName;

  const ChatScreen(this.senderName);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController _scrollController;

  SocketIoManager _socketIoManager;

  bool _isTyping = false;
  String _userNameTyping;

  void _onTyping() {
    _socketIoManager.sendMessage(
        'typing', json.encode({'senderName': widget.senderName}));
  }

  void _onStopTyping() {
    _socketIoManager.sendMessage(
        'stop_typing', json.encode({'senderName': widget.senderName}));
  }

  void _sendMessage(String messageContent, String msg_type) {
    _socketIoManager.sendMessage(
      'send_message',
      Message(widget.senderName, messageContent, DateTime.now(), msg_type, "")
          .toJson(),
    );

    Provider.of<MessagesProvider>(context, listen: false).addMessage(Message(
        widget.senderName, messageContent, DateTime.now(), msg_type, ""));
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _socketIoManager = SocketIoManager(serverUrl: SERVER_URL)
      ..init()
      ..subscribe('receive_message', (Map<String, dynamic> data) {
        Provider.of<MessagesProvider>(context, listen: false)
            .addMessage(Message.fromJson(data));
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 200),
          curve: Curves.bounceInOut,
        );
      })
      ..subscribe('typing', (Map<String, dynamic> data) {
        _userNameTyping = data['senderName'];
        setState(() {
          _isTyping = true;
        });
      })
      ..subscribe('stop_typing', (Map<String, dynamic> data) {
        setState(() {
          _isTyping = false;
        });
      })
      ..connect();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _socketIoManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.senderName),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Consumer<MessagesProvider>(
                builder: (_, messagesProvider, __) => ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messagesProvider.allMessages.length,
                    itemBuilder: (ctx, index) =>
                        /* rowChatUi(
                      index,
                      messagesProvider.allMessages[index],
                      messagesProvider.allMessages[index]
                          .isUserMessage(widget.senderName))*/
                        MessagesItemNew(
                          message: messagesProvider.allMessages[index],
                          isUserMassage: messagesProvider.allMessages[index]
                              .isUserMessage(widget.senderName),
                        ))),
          ),
          Visibility(
            visible: _isTyping,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    '$_userNameTyping is typing',
                    style: Theme.of(context).textTheme.title.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                  ),
                  Lottie.asset(
                    'assets/animations/chat-typing-indicator.json',
                    width: 40,
                    height: 40,
                    alignment: Alignment.bottomLeft,
                  ),
                ],
              ),
            ),
          ),
          MessageForm(
            onSendMessage: _sendMessage,
            onTyping: _onTyping,
            onStopTyping: _onStopTyping,
          ),
        ],
      ),
    );
  }

  VideoPlayerController _controller;
  String urlVideo = "";
  var bytes = [];

  Widget rowChatUi(int index, Message message, bool isUserMassage) {
    if (message.msg_type == "image") {
      bytes = base64.decode(message.content);
    } else if (message.msg_type == "video") {
      bytes = base64.decode(message.content);
      //getImage(bytes);
      print("=======video==========");
      if (message.video_ulr == "") {
        writeToFileNew(bytes)
            .then((value) => {videoCompleteDonwload(message, index, value)});
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              /*  textDirection:
                isUserMassage ? TextDirection.rtl : TextDirection.ltr,*/
              children: <Widget>[
                isUserMassage
                    ? SizedBox()
                    : Card(
                        elevation: 10,
                        color: isUserMassage
                            ? Theme.of(context).primaryColor.withOpacity(.8)
                            : Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight:
                                Radius.circular(isUserMassage ? 20 : 0),
                            bottomLeft: Radius.circular(isUserMassage ? 0 : 20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          child: Text(
                            message.senderName.substring(0, 1).toUpperCase(),
                            style: Theme.of(context).textTheme.title.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                Column(
                  crossAxisAlignment: isUserMassage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    isUserMassage
                        ? SizedBox()
                        : Container(
                            padding: isUserMassage
                                ? const EdgeInsets.only(right: 15)
                                : const EdgeInsets.only(left: 15),
                            child: FittedBox(
                              child: Text(
                                message.senderName,
                                style:
                                    Theme.of(context).textTheme.title.copyWith(
                                          color: Colors.black.withOpacity(.6),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 3,
                    ),
                    message.msg_type == "video"
                        ? message.video_ulr == ""
                            ? Container(
                                color: Colors.red,
                                height: 300,
                                width: 200,
                                child: Text("video loding..."),
                              )
                            : Container(
                                height: 300,
                                width: 200,
                                child: VideoPlayerRemote(
                                  url: message.video_ulr,
                                  playPause: false,
                                ),
                              )
                        //  : Container()
                        : Container(
                            width: MediaQuery.of(context).size.width * .75,
                            child: Align(
                              alignment: isUserMassage
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Card(
                                elevation: 10,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(isUserMassage ? 20 : 0),
                                    bottomRight:
                                        Radius.circular(isUserMassage ? 0 : 20),
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Container(
                                  color: message.msg_type == "video"
                                      ? Colors.transparent
                                      : isUserMassage
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.8)
                                          : Theme.of(context).accentColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: message.msg_type == "video"
                                      ? _controller.value.initialized
                                          ? SizedBox(
                                              height: 300,
                                              width: 200,
                                              child: VideoPlayer(_controller),
                                            )
                                          : Container()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            message.msg_type == "text"
                                                ? Text(
                                                    message.content,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  )
                                                : message.msg_type == "image"
                                                    ? Image.memory(
                                                        bytes,
                                                        height: 300,
                                                        width: 300,
                                                      )
                                                    : Text(
                                                        "msg type not found"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              DateFormat('HH:mm')
                                                  .format(message.date)
                                                  .toString(),
                                              textAlign: TextAlign.start,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle
                                                  .copyWith(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white
                                                        .withOpacity(.9),
                                                  ),
                                            )
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    }
  }

  var filePath = "";

//=======================
  Future<File> writeToFileNew(Uint8List data) async {
    final buffer = data.buffer;
    Directory tempDir = await getExternalStorageDirectory();
    String tempPath = tempDir.path;
    filePath = tempPath +
        '/' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        'file_01.mp4';
    print(
        "===filePath=====${filePath}======"); // file_01.tmp is dump file, can be anything
    /*return await File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));*/
    return new File(filePath)
        .writeAsBytes(data, mode: FileMode.writeOnly, flush: true);
  }

  videoCompleteDonwload(Message message, int index, File value) {
    message.video_ulr = value.path;
    print("complet donlwod ===");
    /* Provider.of<MessagesProvider>(context, listen: false)
        .updateMessage(index, message);*/
    setState(() {
      // urlVideo = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4";
      urlVideo = value.path;
    });
  }
}
