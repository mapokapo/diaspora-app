import 'package:diaspora_app/widgets/partials/animated_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vrouter/vrouter.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;

  const AppScaffold({required this.body, Key? key}) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;
  final List<String> _routes = ["/app", "/app/matches", "/app/settings"];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.vRouter.to(_routes[index], isReplacement: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
        drawer: Drawer(
          child: Column(
            children: const [Text("Hello")],
          ),
        ),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appName),
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
        ),
        bottomNavigationBar: BottomNavigationBar(
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
              icon: const Icon(Icons.settings),
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        body: Stack(
          children: [
            widget.body,
            // TODO
            // Add a cool background
          ],
        ),
      ),
    );
  }
}
