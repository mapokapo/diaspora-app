import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

bool userDataEqual(dynamic a, dynamic b) {
  if ((a is String && b is String) ||
      (a is String && b is String?) ||
      ((a is String?) && b is String) ||
      ((a is String?) && b is String?)) {
    return a == b;
  } else if (a is List && (a is! Uint8List?) && b is List && b is! Uint8List?) {
    return listEquals(a, b);
  } else if ((a is Uint8List?) && b is Uint8List?) {
    return a == b;
  } else if ((a is DateTime && b is DateTime) ||
      (a is DateTime && b is Timestamp)) {
    return a.compareTo(b is Timestamp ? b.toDate() : b) == 0;
  } else {
    return a == b;
  }
}
