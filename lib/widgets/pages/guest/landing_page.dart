import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo'),
            ],
          ),
          flex: 2,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    text: "By tapping log in, you agree with our ",
                    children: [
                      TextSpan(
                        text: "Terms of Service",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            debugPrint("Terms");
                          },
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            debugPrint("Privacy");
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                AuthButton(
                  title: "Log In With Email",
                  onClick: () {
                    context.vRouter.to('login');
                  },
                ),
                const SizedBox(height: 16.0),
                AuthButton(
                  title: "Log In With Google",
                  onClick: () {
                    debugPrint("Google");
                  },
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    debugPrint("Trouble");
                  },
                  child: Text(
                    "Trouble logging in?",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          flex: 1,
        ),
      ],
    );
  }
}
