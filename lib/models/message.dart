import 'dart:convert';

class Message {
  final String senderName;
  final String content;
  final DateTime date;
  final String msg_type;
  String video_ulr;

  Message(
      this.senderName, this.content, this.date, this.msg_type, this.video_ulr);

  bool isUserMessage(String senderName) => this.senderName == senderName;

  String toJson() => json.encode({
        'senderName': senderName,
        'video_ulr': video_ulr,
        'msg_type': msg_type,
        'content': content,
        'date': date.toString(),
      });

  static Message fromJson(Map<String, dynamic> data) {
    return Message(
      data['senderName'],
      data['content'],
      DateTime.parse(data['date']),
      data['msg_type'],
      data['video_ulr'],
    );
  }
}
