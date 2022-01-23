import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String receiverId;
  String text;
  DateTime sentAt;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.sentAt,
  });

  static Message from(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Message(
      senderId: snapshot.get('senderId'),
      receiverId: snapshot.get('receiverId'),
      text: snapshot.get('text'),
      sentAt: (snapshot.get('sentAt') as Timestamp).toDate(),
    );
  }
}
