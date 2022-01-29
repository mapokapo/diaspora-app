import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/match.dart';
import 'package:diaspora_app/constants/option.dart';
import 'package:diaspora_app/constants/user_interests.dart';
import 'package:diaspora_app/utils/user_data_equal.dart';
import 'package:diaspora_app/widgets/partials/form_builder_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:vrouter/vrouter.dart';

class ProfilePage extends StatefulWidget {
  final Match? match;
  const ProfilePage({this.match, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Match? _match;
  DocumentSnapshot<Map<String, dynamic>>? _currentUser;
  Uint8List? _imageData;
  List<Option>? _options;
  final _dialogFormKey = GlobalKey<FormBuilderState>();

  void _loadData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final user =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final _profileImageExists =
        (await FirebaseStorage.instance.ref('profile_images').list())
            .items
            .any((e) => e.name == userId);
    Uint8List? imageData;
    if (_profileImageExists) {
      imageData = await FirebaseStorage.instance
          .ref('profile_images')
          .child(userId)
          .getData();
    }
    final options = [
      Option<String?>(name: 'bio', value: user.data()!['bio']),
      Option<Uint8List?>(name: 'image', value: imageData),
      Option<String>(name: 'name', value: user.get('name')),
      Option<DateTime>(
          name: 'dateOfBirth',
          value: (user.get('dateOfBirth') as Timestamp).toDate()),
      Option<List<String>>(
          name: 'interests', value: List<String>.from(user.get('interests'))),
    ];
    setState(() {
      _imageData = imageData;
      _currentUser = user;
      _options = options;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.match == null) {
      _loadData();
    } else {
      setState(() {
        _match = widget.match;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _currentUser == null && _match == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
                              border: Border.all(),
                              image: _match == null
                                  ? (_imageData != null
                                      ? DecorationImage(
                                          image: MemoryImage(_imageData!),
                                          fit: BoxFit.cover,
                                        )
                                      : FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .providerData
                                                  .first
                                                  .providerId !=
                                              "password"
                                          ? DecorationImage(
                                              image: NetworkImage(FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .photoURL!),
                                            )
                                          : const DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/profile.png")))
                                  : (_match!.imageData != null
                                      ? DecorationImage(
                                          image:
                                              MemoryImage(_match!.imageData!),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/profile.png"))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _match != null
                                      ? _match!.name
                                      : _currentUser!.get('name'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.yearsOld(
                                    (DateTime.now()
                                                .difference(_match != null
                                                    ? _match!.dateOfBirth
                                                    : (_currentUser!.get(
                                                                'dateOfBirth')
                                                            as Timestamp)
                                                        .toDate())
                                                .inDays /
                                            365)
                                        .floor()),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              if (_match == null)
                                Text(
                                  AppLocalizations.of(context)!.matchedUsers(
                                      List<String>.from(
                                              _currentUser!.get('matches'))
                                          .length),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if ((_match != null && _match!.bio != null))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _match!.bio!,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_currentUser != null &&
                    _currentUser!.data()!.containsKey('bio'))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _currentUser!.get('bio'),
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Divider(
                  color: Colors.black,
                ),
                if (_match != null)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.interests +
                                ": " +
                                _match!.interests
                                    .map((e) => getUserInterestLocalizedString(
                                        context, e))
                                    .join(", "),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.sign +
                                ": " +
                                _match!.getLocalizedHoroscope(context),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_match == null)
                  _options == null
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          flex: 2,
                          child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                            itemCount: _options!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  _dialogFormKey.currentState?.reset();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        final _option = _options![index];
                                        return Dialog(
                                          child: FormBuilder(
                                            key: _dialogFormKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  child: Text(
                                                    _option
                                                        .localizedName(context),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16),
                                                  child: (_option.value
                                                              is String ||
                                                          _option.value
                                                              is String?)
                                                      ? FormBuilderTextField(
                                                          name: _option.name,
                                                          initialValue:
                                                              _option.value,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText: _option
                                                                .localizedName(
                                                                    context),
                                                            border:
                                                                const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .black,
                                                                width: 4.0,
                                                              ),
                                                            ),
                                                          ),
                                                          validator:
                                                              FormBuilderValidators
                                                                  .compose([
                                                            FormBuilderValidators.required(
                                                                context,
                                                                errorText: AppLocalizations.of(
                                                                        context)!
                                                                    .fieldRequiredYour(
                                                                        _option
                                                                            .name)),
                                                          ]),
                                                        )
                                                      : (_option.value
                                                              is DateTime)
                                                          ? FormBuilderDateTimePicker(
                                                              name:
                                                                  _option.name,
                                                              initialDate:
                                                                  _option.value,
                                                              inputType:
                                                                  InputType
                                                                      .date,
                                                              decoration:
                                                                  InputDecoration(
                                                                suffixIcon:
                                                                    const Icon(Icons
                                                                        .date_range),
                                                                labelText: _option
                                                                    .localizedName(
                                                                        context),
                                                                border:
                                                                    const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 4.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              validator:
                                                                  FormBuilderValidators
                                                                      .compose([
                                                                FormBuilderValidators.required(
                                                                    context,
                                                                    errorText: AppLocalizations.of(
                                                                            context)!
                                                                        .fieldRequiredYour(
                                                                            _option.name)),
                                                              ]),
                                                            )
                                                          : (_option.value
                                                                  is Uint8List?)
                                                              ? FormBuilderImagePicker(
                                                                  name: _option
                                                                      .name,
                                                                  initialValue:
                                                                      _option
                                                                          .value,
                                                                )
                                                              : (_option.value
                                                                          is List &&
                                                                      _option.value
                                                                          is! Uint8List?)
                                                                  ? FormBuilderCheckboxGroup<
                                                                      String>(
                                                                      name: _option
                                                                          .name,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            _option.localizedName(context),
                                                                        border:
                                                                            const OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Colors.black,
                                                                            width:
                                                                                4.0,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      initialValue: List<
                                                                              String>.from(
                                                                          _option
                                                                              .value),
                                                                      options: userInterests
                                                                          .map((e) => FormBuilderFieldOption(
                                                                                value: e.toLowerCase().replaceAll(" ", "_"),
                                                                                child: Text(
                                                                                  getUserInterestLocalizedString(context, e),
                                                                                ),
                                                                              ))
                                                                          .toList(),
                                                                    )
                                                                  : null,
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .cancel),
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .submit),
                                                      onPressed: () async {
                                                        if (_dialogFormKey
                                                                .currentState
                                                                ?.saveAndValidate() ??
                                                            false) {
                                                          var _updated = false;
                                                          final data = Map<
                                                                  String,
                                                                  dynamic>.from(
                                                              _dialogFormKey
                                                                  .currentState!
                                                                  .value);
                                                          final imageData =
                                                              data.remove(
                                                                      'image')
                                                                  as Uint8List?;
                                                          if (data.isNotEmpty &&
                                                              !userDataEqual(
                                                                  data[data.keys
                                                                      .first],
                                                                  _currentUser!
                                                                          .data()![
                                                                      data.keys
                                                                          .first])) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .update(data);
                                                            _updated = true;
                                                          }
                                                          if (imageData !=
                                                              _imageData) {
                                                            final _imageRef = FirebaseStorage
                                                                .instance
                                                                .ref(
                                                                    'profile_images')
                                                                .child(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid);
                                                            if (imageData ==
                                                                null) {
                                                              await _imageRef
                                                                  .delete();
                                                            } else {
                                                              await _imageRef
                                                                  .putData(
                                                                      imageData);
                                                            }
                                                            _updated = true;
                                                          }
                                                          Navigator.of(context)
                                                              .pop();
                                                          if (_updated) {
                                                            setState(() {
                                                              _currentUser =
                                                                  null;
                                                              _imageData = null;
                                                              _options = null;
                                                            });
                                                            _loadData();
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                title: Text(
                                  _options![index].localizedName(context),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                trailing: _options![index].valueShowable()
                                    ? Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 150,
                                        ),
                                        child: Text(
                                          _options![index].stringValue,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                if (_match == null)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                                AppLocalizations.of(context)!.deleteAccount),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppLocalizations.of(context)!
                                    .deleteAccountText),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context)!.cancel),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child:
                                    Text(AppLocalizations.of(context)!.confirm),
                                onPressed: () async {
                                  final _uid =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  final _usersRef = FirebaseFirestore.instance
                                      .collection('users');
                                  final _messagesRef = FirebaseFirestore
                                      .instance
                                      .collection('messages');
                                  try {
                                    final _matchedUsers = await _usersRef
                                        .where('matches', arrayContains: _uid)
                                        .get();
                                    for (final _matchedUser
                                        in _matchedUsers.docs) {
                                      await _usersRef
                                          .doc(_matchedUser.id)
                                          .update({
                                        'matches':
                                            FieldValue.arrayRemove([_uid]),
                                      });
                                    }
                                    final _sentMessages = await _messagesRef
                                        .where('senderId', isEqualTo: _uid)
                                        .get();
                                    final _receivedMessages = await _messagesRef
                                        .where('receiverId', isEqualTo: _uid)
                                        .get();
                                    for (final _message in _sentMessages.docs
                                      ..addAll(_receivedMessages.docs)) {
                                      await _messagesRef
                                          .doc(_message.id)
                                          .delete();
                                    }
                                    await _usersRef.doc(_uid).delete();
                                    final _imageExists = (await FirebaseStorage
                                            .instance
                                            .ref('profile_images')
                                            .list())
                                        .items
                                        .any((ref) => ref.name == _uid);
                                    if (_imageExists) {
                                      await FirebaseStorage.instance
                                          .ref('profile_images')
                                          .child(_uid)
                                          .delete();
                                    }
                                    await FirebaseAuth.instance.currentUser!
                                        .delete();
                                    context.vRouter
                                        .to('/', isReplacement: true);
                                  } on FirebaseAuthException catch (e) {
                                    final code = e.code;
                                    String? errStr;
                                    if (code == "requires-recent-login") {
                                      errStr = AppLocalizations.of(context)!
                                          .requiresRecentLogin;
                                    }
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(errStr ??
                                          e.message ??
                                          AppLocalizations.of(context)!.error),
                                    ));
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.deleteAccount.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
              ],
            ),
          );
  }
}
