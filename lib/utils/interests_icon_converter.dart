import 'package:flutter/material.dart';

List<IconData> interestsToIconData(List<String> interests) {
  final List<IconData> _icons = [];
  for (final e in interests) {
    final _normalizedName = e.toLowerCase().replaceAll(" ", "_");
    late IconData _iconData;
    switch (_normalizedName) {
      case "gaming":
        _iconData = Icons.games;
        break;
      case "music":
        _iconData = Icons.music_note;
        break;
      case "beauty":
        _iconData = Icons.face;
        break;
      case "fashion":
        _iconData = Icons.checkroom;
        break;
      case "animals":
        _iconData = Icons.pets;
        break;
      case "movies_&_tv_shows":
        _iconData = Icons.movie;
        break;
      case "fitness":
        _iconData = Icons.fitness_center;
        break;
      case "technology":
        _iconData = Icons.computer;
        break;
      case "recreational_sports":
        _iconData = Icons.sports_baseball;
        break;
      case "photography":
        _iconData = Icons.camera_alt;
        break;
      default:
        throw Exception("Invalid icon " + _normalizedName);
    }
    _icons.add(_iconData);
  }
  return _icons;
}
