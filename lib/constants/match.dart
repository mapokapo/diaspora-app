import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Match {
  String id;
  Uint8List? imageData;
  bool googleUser;
  bool matchedYou;
  DateTime dateOfBirth;
  String? bio;
  String name;
  List<String> interests;
  int messageCount;

  Match({
    required this.id,
    required this.name,
    required this.interests,
    required this.dateOfBirth,
    this.bio,
    this.matchedYou = true,
    this.imageData,
    this.googleUser = false,
    this.messageCount = 0,
  });

  String getLocalizedHoroscope(BuildContext context) {
    final days = [21, 20, 21, 21, 22, 22, 23, 24, 24, 24, 23, 22];
    final signs = {
      "aquarius",
      "pisces",
      "aries",
      "taurus",
      "gemini",
      "cancer",
      "leo",
      "virgo",
      "libra",
      "scorpio",
      "sagittarius",
      "capricorn"
    };
    final signLocalizationMap = {
      "aquarius": AppLocalizations.of(context)!.aquarius,
      "pisces": AppLocalizations.of(context)!.pisces,
      "aries": AppLocalizations.of(context)!.aries,
      "taurus": AppLocalizations.of(context)!.taurus,
      "gemini": AppLocalizations.of(context)!.gemini,
      "cancer": AppLocalizations.of(context)!.cancer,
      "leo": AppLocalizations.of(context)!.leo,
      "virgo": AppLocalizations.of(context)!.virgo,
      "libra": AppLocalizations.of(context)!.libra,
      "scorpio": AppLocalizations.of(context)!.scorpio,
      "sagittarius": AppLocalizations.of(context)!.sagittarius,
      "capricorn": AppLocalizations.of(context)!.capricorn,
    };
    int month = dateOfBirth.month - 1;
    int day = dateOfBirth.day - 1;
    if (month == 0 && day <= 20) {
      month = 11;
    } else if (day < days[month]) {
      month--;
    }
    return signLocalizationMap[signs.elementAt(month)]!;
  }

  static Future<Match> fromDoc(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [bool getMessageCount = true]) async {
    return Match._from(snapshot, getMessageCount);
  }

  static Future<Match> fromQuery(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
      [bool getMessageCount = true]) async {
    return Match._from(snapshot, getMessageCount);
  }

  static Future<Match> fromId(String id, [bool getMessageCount = true]) async {
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
    return Match.fromDoc(_matchData, getMessageCount);
  }

  static Future<Match> _from(dynamic snapshot,
      [bool getMessageCount = true]) async {
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
    int _messageCount = 0;
    if (getMessageCount) {
      final _messagesCountRef = await FirebaseFirestore.instance
          .collection('messagesCount')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (_messagesCountRef.exists) {
        final _data = _messagesCountRef.data()!;
        if (_data.containsKey(snapshot.id)) _messageCount = _data[snapshot.id];
      }
    }
    return Match(
      id: snapshot.id,
      name: snapshot.get('name'),
      interests: List<String>.from(snapshot.get('interests')),
      imageData: _imageData,
      dateOfBirth: (snapshot.get('dateOfBirth') as Timestamp).toDate(),
      bio: snapshot.data()['bio'],
      googleUser: _googleUser,
      matchedYou: _matchedYou,
      messageCount: _messageCount,
    );
  }
}
