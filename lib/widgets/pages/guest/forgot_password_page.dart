import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.forgotPasswordText1,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
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
                FormBuilderTextField(
                  name: 'email',
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context,
                        errorText: AppLocalizations.of(context)!
                            .fieldRequired("email")),
                    FormBuilderValidators.email(context,
                        errorText: AppLocalizations.of(context)!
                            .fieldInvalid("email")),
                  ]),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 4.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          AuthButton(
            title: AppLocalizations.of(context)!.submit,
            onClick: () async {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _formKey.currentState!.value['email']);
                } on FirebaseAuthException catch (e) {
                  final code = e.code.split("/").last;
                  String? errStr, field;
                  if (code == "user-not-found") {
                    errStr = AppLocalizations.of(context)!.userNotFound;
                  } else if (code == "invalid-email") {
                    errStr =
                        AppLocalizations.of(context)!.fieldInvalid("email");
                    field = 'email';
                  }
                  if (errStr != null && field != null) {
                    _formKey.currentState!
                        .invalidateField(name: field, errorText: errStr);
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
            },
          ),
        ],
      ),
    );
  }
}
