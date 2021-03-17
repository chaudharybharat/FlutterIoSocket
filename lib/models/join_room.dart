import 'dart:convert';

class JoinRoom {
  final String username;
  final String room;

  JoinRoom(
    this.username,
    this.room,
  );

  String toJson() => json.encode({
        'username': username,
        'room': room,
      });

  static JoinRoom fromJson(Map<String, dynamic> data) {
    return JoinRoom(
      data['username'],
      data['room'],
    );
  }
}
