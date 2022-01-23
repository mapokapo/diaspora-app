import 'package:diaspora_app/constants/match.dart';
import 'package:flutter/material.dart';

class CurrentMatchNotifier extends ChangeNotifier {
  Match? _match;
  Match? get match => _match;

  void setMatch(Match? newMatch) {
    _match = newMatch;
    notifyListeners();
  }
}
