import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccess = 'access_token';
const _kRefresh = 'refresh_token';
const _secureTimeout = Duration(seconds: 2);

bool _desktopUsesMemoryOnly() {
  if (kIsWeb) return true;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

/// JWT storage. Desktop uses in-memory (Keychain can hang); mobile uses secure + timeout.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage, bool? memoryOnly})
      : _storage = storage ?? _defaultStorage,
        _memoryOnly = memoryOnly ?? _desktopUsesMemoryOnly();

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;
  final bool _memoryOnly;

  String? _memoryAccess;
  String? _memoryRefresh;

  Future<String?> readAccessToken() async {
    if (_memoryOnly) return _memoryAccess;
    return _readSecure(_kAccess, _memoryAccess);
  }

  Future<String?> readRefreshToken() async {
    if (_memoryOnly) return _memoryRefresh;
    return _readSecure(_kRefresh, _memoryRefresh);
  }

  Future<void> writeTokens({required String access, String? refresh}) async {
    _memoryAccess = access;
    _memoryRefresh = refresh;
    if (_memoryOnly) return;
    await _writeSecure(_kAccess, access);
    if (refresh != null) {
      await _writeSecure(_kRefresh, refresh);
    }
  }

  Future<void> clear() async {
    _memoryAccess = null;
    _memoryRefresh = null;
    if (_memoryOnly) return;
    await _deleteSecure(_kAccess);
    await _deleteSecure(_kRefresh);
  }

  Future<String?> _readSecure(String key, String? fallback) async {
    try {
      return await _storage.read(key: key).timeout(_secureTimeout);
    } on TimeoutException {
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value).timeout(_secureTimeout);
    } on TimeoutException {
      // keep in-memory copy only
    } catch (_) {}
  }

  Future<void> _deleteSecure(String key) async {
    try {
      await _storage.delete(key: key).timeout(_secureTimeout);
    } on TimeoutException {
      // ignore
    } catch (_) {}
  }
}
