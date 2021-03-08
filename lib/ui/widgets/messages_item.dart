import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/message.dart';

class MessagesItem extends StatelessWidget {
  final Message _message;

  final bool isUserMassage;

  const MessagesItem(this._message, this.isUserMassage);

  Future<File> writeToFile(Uint8List data) async {
    File recordedFile = File("/storage/emulated/0/recordedFile.mp4");
    recordedFile.writeAsBytesSync(data, flush: true);
    if (recordedFile != null) {
      print("=======not null=====");
    } else {
      print("=======null=====");
    }
  }
/*
  requestWritePermission() async {
    PermissionStatus permissionStatus =
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
    print(permissionStatus);
    if (permissionStatus == PermissionStatus.authorized) {}
  }*/

  getImage(Uint8List tempImg) async {
    if (tempImg != null) {
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/mynewCreat.mp4').create();
      file.writeAsBytesSync(tempImg);
    }
  }

//=======================
  Future<File> writeToFileNew(Uint8List data) async {
    final buffer = data.buffer;
    Directory tempDir = await getExternalStorageDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath +
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

  @override
  Widget build(BuildContext context) {
    // requestWritePermission();
    VideoPlayerController _controller;
    _controller = VideoPlayerController.network(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
    _controller.play();
    var bytes = [];
    if (_message.msg_type == "image") {
      bytes = base64.decode(_message.content);
    } else if (_message.msg_type == "video") {
      bytes = base64.decode(_message.content);
      //getImage(bytes);
      print("=======video==========");
      writeToFileNew(bytes).then(
          (value) => {print("=======video===downlaod done====${value}===")});
      /*   final PermissionHandler _permissionHandler = PermissionHandler();
      var result = await _permissionHandler.requestPermissions([PermissionGroup.storage]);
      if (result[PermissionGroup.storage] == PermissionStatus.granted) {*/
      // writeToFile(bytes);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection:
                isUserMassage ? TextDirection.rtl : TextDirection.ltr,
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
                          bottomRight: Radius.circular(isUserMassage ? 20 : 0),
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
                          _message.senderName.substring(0, 1).toUpperCase(),
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
                              _message.senderName,
                              style: Theme.of(context).textTheme.title.copyWith(
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
                  Container(
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
                            bottomLeft: Radius.circular(isUserMassage ? 20 : 0),
                            bottomRight:
                                Radius.circular(isUserMassage ? 0 : 20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Container(
                          color: isUserMassage
                              ? Theme.of(context).primaryColor.withOpacity(.8)
                              : Theme.of(context).accentColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: _message.msg_type == "video"
                              ? AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: <Widget>[
                                      VideoPlayer(_controller),
                                    ],
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _message.msg_type == "text"
                                        ? Text(
                                            _message.content,
                                            style: Theme.of(context)
                                                .textTheme
                                                .title
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          )
                                        : _message.msg_type == "image"
                                            ? Image.memory(
                                                bytes,
                                                height: 300,
                                                width: 300,
                                              )
                                            : Text("msg type not found"),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(_message.date)
                                          .toString(),
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle
                                          .copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withOpacity(.9),
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
