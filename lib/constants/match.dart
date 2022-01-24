import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class Match {
  String id;
  Uint8List? imageData;
  bool googleUser;
  bool isMatched;
  String name;
  List<String> interests;

  Match({
    required this.id,
    required this.name,
    required this.interests,
    this.isMatched = true,
    this.imageData,
    this.googleUser = false,
  });

  static Future<Match> from(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final _imageExists =
        (await FirebaseStorage.instance.ref('profile_images').list())
            .items
            .any((ref) => ref.name == snapshot.id);
    Uint8List? _imageData;
    bool _googleUser = false;
    if (_imageExists) {
      _imageData = await FirebaseStorage.instance
          .ref('profile_images')
          .child(snapshot.id)
          .getData();
    } else if (snapshot.get('imageUrl') != null) {
      final ByteData imageData =
          await NetworkAssetBundle(Uri.parse(snapshot.get('imageUrl')))
              .load("");
      _imageData = imageData.buffer.asUint8List();
      _googleUser = true;
    }
    return Match(
      id: snapshot.id,
      name: snapshot.get('name'),
      interests: List<String>.from(snapshot.get('interests')),
      imageData: _imageData,
      googleUser: _googleUser,
    );
  }
}
