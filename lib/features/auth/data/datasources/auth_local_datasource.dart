import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<AuthUserModel?> getCachedUser();
  Future<void> cacheUser(AuthUserModel user);
  Future<void> clear();
}

final class PreferencesAuthLocalDataSource implements AuthLocalDataSource {
  const PreferencesAuthLocalDataSource(this._preferences);

  static const _userKey = 'auth_user';

  final SharedPreferences _preferences;

  @override
  Future<AuthUserModel?> getCachedUser() async {
    final raw = _preferences.getString(_userKey);
    if (raw == null) {
      return null;
    }

    try {
      return AuthUserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException('Could not decode cached user');
    }
  }

  @override
  Future<void> cacheUser(AuthUserModel user) async {
    await _preferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_userKey);
  }
}
