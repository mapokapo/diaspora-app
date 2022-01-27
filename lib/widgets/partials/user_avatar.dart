import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final Uint8List? imageData;
  final bool mini;
  const UserAvatar(this.imageData, {this.mini = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mini ? 40 : 64,
      height: mini ? 40 : 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.secondary,
      ),
      clipBehavior: Clip.hardEdge,
      child: imageData != null
          ? Image.memory(
              imageData!,
              fit: BoxFit.cover,
            )
          : Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset('assets/images/profile.png'),
            ),
    );
  }
}
