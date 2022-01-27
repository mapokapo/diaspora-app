import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/user_interests.dart';
import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:diaspora_app/widgets/partials/form_builder_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:vrouter/vrouter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _uploading = false;
  String? _error;

  Future<void> _handleRegister(Uint8List? imageData, String name, String? email,
      String? password, DateTime dateOfBirth, List<String> interests,
      [String? uid, String? imageUrl]) async {
    try {
      User? user;
      if (email != null && password != null) {
        user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email, password: password))
            .user!;
      }
      final firestore = FirebaseFirestore.instance;
      final userRef =
          firestore.collection('users').doc(user != null ? user.uid : uid!);
      await userRef.set({
        'name': name,
        'dateOfBirth': dateOfBirth,
        'interests': interests,
        'matches': [],
        'imageUrl': imageData == null ? imageUrl : null,
        'deviceToken': await FirebaseMessaging.instance.getToken(),
      });
      if (imageData != null) {
        final ref = FirebaseStorage.instance
            .ref("profile_images")
            .child(user != null ? user.uid : uid!);
        UploadTask uploadTask = ref.putFile(File.fromRawPath(imageData));
        setState(() {
          _uploading = true;
        });
        uploadTask.whenComplete(() async {
          context.vRouter.to("/app", isReplacement: true, historyState: {});
          await FirebaseMessaging.instance.requestPermission();
        });
      } else {
        context.vRouter.to("/app", isReplacement: true, historyState: {});
        await FirebaseMessaging.instance.requestPermission();
      }
    } on FirebaseAuthException catch (e) {
      final code = e.code.split("/").last;
      String? errStr, field;
      if (code == "email-already-in-use") {
        errStr = AppLocalizations.of(context)!.emailAlreadyInUse;
        field = 'email';
      } else if (code == "invalid-email") {
        errStr = AppLocalizations.of(context)!.fieldInvalid("email");
        field = 'email';
      } else if (code == "weak-password") {
        errStr = AppLocalizations.of(context)!.weakPassword;
        field = 'password';
      } else if (code == "operation-not-allowed") {
        errStr = AppLocalizations.of(context)!.operationNotAllowed;
      }
      if (errStr != null && field != null) {
        _formKey.currentState!.invalidateField(name: field, errorText: errStr);
      } else if (errStr != null && field == null) {
        setState(() {
          _error = errStr;
        });
      } else {
        setState(() {
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _uploading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.register.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const FormBuilderImagePicker(name: 'image'),
                        if (_error == null) const SizedBox(height: 32),
                        if (_error != null) const SizedBox(height: 8),
                        if (_error != null)
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: Theme.of(context).errorColor),
                          ),
                        if (_error != null) const SizedBox(height: 8),
                        FormBuilderTextField(
                          initialValue: context.vRouter.queryParameters['name'],
                          name: 'name',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.name,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 4.0,
                              ),
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context,
                                errorText: AppLocalizations.of(context)!
                                    .fieldRequiredYour('name')),
                            FormBuilderValidators.match(context, r'\w+( +\w+)*',
                                errorText: AppLocalizations.of(context)!
                                    .fieldInvalid('name')),
                          ]),
                        ),
                        if (!context.vRouter.queryParameters
                            .containsKey('name'))
                          const SizedBox(height: 16.0),
                        if (!context.vRouter.queryParameters
                            .containsKey('name'))
                          FormBuilderTextField(
                            name: 'email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.email,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 4.0,
                                ),
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context,
                                  errorText: AppLocalizations.of(context)!
                                      .fieldRequiredYour('email')),
                              FormBuilderValidators.email(context,
                                  errorText: AppLocalizations.of(context)!
                                      .fieldInvalid('email')),
                            ]),
                          ),
                        if (!context.vRouter.queryParameters
                            .containsKey('name'))
                          const SizedBox(height: 16.0),
                        if (!context.vRouter.queryParameters
                            .containsKey('name'))
                          FormBuilderTextField(
                            name: 'password',
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 4.0,
                                ),
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context,
                                  errorText: AppLocalizations.of(context)!
                                      .fieldRequired('password')),
                              FormBuilderValidators.minLength(context, 6,
                                  errorText: AppLocalizations.of(context)!
                                      .passwordLengthError),
                            ]),
                          ),
                        const SizedBox(height: 16),
                        FormBuilderDateTimePicker(
                          name: 'dateOfBirth',
                          inputType: InputType.date,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.date_range),
                            labelText:
                                AppLocalizations.of(context)!.dateOfBirth,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 4.0,
                              ),
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context,
                                errorText: AppLocalizations.of(context)!
                                    .fieldRequiredYour('dateOfBirth')),
                          ]),
                          timePickerInitialEntryMode: TimePickerEntryMode.input,
                        ),
                        const SizedBox(height: 16.0),
                        FormBuilderCheckboxGroup<String>(
                          name: 'interests',
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.yourInterests,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 4.0,
                              ),
                            ),
                          ),
                          options: [
                            ...userInterests.map((e) {
                              return FormBuilderFieldOption(
                                  child: Text(
                                    getUserInterestLocalizedString(context, e),
                                  ),
                                  value: e.toLowerCase().replaceAll(" ", "_"));
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AuthButton(
                            title: AppLocalizations.of(context)!.submit,
                            onClick: () async {
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                final values = _formKey.currentState!.value;
                                await _handleRegister(
                                  values['image'],
                                  values['name'],
                                  values['email'],
                                  values['password'],
                                  DateTime.parse(
                                      values['dateOfBirth'].toString()),
                                  values['interests'] as List<String>,
                                  context.vRouter.queryParameters['uid'],
                                  context.vRouter.queryParameters['photoUrl'],
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        KeyboardVisibilityBuilder(
                          builder: (context, keyboardVisible) => keyboardVisible
                              ? const SizedBox()
                              : Column(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        context.vRouter
                                            .to('/login', isReplacement: true);
                                      },
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.all(12.0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .hasAccount,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
