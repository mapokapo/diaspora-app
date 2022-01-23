import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LandingScaffold extends StatelessWidget {
  final Widget body;

  const LandingScaffold({required this.body, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: context.vRouter.historyCanBack() && context.vRouter.url != "/"
            ? AppBar(
                title: Text(context.vRouter.path == "/"
                    ? ""
                    : AppLocalizations.of(context)!.appName),
                leading: BackButton(
                  onPressed: () => context.vRouter.systemPop(),
                ),
              )
            : null,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorLight,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: body,
        ),
      ),
    );
  }
}
