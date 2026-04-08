import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    var authCtrl = Get.find<AuthController>();
    
    if (authCtrl.getCurrentUser() == null) {
      // User is not logged in, redirect to login page
      return const RouteSettings(name: '/login');
    }
    // Allow the user to proceed
    return null;
  }
}
