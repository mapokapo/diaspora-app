import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/match.dart';
import 'package:diaspora_app/constants/message.dart';
import 'package:diaspora_app/state/current_match_notifier.dart';
import 'package:diaspora_app/widgets/partials/chat_message.dart';
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
  List<Message>? _messages;
  bool _loading = false;
  final TextEditingController _textController = TextEditingController();

  Future<List<Message>> _getMessages() async {
    final _messagesRef = FirebaseFirestore.instance.collection('messages');
    final _messages = (await _messagesRef
            .where('senderId', isEqualTo: _match.id)
            .orderBy('sentAt', descending: true)
            .get())
        .docs;
    return _messages.map((e) => Message.from(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    _match = Provider.of<CurrentMatchNotifier>(context, listen: false).match!;
    _getMessages().then((value) {
      setState(() {
        _messages = value;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _messages!.isNotEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noUsersFound))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages!.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          senderName: _match.name,
                          senderId: _messages![index].senderId,
                          imageData: _match.imageData,
                          text: _messages![index].text,
                          sentAt: _messages![index].sentAt,
                        );
                      },
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
                                    hintText:
                                        AppLocalizations.of(context)!.email,
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(
                                          color: Colors.grey.shade300,
                                        ),
                                    border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  debugPrint("Send");
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
}
