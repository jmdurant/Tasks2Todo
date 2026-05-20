import 'package:shared_preferences/shared_preferences.dart';

/// Stores the *profile* of the signed-in user. Credentials (password) are never
/// persisted here — Firebase Auth manages cloud credentials, and the local
/// mode stores only a salted hash via [LocalAuthService].
class UserPref {
  static const String _nameKey = 'NAME';
  static const String _emailKey = 'EMAIL';
  static const String _uidKey = 'UID';
  static const String _tokenKey = 'TOKEN';

  static Future<void> setUser({
    required String name,
    required String email,
    required String uid,
    required String token,
  }) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(_nameKey, name);
    await pref.setString(_emailKey, email);
    await pref.setString(_uidKey, uid);
    await pref.setString(_tokenKey, token);
  }

  static Future<Map<String, String>> getUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return <String, String>{
      'NAME': pref.getString(_nameKey) ?? '',
      'EMAIL': pref.getString(_emailKey) ?? '',
      'UID': pref.getString(_uidKey) ?? '',
      'TOKEN': pref.getString(_tokenKey) ?? '',
    };
  }

  static Future<void> clearUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(_nameKey);
    await pref.remove(_emailKey);
    await pref.remove(_uidKey);
    await pref.remove(_tokenKey);
  }
}
