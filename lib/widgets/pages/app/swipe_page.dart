import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/match.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  List<Match>? _matches;
  bool _loading = false;

  Future<List<Match>> _getMatches() async {
    // get users aged age-2 to age+2, where age is the current user's age
    // get users with the same interests as the current user
    final firestore = FirebaseFirestore.instance;
    final usersCollection = firestore.collection('users');
    final currentUser =
        await usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).get();
    DateTime currentUserDoB =
        (currentUser.get('dateOfBirth') as Timestamp).toDate();
    final _matches = (await usersCollection
            .where(
              'dateOfBirth',
              isGreaterThan: Timestamp.fromDate(
                  currentUserDoB.subtract(const Duration(days: 365 * 2))),
              isLessThan: Timestamp.fromDate(
                  currentUserDoB.add(const Duration(days: 365 * 2))),
            )
            .where('interests', arrayContainsAny: currentUser.get('interests'))
            .get())
        .docs
        .where((e) => e.id != FirebaseAuth.instance.currentUser!.uid)
        .where((e) =>
            !List<String>.from(currentUser.get('matches')).contains(e.id))
        .toList();
    // Not enough matches - get random users instead
    if (_matches.length < 10) {
      // add every matched user's id, the current user's id, and every user id the current user has ever matched with
      final _filterMatchIds = _matches.map((e) => e.id).toList()
        ..add(FirebaseAuth.instance.currentUser!.uid)
        ..addAll(List<String>.from(currentUser.get('matches')));
      // then get extra matches which are NOT in matchIds - this guarantees novel matches for the current user
      final extraMatches = (await usersCollection
              .where(FieldPath.documentId, whereNotIn: _filterMatchIds)
              .limit(10 - _matches.length)
              .get())
          .docs;
      _matches.addAll(extraMatches);
    }

    List<Match> _newMatches = [];
    for (final s in _matches) {
      final _match = await Match.fromQuery(s);
      _newMatches.add(_match);
    }

    return _newMatches;
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    _getMatches().then((value) async {
      setState(() {
        _matches = value;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _matches!.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noUsersFound))
            : Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).colorScheme.secondaryVariant,
                      size: 32,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.secondaryVariant,
                      size: 32,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TinderSwapCard(
                      cardBuilder: (context, index) {
                        return Material(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          clipBehavior: Clip.hardEdge,
                          elevation: 4,
                          color: Theme.of(context).colorScheme.primary,
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              _matches![index].imageData != null
                                  ? Padding(
                                      padding: EdgeInsets.all(
                                          _matches![index].googleUser
                                              ? 48.0
                                              : 0),
                                      child: Image.memory(
                                        _matches![index].imageData!,
                                        fit: _matches![index].googleUser
                                            ? BoxFit.contain
                                            : BoxFit.fitHeight,
                                      ),
                                    )
                                  : Image.asset('assets/images/profile.png'),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    Icons.delete,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 32,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    Icons.favorite,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 32,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .primaryVariant,
                                        Colors.transparent,
                                        Colors.transparent,
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _matches![index].name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3!
                                              .copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: Text(
                                            (AppLocalizations.of(context)!
                                                    .interests +
                                                ": " +
                                                _matches![index]
                                                    .interests
                                                    .join(", ")),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(
                                                  color: Colors.white,
                                                ),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      totalNum: _matches!.length,
                      allowVerticalMovement: false,
                      orientation: AmassOrientation.bottom,
                      stackNum: 3,
                      swipeEdge: 4.0,
                      swipeUp: true,
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                      minHeight: MediaQuery.of(context).size.width * 0.5,
                      swipeCompleteCallback: (orientation, index) async {
                        if (orientation == CardSwipeOrientation.right) {
                          final _userRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid);
                          await _userRef.update({
                            'matches':
                                FieldValue.arrayUnion([_matches![index].id]),
                          });
                        }
                        if (orientation != CardSwipeOrientation.recover) {
                          setState(() {
                            _matches = _matches!
                                .where((e) => e.id != _matches![index].id)
                                .toList();
                          });
                        }
                      },
                    ),
                  ),
                ],
              );
  }
}
