import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../constants/route_constants.dart';

class RouteGuards {
  static Future<String?> authGuard(BuildContext context, GoRouterState state) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool(AppConstants.isFirstTimeKey) ?? true;

    final isGoingToOnboarding = state.matchedLocation == RouteConstants.onboarding;
    final isGoingToSplash = state.matchedLocation == RouteConstants.splash;

    if (isFirstTime && !isGoingToOnboarding && !isGoingToSplash) {
      return RouteConstants.onboarding;
    }

    return null;
  }
}
