import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:game_city_app/core/services/storage_service.dart';
import '../../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final token = storage.read('token');

    debugPrint(
      'AuthMiddleware: checking route $route, token exists: ${token != null}',
    );

    // If the user is not logged in and is trying to access a restricted route,
    // redirect them to the login page.
    // We allow access to splash, login, and register without authentication.
    final allowedRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
    ];

    if (token == null && !allowedRoutes.contains(route)) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}
