import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class Option<T> {
  String name;
  T? value;

  String get stringValue {
    if (value is String) {
      return value.toString();
    } else if (value is List && value is! Uint8List?) {
      final _string = (List<String>.from(value as List))
          .map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
          .join(", ");
      return _string;
    } else if (value is DateTime) {
      return DateFormat('yyyy-MM-dd').format(value as DateTime);
    } else {
      return "Null";
    }
  }

  bool valueShowable() {
    return value != null && value is! Uint8List;
  }

  Option({required this.name, this.value});

  String localizedName(BuildContext context) {
    switch (name) {
      case 'image':
        return AppLocalizations.of(context)!.change +
            " " +
            AppLocalizations.of(context)!.profileImage.toLowerCase();
      case 'bio':
        return AppLocalizations.of(context)!.change +
            " " +
            AppLocalizations.of(context)!.bio.toLowerCase();
      case 'name':
        return AppLocalizations.of(context)!.change +
            " " +
            AppLocalizations.of(context)!.name.toLowerCase();
      case 'password':
        return AppLocalizations.of(context)!.change +
            " " +
            AppLocalizations.of(context)!.password.toLowerCase();
      case 'dateOfBirth':
        return AppLocalizations.of(context)!.change +
            " " +
            AppLocalizations.of(context)!.dateOfBirth.toLowerCase();
      case 'interests':
        return AppLocalizations.of(context)!.change +
            " " +
            AppLocalizations.of(context)!.interests.toLowerCase();
      default:
        throw Exception("Invalid name in Option");
    }
  }
}
