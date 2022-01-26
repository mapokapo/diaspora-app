import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/state/current_match_notifier.dart';
import 'package:diaspora_app/utils/interests_icon_converter.dart';
import 'package:diaspora_app/constants/match.dart';
import 'package:diaspora_app/widgets/partials/user_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({Key? key}) : super(key: key);

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  List<Match>? _matches;
  bool _loading = false;
  DocumentSnapshot<Map<String, dynamic>>? _currentUser;

  Future<List<Match>> _getMatches() async {
    final _messagesCollection =
        FirebaseFirestore.instance.collection('messages');
    final _usersRef = FirebaseFirestore.instance.collection('users');
    final _currentUser =
        await _usersRef.doc(FirebaseAuth.instance.currentUser!.uid).get();
    final _matchedIds = Set<String>.from(_currentUser.get('matches'));
    final _sentMessages = await _messagesCollection
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    final _receivedMessages = await _messagesCollection
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    _matchedIds.addAll((_sentMessages.docs..addAll(_receivedMessages.docs)).map(
        (e) => e.get('senderId') == FirebaseAuth.instance.currentUser!.uid
            ? e.get('receiverId')
            : e.get('senderId')));
    List<DocumentSnapshot<Map<String, dynamic>>> _matchedSnapshots = [];
    for (final id in _matchedIds) {
      _matchedSnapshots.add((await _usersRef.doc(id).get()));
    }
    final List<Match> _matches = [];
    for (final s in _matchedSnapshots) {
      final _match = await Match.fromDoc(s);
      _matches.add(_match);
    }

    return _matches;
  }

  Future<void> _loadData([bool firstRun = false]) async {
    if (!firstRun) {
      setState(() {
        _loading = true;
      });
    }
    final _user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final _m = await _getMatches();
    setState(() {
      _matches = _m;
      _currentUser = _user;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadData(true);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await Future.delayed(const Duration(milliseconds: 200));
      },
      child: _loading || _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : _matches!.isEmpty
              ? Center(
                  child: Text(AppLocalizations.of(context)!.hasMatches('no')))
              : Column(
                  children: [
                    if (List<String>.from(_currentUser!.get('matches'))
                            .isNotEmpty &&
                        _matches!.any((e) => e.matchedYou))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          AppLocalizations.of(context)!.hasMatches('yes'),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemCount: _matches!.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_matches![index].matchedYou &&
                                    !List<String>.from(
                                            _currentUser!.get('matches'))
                                        .contains(_matches![index].id))
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 8),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .userMatched('no'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .copyWith(
                                            color: Colors.red,
                                          ),
                                    ),
                                  ),
                                ListTile(
                                  onTap: () {
                                    Provider.of<CurrentMatchNotifier>(context,
                                            listen: false)
                                        .setMatch(_matches![index]);
                                    context.vRouter.to('chat');
                                  },
                                  leading:
                                      UserAvatar(_matches![index].imageData),
                                  title: Text(
                                    _matches![index].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ...interestsToIconData(
                                              _matches![index].interests)
                                          .map((e) => Icon(
                                                e,
                                                size: 20,
                                              ))
                                          .take(3)
                                          .toList(),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
