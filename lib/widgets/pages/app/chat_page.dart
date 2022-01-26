import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/match.dart';
import 'package:diaspora_app/constants/message.dart';
import 'package:diaspora_app/state/current_match_notifier.dart';
import 'package:diaspora_app/widgets/partials/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Match _match;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream;
  DocumentSnapshot<Map<String, dynamic>>? _currentUser;
  final TextEditingController _textController = TextEditingController();

  Stream<QuerySnapshot<Map<String, dynamic>>> _getMessagesStream() {
    final _messagesRef = FirebaseFirestore.instance.collection('messages');
    final _messagesStream = _messagesRef
        .where('senderId',
            whereIn: [_match.id, FirebaseAuth.instance.currentUser!.uid])
        .orderBy('sentAt', descending: true)
        .snapshots();
    return _messagesStream;
  }

  @override
  void initState() {
    super.initState();
    _match = Provider.of<CurrentMatchNotifier>(context, listen: false).match!;
    _messagesStream = _getMessagesStream();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        _currentUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: snapshot.hasData
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView(
                                  reverse: true,
                                  children: [
                                    ...snapshot.data!.docs
                                        .asMap()
                                        .map(
                                          (i, e) {
                                            final _message = Message.from(e);
                                            return MapEntry(
                                              i,
                                              ChatMessage(
                                                senderName: _message.senderId ==
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid
                                                    ? _currentUser!.get('name')
                                                    : _match.name,
                                                senderId: _message.senderId,
                                                imageData: _match.imageData,
                                                text: _message.text,
                                                sentAt: _message.sentAt,
                                                prevMessage: i + 1 >=
                                                        snapshot
                                                            .data!.docs.length
                                                    ? null
                                                    : Message.from(
                                                        snapshot
                                                            .data!.docs[i + 1],
                                                      ),
                                              ),
                                            );
                                          },
                                        )
                                        .values
                                        .toList()
                                  ],
                                ),
                              )
                            : Center(
                                child: Text(
                                    AppLocalizations.of(context)!.noMessages),
                              ),
                      ),
                      Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _textController,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.go,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .copyWith(
                                            color: Colors.white,
                                          ),
                                      decoration: InputDecoration(
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .primaryVariant,
                                        filled: true,
                                        hintText: AppLocalizations.of(context)!
                                            .typeMessage,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .copyWith(
                                              color: Colors.grey.shade300,
                                            ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () async {
                                      final _message =
                                          _textController.text.trim();
                                      if (_message.isNotEmpty) {
                                        final _messagesCollection =
                                            FirebaseFirestore.instance
                                                .collection('messages');
                                        final _userRef = FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid);
                                        final _currentUser =
                                            await _userRef.get();
                                        await _messagesCollection.add({
                                          'senderId': FirebaseAuth
                                              .instance.currentUser!.uid,
                                          'receiverId': _match.id,
                                          'text': _message,
                                          'sentAt': DateTime.now(),
                                        });
                                        if (!List<String>.from(
                                                _currentUser.get('matches'))
                                            .contains(_match.id)) {
                                          await _userRef.update({
                                            'matches': FieldValue.arrayUnion(
                                                [_match.id]),
                                          });
                                        }
                                        _textController.clear();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.send,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryVariant,
                                      size: 32,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }),
    );
  }
}
