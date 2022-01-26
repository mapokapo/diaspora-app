import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Match {
  String id;
  Uint8List? imageData;
  bool googleUser;
  bool matchedYou;
  String name;
  List<String> interests;

  Match({
    required this.id,
    required this.name,
    required this.interests,
    this.matchedYou = true,
    this.imageData,
    this.googleUser = false,
  });

  static Future<Match> fromDoc(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    return Match._from(snapshot);
  }

  static Future<Match> fromQuery(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) async {
    return Match._from(snapshot);
  }

  static Future<Match> fromId(String id) async {
    debugPrint(id);
    final _matchIds = List<String>.from((await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get())
        .get('matches'));
    final _matchData = await FirebaseFirestore.instance
        .collection('users')
        .doc(_matchIds.firstWhere((m) => m == id))
        .get();
    return Match.fromDoc(_matchData);
  }

  static Future<Match> _from(dynamic snapshot) async {
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
    final _matches = List<String>.from(snapshot.get('matches'));
    final _matchedYou =
        _matches.contains(FirebaseAuth.instance.currentUser!.uid);
    return Match(
      id: snapshot.id,
      name: snapshot.get('name'),
      interests: List<String>.from(snapshot.get('interests')),
      imageData: _imageData,
      googleUser: _googleUser,
      matchedYou: _matchedYou,
    );
  }
}
