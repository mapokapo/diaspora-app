import 'package:diaspora_app/state/language_notifier.dart';
import 'package:diaspora_app/widgets/partials/auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<Locale>(
                      value: Provider.of<LanguageNotifier>(context).locale,
                      items: AppLocalizations.supportedLocales
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.languageCode == "hr"
                                  ? "Lokalni"
                                  : "Engleski"),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        Provider.of<LanguageNotifier>(context, listen: false)
                            .setLocale(newValue);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2,
                  text: AppLocalizations.of(context)!.loginToAgree + " ",
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.termsOfService,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.vRouter.toExternal(
                              'https://www.termsofservicegenerator.net/live.php?token=xkATBj5xOPp747aDJHQyn3xBTqii44gN',
                              openNewTab: true);
                        },
                    ),
                    TextSpan(
                        text: " " + AppLocalizations.of(context)!.and + " "),
                    TextSpan(
                      text: AppLocalizations.of(context)!.privacyPolicy,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.vRouter.toExternal(
                              'https://www.privacypolicygenerator.info/live.php?token=cf3BJ7qt7KyS5MCmnBcLyKsrEG7kOwgL',
                              openNewTab: true);
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              AuthButton(
                title: AppLocalizations.of(context)!.loginEmail,
                onClick: () {
                  context.vRouter.to('login');
                },
              ),
              const SizedBox(height: 16.0),
              AuthButton(
                title: AppLocalizations.of(context)!.loginGoogle,
                onClick: () async {
                  final GoogleSignInAccount? googleUser =
                      await GoogleSignIn().signIn();
                  if (googleUser != null) {
                    final GoogleSignInAuthentication? googleAuth =
                        await googleUser.authentication;

                    final credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth?.accessToken,
                      idToken: googleAuth?.idToken,
                    );
                    try {
                      await FirebaseAuth.instance
                          .signInWithCredential(credential);
                      context.vRouter.to('/app');
                    } on FirebaseAuthException catch (e) {
                      final code = e.code;
                      String? errStr;
                      if (code == "account-exists-with-different-credential") {
                        errStr = AppLocalizations.of(context)!
                            .accountExistsWithDifferentCredential;
                      } else if (code == "user-disabled") {
                        errStr = AppLocalizations.of(context)!.userDisabled;
                      } else if (code == "user-not-found") {
                        errStr = AppLocalizations.of(context)!.userNotFound;
                      } else if (code == "wrong-password") {
                        errStr = AppLocalizations.of(context)!.wrongPassword;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errStr ?? e.message!)));
                    }
                  }
                },
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  context.vRouter.to('/login_help');
                },
                child: Text(
                  AppLocalizations.of(context)!.loginTrouble,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ],
    );
  }
}
