import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String senderName;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final Uint8List? imageData;
  const ChatMessage({
    required this.senderName,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.imageData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == senderId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(senderName),
            Text(text),
          ],
        ),
      ],
    );
  }
}
