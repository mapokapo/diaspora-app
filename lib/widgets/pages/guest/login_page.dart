import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:vrouter/vrouter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  String? _error;

  Future<void> _handleLogin(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      context.vRouter.to('/app', isReplacement: true);
    } on FirebaseAuthException catch (e) {
      final code = e.code;
      String? errStr;
      if (code == "invalid-email") {
        errStr = AppLocalizations.of(context)!.fieldInvalid('email');
      } else if (code == "user-disabled") {
        errStr = AppLocalizations.of(context)!.userDisabled;
      } else if (code == "user-not-found") {
        errStr = AppLocalizations.of(context)!.userNotFound;
      } else if (code == "wrong-password") {
        errStr = AppLocalizations.of(context)!.wrongPassword;
      }
      if (errStr != null) {
        _formKey.currentState!
            .invalidateField(name: 'email', errorText: errStr);
      } else {
        setState(() {
          _error = e.message!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context)!.log('in').toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .headline1
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
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
          FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                // TODO
                // Proper focus shift on "enter" button pressed
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
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          AuthButton(
            title: AppLocalizations.of(context)!.submit,
            onClick: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                await _handleLogin(_formKey.currentState?.value['email'],
                    _formKey.currentState?.value['password']);
              }
            },
          ),
          KeyboardVisibilityBuilder(
            builder: (context, keyboardVisible) => keyboardVisible
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 16.0),
                      TextButton(
                        onPressed: () {
                          context.vRouter.to('/register', isReplacement: true);
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(12.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.hasNoAccount,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextButton(
                        onPressed: () {
                          context.vRouter.to("/forgot_password");
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(12.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
