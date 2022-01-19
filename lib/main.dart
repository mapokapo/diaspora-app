// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/routes.dart';
import 'package:diaspora_app/constants/theme_data.dart';
import 'package:diaspora_app/state/language_notifier.dart';
import 'package:diaspora_app/state/theme_mode_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vrouter/vrouter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 4000);
  FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9199);
  FirebaseDatabase.instance.useDatabaseEmulator('10.0.2.2', 9000);

  final _sharedPreferences = await SharedPreferences.getInstance();
  final _storedLocale = _sharedPreferences.getString('locale');
  final _storedThemeMode = _sharedPreferences.getString('themeMode');

  List<SingleChildWidget> providers = [
    ChangeNotifierProvider(
      create: (context) => LanguageNotifier(_storedLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          fallbackLocale: Locale('en')),
    ),
    ChangeNotifierProvider(
      create: (context) => ThemeModeNotifier(_storedThemeMode),
    ),
  ];
  runApp(MyApp(
    providers: providers,
  ));
}

class MyApp extends StatelessWidget {
  final List<SingleChildWidget> providers;
  const MyApp({
    required this.providers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      builder: (BuildContext context, _) {
        return VRouter(
          onSystemPop: (redirector) async {
            if (redirector.historyCanBack()) redirector.historyBack();
          },
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            FormBuilderLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Provider.of<LanguageNotifier>(context).locale,
          debugShowCheckedModeBanner: false,
          title: 'Diaspora',
          themeMode: Provider.of<ThemeModeNotifier>(context).themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          routes: Routes.routes(),
        );
      },
    );
  }
}
