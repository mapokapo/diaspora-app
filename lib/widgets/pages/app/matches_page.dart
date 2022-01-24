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

  Future<List<Match>> _getMatches() async {
    final _messagesCollection =
        FirebaseFirestore.instance.collection('messages');
    final _usersRef = FirebaseFirestore.instance.collection('users');
    final _currentUser =
        await _usersRef.doc(FirebaseAuth.instance.currentUser!.uid).get();
    final _matchedIds = List<String>.from(_currentUser.get('matches'));
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
    List<QueryDocumentSnapshot<Map<String, dynamic>>> _matchedQuerySnapshots =
        [];
    if (_matchedIds.isNotEmpty) {
      // TODO
      // if _matchedIds is > 10, crashes
      _matchedQuerySnapshots = (await _usersRef
              .where(FieldPath.documentId, whereIn: _matchedIds)
              .get())
          .docs;
    }
    final List<Match> _matches = [];
    for (final s in _matchedQuerySnapshots) {
      final _match = await Match.from(s);
      _matches.add(_match);
    }

    return _matches;
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    _getMatches().then((value) {
      setState(() {
        _matches = value;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _matches!.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noUsersFound))
              : ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: _matches!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Provider.of<CurrentMatchNotifier>(context,
                                listen: false)
                            .setMatch(_matches![index]);
                        context.vRouter.to('chat');
                      },
                      leading: UserAvatar(_matches![index].imageData),
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
                          ...interestsToIconData(_matches![index].interests)
                              .map((e) => Icon(
                                    e,
                                    size: 20,
                                  ))
                              .take(3)
                              .toList()
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    );
                  },
                ),
    );
  }
}
