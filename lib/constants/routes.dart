import 'package:diaspora_app/widgets/pages/guest/landing_page.dart';
import 'package:diaspora_app/widgets/pages/guest/login_page.dart';
import 'package:diaspora_app/widgets/scaffolds/app_scaffold.dart';
import 'package:diaspora_app/widgets/scaffolds/landing_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class Routes {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPass = '/forgotpass';
  static const String app = '/app';
  static const String settings = '/app/settings';
  static const String help = '/app/help';

  static List<VRouteElement> routes() {
    return [
      // landing nest guard
      VGuard(
        beforeEnter: (vRedirector) async =>
            FirebaseAuth.instance.currentUser != null
                ? vRedirector.to('/app')
                : null,
        stackedRoutes: [
          // landing nest
          VNester(
            path: '/',
            widgetBuilder: (child) => LandingScaffold(body: child),
            nestedRoutes: [
              // landing page
              VWidget(
                path: null,
                widget: const LandingPage(),
              ),
              // login page
              VWidget(
                path: "login",
                widget: const LoginPage(),
              ),
            ],
          ),
        ],
      ),
      // app nest guard
      VGuard(
        beforeEnter: (vRedirector) async =>
            FirebaseAuth.instance.currentUser != null
                ? null
                : vRedirector.to('/'),
        stackedRoutes: [
          // app nest
          VNester(
            path: '/app',
            widgetBuilder: (child) => AppScaffold(body: child),
            nestedRoutes: [
              // home page
              VWidget(
                path: null,
                widget: const Placeholder(),
              ),
              // settings page... etc.
              VWidget(
                path: "settings",
                widget: const Placeholder(),
              ),
            ],
          ),
        ],
      ),
      // redirect all invalid pages to the landing page
      VRouteRedirector(path: '*', redirectTo: '/'),
    ];
  }
}
