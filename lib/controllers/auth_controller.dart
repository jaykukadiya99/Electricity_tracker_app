import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  // Handle Login
  Future<void> loginUser(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Wait for auth state to propagate slightly
      await Future.delayed(const Duration(milliseconds: 300));
      
      final AppController appCtrl = Get.find<AppController>();
      if (appCtrl.isSetupComplete) {
        Get.offAllNamed('/main');
      } else {
        Get.offAllNamed('/setup');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.message != null) {
        message = e.message!;
      }
      
      Get.snackbar(
        'Login Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check current session state, can be used to manually jump routing
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }
}
