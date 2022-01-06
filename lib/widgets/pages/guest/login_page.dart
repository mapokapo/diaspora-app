import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:vrouter/vrouter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Login".toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .headline1
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'email',
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 4.0,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    debugPrint(val);
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context,
                        errorText: "You must enter an email"),
                    FormBuilderValidators.email(context,
                        errorText: "Invalid email"),
                  ]),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'password',
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 4.0,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    debugPrint(val);
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context,
                        errorText: "You must enter a password"),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          AuthButton(
            title: "Submit",
            onClick: () {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                context.vRouter.to('/app');
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
                          debugPrint("Reg");
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(12.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Don't have an account?",
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextButton(
                        onPressed: () {
                          debugPrint("For");
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(12.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Forgot your password?",
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
