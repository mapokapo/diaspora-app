import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MatchSelectionNotifier extends ChangeNotifier {
  Set<String?> _selectedIds = {};
  Set<String?> get selectedIds => _selectedIds;
  bool changed = false;

  void setSelectedIds(Set<String?> newSelectedIds) {
    _selectedIds = newSelectedIds;
    notifyListeners();
  }

  void addId(String id) {
    _selectedIds.add(id);
    notifyListeners();
  }

  void addOrRemove(String id, [bool? shouldAdd]) {
    if (shouldAdd == null) {
      final _idExists = _selectedIds.contains(id);
      if (_idExists) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    } else {
      if (shouldAdd) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    }
    notifyListeners();
  }

  void removeId(String id) {
    _selectedIds.remove(id);
    notifyListeners();
  }

  void removeIds() {
    _selectedIds.clear();
    notifyListeners();
  }

  Future<void> deleteMatches() async {
    if (_selectedIds.isEmpty) {
      return;
    }
    final _userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final _messagesRef = FirebaseFirestore.instance.collection('messages');
    final _receivedMessages = await _messagesRef
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final _sentMessages = await _messagesRef
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    await _userRef
        .update({'matches': FieldValue.arrayRemove(_selectedIds.toList())});
    for (final _receivedMessage in _receivedMessages.docs) {
      if (_selectedIds.contains(_receivedMessage.get('senderId'))) {
        await _messagesRef.doc(_receivedMessage.id).delete();
      }
    }
    for (final _sentMessage in _sentMessages.docs) {
      if (_selectedIds.contains(_sentMessage.get('receiverId'))) {
        await _messagesRef.doc(_sentMessage.id).delete();
      }
    }
    _selectedIds.clear();
    changed = true;
    notifyListeners();
  }

  bool selectionMode() {
    return _selectedIds.isNotEmpty;
  }

  bool contains(String id) {
    return _selectedIds.contains(id);
  }
}
