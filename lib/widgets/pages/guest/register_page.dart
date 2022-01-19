import 'dart:io';

import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:vrouter/vrouter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  File? _image;
  bool _uploading = false;
  String? _error;

  Future<void> _handleRegister(
      String name, String email, String password) async {
    try {
      final user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password))
          .user!;
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref("profile_images")
            .child(user.uid + path.extension(_image!.path));
        UploadTask uploadTask = ref.putFile(_image!);
        setState(() {
          _uploading = true;
        });
        uploadTask.whenComplete(() {
          setState(() {
            _uploading = false;
          });
          context.vRouter.to("/app", isReplacement: true);
        });
      } else {
        context.vRouter.to("/app", isReplacement: true);
      }
    } on FirebaseAuthException catch (e) {
      final code = e.code.split("/").last;
      String? errStr;
      if (code == "email-already-in-use") {
        errStr = AppLocalizations.of(context)!.emailAlreadyInUse;
      } else if (code == "invalid-email") {
        errStr = AppLocalizations.of(context)!.fieldInvalid("email");
      } else if (code == "weak-password") {
        errStr = AppLocalizations.of(context)!.weakPassword;
      } else if (code == "operation-not-allowed") {
        errStr = AppLocalizations.of(context)!.operationNotAllowed;
      }
      if (errStr != null) {
        _formKey.currentState!
            .invalidateField(name: 'email', errorText: errStr);
      } else {
        setState(() {
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    FormBuilderField(
                      builder: (state) {
                        return InkWell(
                          onTap: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                                source: ImageSource.gallery);
                            setState(() {
                              _image = image != null ? File(image.path) : null;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 96),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  image: _image != null
                                      ? DecorationImage(
                                          image: FileImage(_image!),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/profile.png')),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryVariant),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      name: 'image',
                    ),
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
                    // TODO
                    // Proper focus shift on "enter" button pressed
                    FormBuilderTextField(
                      name: 'name',
                      keyboardType: TextInputType.name,
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
                                .fieldRequired('name')),
                        FormBuilderValidators.match(context, r'\w+( +\w+)*',
                            errorText: AppLocalizations.of(context)!
                                .fieldInvalid('name')),
                      ]),
                    ),
                    const SizedBox(height: 16.0),
                    FormBuilderTextField(
                      name: 'email',
                      keyboardType: TextInputType.emailAddress,
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
                                .fieldRequired('email')),
                        FormBuilderValidators.email(context,
                            errorText: AppLocalizations.of(context)!
                                .fieldInvalid('email')),
                      ]),
                    ),
                    const SizedBox(height: 16.0),
                    FormBuilderTextField(
                      name: 'password',
                      keyboardType: TextInputType.text,
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
                                values['name'].toString().trim(),
                                values['email'].toString().trim(),
                                values['password'].toString().trim());
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
                                    AppLocalizations.of(context)!.hasAccount,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
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
    );
  }
}
