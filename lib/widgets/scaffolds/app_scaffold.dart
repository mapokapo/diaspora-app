import 'package:diaspora_app/constants/match.dart';
import 'package:diaspora_app/state/current_match_notifier.dart';
import 'package:diaspora_app/state/language_notifier.dart';
import 'package:diaspora_app/state/match_selection_provider.dart';
import 'package:diaspora_app/state/theme_mode_notifier.dart';
import 'package:diaspora_app/widgets/partials/user_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;

  const AppScaffold({required this.body, Key? key}) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final List<String> _routes = ["/app", "/app/matches", "/app/profile"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    context.vRouter.to(_routes[index], isReplacement: true);
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((_initialMessage) async {
      if (_initialMessage != null &&
          _initialMessage.data.containsKey('senderId')) {
        final _match = await Match.fromId(_initialMessage.data['senderId']);
        Provider.of<CurrentMatchNotifier>(context, listen: false)
            .setMatch(_match);
        context.vRouter.to('chat');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final _match = await Match.fromId(message.data['senderId']);
      Provider.of<CurrentMatchNotifier>(context, listen: false)
          .setMatch(_match);
      context.vRouter.to('chat');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawerEnableOpenDragGesture: false,
        resizeToAvoidBottomInset:
            context.vRouter.url == "/app/profile" ? false : true,
        drawer: Drawer(
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  context.vRouter.to(
                    '/',
                    historyState: {},
                    isReplacement: true,
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 16),
                    Flexible(
                        child: Text(AppLocalizations.of(context)!.log('out'))),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  Provider.of<ThemeModeNotifier>(context, listen: false)
                      .toggleThemeMode();
                },
                child: Row(
                  children: [
                    Provider.of<ThemeModeNotifier>(context).themeMode ==
                            ThemeMode.dark
                        ? const Icon(Icons.light_mode)
                        : const Icon(Icons.dark_mode),
                    const SizedBox(width: 16),
                    Flexible(
                        child: Text(AppLocalizations.of(context)!.toggleTheme)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final _currentLocale =
                      Provider.of<LanguageNotifier>(context, listen: false)
                          .locale;
                  Provider.of<LanguageNotifier>(context, listen: false)
                      .setLocale(_currentLocale.languageCode == "en"
                          ? const Locale("hr")
                          : const Locale("en"));
                },
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(AppLocalizations.of(context)!.changeLanguage(
                          Provider.of<LanguageNotifier>(context, listen: false)
                                      .locale
                                      .languageCode ==
                                  "en"
                              ? "hr"
                              : "en")),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        appBar: Provider.of<CurrentMatchNotifier>(context).match == null
            ? AppBar(
                title: Text(AppLocalizations.of(context)!.appName),
                leading:
                    Provider.of<MatchSelectionNotifier>(context).selectionMode()
                        ? IconButton(
                            onPressed: () {
                              Provider.of<MatchSelectionNotifier>(context,
                                      listen: false)
                                  .removeIds();
                            },
                            icon: const Icon(Icons.close),
                          )
                        : IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                actions: Provider.of<MatchSelectionNotifier>(context)
                        .selectionMode()
                    ? [
                        IconButton(
                          onPressed: () async {
                            await Provider.of<MatchSelectionNotifier>(context,
                                    listen: false)
                                .deleteMatches();
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ]
                    : null,
              )
            : AppBar(
                title: Text(
                    Provider.of<CurrentMatchNotifier>(context).match!.name),
                leadingWidth: 80,
                titleSpacing: 4,
                leading: InkWell(
                  onTap: () {
                    context.vRouter.systemPop();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chevron_left),
                      UserAvatar(
                          Provider.of<CurrentMatchNotifier>(context)
                              .match!
                              .imageData,
                          mini: true),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar:
            Provider.of<CurrentMatchNotifier>(context).match == null
                ? BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.search),
                        label: AppLocalizations.of(context)!.swipe,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.favorite),
                        label: AppLocalizations.of(context)!.matches,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.person),
                        label: AppLocalizations.of(context)!.profile,
                      ),
                    ],
                    currentIndex: context.vRouter.path == "/app"
                        ? 0
                        : context.vRouter.path == "/app/matches"
                            ? 1
                            : context.vRouter.path == "/app/profile"
                                ? 2
                                : 0,
                    onTap: _onItemTapped,
                  )
                : null,
        body: Stack(
          children: [
            widget.body,
          ],
        ),
      ),
    );
  }
}
