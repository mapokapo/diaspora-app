import 'dart:typed_data';

import 'package:diaspora_app/constants/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String senderName;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final Uint8List? imageData;
  final Message? prevMessage;
  const ChatMessage({
    required this.senderName,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.imageData,
    this.prevMessage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sender = FirebaseAuth.instance.currentUser!.uid == senderId;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8) +
          EdgeInsets.only(
              top: !sender && prevMessage?.senderId == senderId
                  ? 1
                  : prevMessage?.senderId != senderId
                      ? 16
                      : 4),
      child: Row(
        mainAxisAlignment:
            sender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints:
                  BoxConstraints(minWidth: sender ? 0 : 100, maxWidth: 300),
              decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.primaryVariant
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: sender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!sender && prevMessage?.senderId != senderId)
                      Text(
                        senderName,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    Text(text),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
