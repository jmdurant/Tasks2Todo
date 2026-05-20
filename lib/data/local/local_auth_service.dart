import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/utils.dart';
import '../../view/home/home.dart';
import '../../view/sign in/sign_in.dart';
import '../shared pref/shared_pref.dart';

/// Local-only auth: stores a salted SHA-256 hash of the password in
/// SharedPreferences. Never persists the plaintext password.
class LocalAuthService {
  static const String _nameKey = 'LOCAL_USER_NAME';
  static const String _emailKey = 'LOCAL_USER_EMAIL';
  static const String _hashKey = 'LOCAL_USER_PASSWORD_HASH';
  static const String _saltKey = 'LOCAL_USER_PASSWORD_SALT';
  static const String _uidKey = 'LOCAL_USER_UID';

  /// Generates 16 random bytes (hex-encoded, 32 chars).
  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  static Future<void> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String salt = _generateSalt();
    final String hash = _hash(password, salt);
    final String uid = 'local-${DateTime.now().microsecondsSinceEpoch}';

    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_hashKey, hash);
    await prefs.setString(_saltKey, salt);
    await prefs.setString(_uidKey, uid);

    await UserPref.setUser(
      name: name,
      email: email,
      uid: uid,
      token: 'LOCAL_USER',
    );

    Utils.showSnackBar(
      'Sign up',
      'Local account created successfully',
      const Icon(Icons.done, color: Colors.white),
    );
    Get.offAll(() => HomePage());
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString(_emailKey);
    final String? storedHash = prefs.getString(_hashKey);
    final String? storedSalt = prefs.getString(_saltKey);
    final String? storedName = prefs.getString(_nameKey);
    final String? storedUid = prefs.getString(_uidKey);

    if (storedEmail == null ||
        storedHash == null ||
        storedSalt == null ||
        storedName == null ||
        storedUid == null) {
      return 'No local account found. Please create one first.';
    }
    if (storedEmail != email) {
      return 'Entered email does not match the local account.';
    }
    if (_hash(password, storedSalt) != storedHash) {
      return 'Incorrect password for the local account.';
    }

    await UserPref.setUser(
      name: storedName,
      email: storedEmail,
      uid: storedUid,
      token: 'LOCAL_USER',
    );
    return null;
  }

  Future<void> signOut() async {
    await UserPref.clearUser();
    Get.offAll(() => const SignIn());
  }
}
