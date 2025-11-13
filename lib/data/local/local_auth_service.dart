import 'package:shared_preferences/shared_preferences.dart';

import '../../view/home/home.dart';
import '../../util/utils.dart';
import '../../data/shared pref/shared_pref.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LocalAuthService {
  static const String _nameKey = 'LOCAL_USER_NAME';
  static const String _emailKey = 'LOCAL_USER_EMAIL';
  static const String _passwordKey = 'LOCAL_USER_PASSWORD';

  static Future<void> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await _persistToUserPrefs(name: name, email: email, password: password);
    Utils.showSnackBar(
        'Sign up',
        'Local account created successfully',
        const Icon(
          Icons.done,
          color: Colors.white,
        ));
    Get.offAll(HomePage());
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString(_emailKey);
    final String? storedPassword = prefs.getString(_passwordKey);
    final String? storedName = prefs.getString(_nameKey);

    if (storedEmail == null || storedPassword == null || storedName == null) {
      return 'No local account found. Please create one first.';
    }
    if (storedEmail != email) {
      return 'Entered email does not match the local account.';
    }
    if (storedPassword != password) {
      return 'Incorrect password for the local account.';
    }
    await _persistToUserPrefs(
      name: storedName,
      email: storedEmail,
      password: storedPassword,
    );
    return null;
  }

  static Future<void> _persistToUserPrefs({
    required String name,
    required String email,
    required String password,
  }) async {
    final String node = email.contains('@')
        ? email.substring(0, email.indexOf('@'))
        : email;
    await UserPref.setUser(name, email, password, node, 'LOCAL_USER');
  }
}
