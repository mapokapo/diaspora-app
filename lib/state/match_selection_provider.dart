import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/match.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MatchSelectionNotifier extends ChangeNotifier {
  Set<int?> _selectedIndexes = {};
  List<Match>? _matches;
  Set<int?> get selectedIndexes => _selectedIndexes;
  set matches(List<Match> matches) {
    _matches = matches;
  }

  void setSelectionIndexes(Set<int?> newSelectionIndexes) {
    _selectedIndexes = newSelectionIndexes;
    notifyListeners();
  }

  void addIndex(int index) {
    _selectedIndexes.add(index);
    notifyListeners();
  }

  void addOrRemove(int index, [bool? shouldAddIndex]) {
    debugPrint("shouldAddIndex.toString()");
    if (shouldAddIndex == null) {
      final _indexExists = _selectedIndexes.contains(index);
      if (_indexExists) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    } else {
      if (shouldAddIndex) {
        _selectedIndexes.add(index);
      } else {
        _selectedIndexes.remove(index);
      }
    }
    notifyListeners();
  }

  void removeIndex(int index) {
    _selectedIndexes.remove(index);
    notifyListeners();
  }

  void removeIndexes() {
    _selectedIndexes.clear();
    notifyListeners();
  }

  Future<void> deleteMatches() async {
    if (_selectedIndexes.isEmpty || _matches == null || _matches!.isEmpty) {
      return;
    }
    final _userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await _userRef.update({
      'matches': FieldValue.arrayRemove(_matches!.map((e) => e.id).toList())
    });
    _selectedIndexes.clear();
    _matches?.clear();
    notifyListeners();
  }

  bool selectionMode() {
    return _selectedIndexes.isNotEmpty;
  }

  bool contains(int index) {
    return _selectedIndexes.contains(index);
  }
}
