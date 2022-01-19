import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginHelpPage extends StatelessWidget {
  LoginHelpPage({Key? key}) : super(key: key);
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  Widget _textPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, top: 10, right: 4),
            child: Icon(
              Icons.circle,
              size: 8,
            ),
          ),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.loginHelpText1,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textPoint(
                      context, AppLocalizations.of(context)!.loginHelpPoint1),
                  _textPoint(
                      context, AppLocalizations.of(context)!.loginHelpPoint2),
                  _textPoint(
                      context, AppLocalizations.of(context)!.loginHelpPoint3),
                  _textPoint(
                      context, AppLocalizations.of(context)!.loginHelpPoint4),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loginHelpText2,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 16),
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    keyboardType: TextInputType.name,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: AppLocalizations.of(context)!
                              .fieldRequired('name')),
                      FormBuilderValidators.match(context, r'\w+( +\w+)*',
                          errorText: AppLocalizations.of(context)!
                              .fieldInvalid('name')),
                    ]),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 4.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'content',
                    minLines: 3,
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: AppLocalizations.of(context)!
                              .fieldRequired('content')),
                    ]),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.content,
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
            const SizedBox(height: 16),
            AuthButton(
              title: AppLocalizations.of(context)!.submit,
              onClick: () async {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  final Email email = Email(
                    body: _formKey.currentState!.value['content'],
                    subject:
                        "Diaspora bug report from \"${_formKey.currentState!.value['name']}\"",
                    recipients: ["leopetrovic11@gmail.com"],
                  );
                  await FlutterEmailSender.send(email);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
