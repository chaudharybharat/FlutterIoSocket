import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class MessageForm extends StatefulWidget {
  final Function(String, String) onSendMessage;

  final Function onTyping;

  final Function onStopTyping;

  const MessageForm({
    @required this.onSendMessage,
    @required this.onTyping,
    @required this.onStopTyping,
  });

  @override
  _MessageFormState createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  TextEditingController _textEditingController;

  Timer _typingTimer;

  bool _isTyping = false;

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) return;

    widget.onSendMessage(_textEditingController.text, "text");
    setState(() {
      _textEditingController.text = "";
    });
  }

  void _runTimer() {
    if (_typingTimer != null && _typingTimer.isActive) _typingTimer.cancel();
    _typingTimer = Timer(Duration(milliseconds: 600), () {
      if (!_isTyping) return;
      _isTyping = false;
      widget.onStopTyping();
    });
    _isTyping = true;
    widget.onTyping();
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: TextField(
                  onChanged: (_) {
                    _runTimer();
                  },
                  onSubmitted: (_) {
                    _sendMessage();
                  },
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Enter your message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              child: IconButton(
                onPressed: _sendMessage,
                icon: Icon(FontAwesomeIcons.telegramPlane),
                color: Theme.of(context).primaryColor,
                iconSize: 35,
              ),
            ),
            Container(
              child: IconButton(
                onPressed: openCameraGalleryBottomSheet,
                icon: Icon(FontAwesomeIcons.camera),
                color: Theme.of(context).primaryColor,
                iconSize: 35,
              ),
            )
          ],
        ),
      ),
    );
  }

  void openCameraGalleryBottomSheet() async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
              // margin: EdgeInsets.only(left: 10, right: 10),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImageFromGallery(ImageSource.camera);
                      //  _getImage();
                      Navigator.pop(context);
                    }, // handle your image tap here
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 100,
                          ),
                        ),
                        Text(
                          'camera',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      pickImageFromGallery(ImageSource.gallery);
                      Navigator.pop(context);
                    }, // handle your image tap here
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          child:
                              Icon(Icons.image, color: Colors.grey, size: 100),
                        ),
                        Text(
                          'gallery',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        )
                      ],
                    ),
                  )
                ],
              ));
        });
  }

  Future<Uint8List> _readFileByte(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File audioFile = new File.fromUri(myUri);
    Uint8List bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      String base64Image = base64Encode(bytes);
      // widget.onSendMessage(base64Image);
      print("=====base64Image new===${base64Image}======");
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }

  File img_profile;
  pickImageFromGallery(ImageSource source) async {
    try {
      var imageFile =
          await ImagePicker.pickImage(source: source).then((picture) {
        setState(() {
          img_profile = File(picture.path);
        });
        // _readFileByte(picture.path);
        print("============${picture.path}===");
        String base64Image = base64Encode(img_profile.readAsBytesSync());

        List<int> imageBytes = img_profile.readAsBytesSync();
        // String base64Image = base64Encode(imageBytes);
        print("=base64Image1====${base64Image}==");
        widget.onSendMessage(base64Image, "image");

        //  getFileSelect(picture); // I found this .then necessary
      });
    } catch (error) {
      print('error taking picture ${error} ');
    }
  }
}
