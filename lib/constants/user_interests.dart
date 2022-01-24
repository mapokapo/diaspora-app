import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const List<String> userInterests = [
  "Gaming",
  "Music",
  "Beauty",
  "Fashion",
  "Animals",
  "Movies & TV Shows",
  "Fitness",
  "Technology",
  "Recreational Sports",
  "Photography",
];

String getUserInterestLocalizedString(BuildContext context, String interest) {
  final _normalizedName = interest.toLowerCase().replaceAll(" ", "_");
  late String _localizedString;
  switch (_normalizedName) {
    case "gaming":
      _localizedString = AppLocalizations.of(context)!.gaming;
      break;
    case "music":
      _localizedString = AppLocalizations.of(context)!.music;
      break;
    case "beauty":
      _localizedString = AppLocalizations.of(context)!.beauty;
      break;
    case "fashion":
      _localizedString = AppLocalizations.of(context)!.fashion;
      break;
    case "animals":
      _localizedString = AppLocalizations.of(context)!.animals;
      break;
    case "movies_&_tv_shows":
      _localizedString = AppLocalizations.of(context)!.moviesTVShows;
      break;
    case "fitness":
      _localizedString = AppLocalizations.of(context)!.fitness;
      break;
    case "technology":
      _localizedString = AppLocalizations.of(context)!.technology;
      break;
    case "recreational_sports":
      _localizedString = AppLocalizations.of(context)!.recreationalSports;
      break;
    case "photography":
      _localizedString = AppLocalizations.of(context)!.photography;
      break;
  }
  return _localizedString;
}
