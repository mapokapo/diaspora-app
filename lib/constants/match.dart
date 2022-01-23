import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Match {
  String id;
  Uint8List? imageData;
  String name;
  List<String> interests;

  Match({
    required this.id,
    required this.name,
    required this.interests,
    this.imageData,
  });

  static Future<Match> from(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final _imageExists =
        (await FirebaseStorage.instance.ref('profile_images').list())
            .items
            .any((ref) => ref.name == snapshot.id);
    Uint8List? _imageData;
    if (_imageExists) {
      _imageData = await FirebaseStorage.instance
          .ref('profile_images')
          .child(snapshot.id)
          .getData();
    }
    return Match(
      id: snapshot.id,
      name: snapshot.get('name'),
      interests: List<String>.from(snapshot.get('interests')),
      imageData: _imageData,
    );
  }
}
