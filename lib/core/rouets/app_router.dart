import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/rouets/router_list.dart';
import 'package:gym_app/features/auth/ui/views/splash_screen.dart';

abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter? _router;

  static GoRouter getRouter() {
    if (_router != null) return _router!;

    _router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: SplashScreen.routeName,
      routes: RoutesList.all,
    );

    return _router!;
  }
}
