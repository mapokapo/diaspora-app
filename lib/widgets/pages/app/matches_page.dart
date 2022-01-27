import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/state/current_match_notifier.dart';
import 'package:diaspora_app/state/match_selection_provider.dart';
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
  bool _noMatches = false;
  DocumentSnapshot<Map<String, dynamic>>? _currentUser;

  Future<List<Match>> _getMatches(int page) async {
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
    final _idsToFetch = _matchedIds.skip(page * 10).take(10).toList();
    if (_idsToFetch.isNotEmpty) {
      final _matchesToAdd = (await _usersRef
              .where(FieldPath.documentId, whereIn: _idsToFetch)
              .get())
          .docs;
      _matchedSnapshots.addAll(_matchesToAdd);
    }
    final List<Match> matches = [];
    for (final s in _matchedSnapshots) {
      final _match = await Match.fromDoc(s);
      matches.add(_match);
    }

    return matches;
  }

  Future<void> _loadData(
      [int page = 0,
      bool firstRun = false,
      bool disableLoading = false]) async {
    if (!firstRun) {
      if (!disableLoading) {
        setState(() {
          _currentUser = null;
          _matches = null;
        });
      }
      _noMatches = false;
    }
    final _user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final _m = await _getMatches(page);
    setState(() {
      if (_matches == null ||
          (firstRun &&
              !_m.any((e) => _matches!.map((s) => s.id).contains(e.id)))) {
        _matches = _matches != null ? (_matches! + _m) : _m;
      } else {
        _noMatches = true;
      }
      _currentUser = _user;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData(0, true);
  }

  @override
  Widget build(BuildContext context) {
    final _matchesChanged =
        Provider.of<MatchSelectionNotifier>(context).changed;
    if (_matchesChanged) {
      Provider.of<MatchSelectionNotifier>(context).changed = false;
      _loadData();
    }
    return RefreshIndicator(
      onRefresh: () async {
        if (Provider.of<MatchSelectionNotifier>(context, listen: false)
            .selectionMode()) return;
        _loadData();
        await Future.delayed(const Duration(milliseconds: 200));
      },
      child: _matchesChanged || _currentUser == null || _matches == null
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
                          itemCount: _matches!.length + (_noMatches ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index == _matches!.length) {
                              _loadData((index / 9).floor(), false, true);
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(),
                                ],
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_matches![index].matchedYou &&
                                      !List<String>.from(
                                              _currentUser!.get('matches'))
                                          .contains(_matches![index].id))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, top: 8),
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
                                    onLongPress: () {
                                      Provider.of<MatchSelectionNotifier>(
                                              context,
                                              listen: false)
                                          .addId(_matches![index].id);
                                    },
                                    onTap: () {
                                      if (Provider.of<MatchSelectionNotifier>(
                                              context,
                                              listen: false)
                                          .selectionMode()) {
                                        Provider.of<MatchSelectionNotifier>(
                                                context,
                                                listen: false)
                                            .addOrRemove(_matches![index].id);
                                      } else {
                                        Provider.of<CurrentMatchNotifier>(
                                                context,
                                                listen: false)
                                            .setMatch(_matches![index]);
                                        context.vRouter.to('chat');
                                      }
                                    },
                                    leading: Provider.of<
                                                MatchSelectionNotifier>(context)
                                            .selectionMode()
                                        ? Checkbox(
                                            value: Provider.of<
                                                        MatchSelectionNotifier>(
                                                    context)
                                                .contains(_matches![index].id),
                                            onChanged: (newValue) {
                                              Provider.of<MatchSelectionNotifier>(
                                                      context,
                                                      listen: false)
                                                  .addOrRemove(
                                                      _matches![index].id,
                                                      newValue);
                                            })
                                        : UserAvatar(
                                            _matches![index].imageData),
                                    title: Text(
                                      _matches![index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
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
                                    trailing:
                                        Provider.of<MatchSelectionNotifier>(
                                                    context)
                                                .selectionMode()
                                            ? const Icon(Icons.chevron_right)
                                            : null,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
