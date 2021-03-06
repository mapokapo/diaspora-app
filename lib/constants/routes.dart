import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaspora_app/constants/theme_data.dart';
import 'package:diaspora_app/widgets/pages/app/chat_page.dart';
import 'package:diaspora_app/widgets/pages/app/matches_page.dart';
import 'package:diaspora_app/widgets/pages/app/profile_page.dart';
import 'package:diaspora_app/widgets/pages/app/settings_page.dart';
import 'package:diaspora_app/widgets/pages/app/swipe_page.dart';
import 'package:diaspora_app/widgets/pages/guest/forgot_password_page.dart';
import 'package:diaspora_app/widgets/pages/guest/landing_page.dart';
import 'package:diaspora_app/widgets/pages/guest/login_help_page.dart';
import 'package:diaspora_app/widgets/pages/guest/login_page.dart';
import 'package:diaspora_app/widgets/pages/guest/register_page.dart';
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
            FirebaseAuth.instance.currentUser != null &&
                    (await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get())
                        .exists
                ? vRedirector.to('/app')
                : null,
        stackedRoutes: [
          // landing nest
          VNester(
            path: '/',
            widgetBuilder: (child) =>
                Theme(data: lightTheme, child: LandingScaffold(body: child)),
            nestedRoutes: [
              // landing page
              VWidget(
                path: null,
                widget: Theme(data: lightTheme, child: const LandingPage()),
              ),
              // login page
              VWidget(
                path: "login",
                widget: Theme(data: lightTheme, child: const LoginPage()),
              ),
              // register page
              VWidget(
                path: "register",
                widget: Theme(data: lightTheme, child: const RegisterPage()),
              ),
              // forgot password page
              VWidget(
                path: "forgot_password",
                widget:
                    Theme(data: lightTheme, child: const ForgotPasswordPage()),
              ),
              // login help page
              VWidget(
                path: "login_help",
                widget: Theme(data: lightTheme, child: LoginHelpPage()),
              ),
            ],
          ),
        ],
      ),
      // app nest guard
      VGuard(
        beforeEnter: (vRedirector) async =>
            FirebaseAuth.instance.currentUser != null &&
                    (await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get())
                        .exists
                ? null
                : vRedirector.to('/'),
        stackedRoutes: [
          // app nest
          VNester(
            path: '/app',
            widgetBuilder: (child) => AppScaffold(body: child),
            nestedRoutes: [
              // swipe page (main page)
              VWidget(
                path: null,
                widget: const SwipePage(),
              ),
              // matches page
              VWidget(
                  path: "matches",
                  widget: const MatchesPage(),
                  stackedRoutes: [
                    // matches/chat page
                    VWidget(
                      path: "chat",
                      widget: const ChatPage(),
                    ),
                  ]),
              // profile page
              VWidget(
                path: "profile",
                widget: const ProfilePage(),
              ),
              // settings page
              VWidget(
                path: "settings",
                widget: const SettingsPage(),
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
