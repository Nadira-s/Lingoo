import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccess = 'access_token';
const _kRefresh = 'refresh_token';

/// JWT storage: Keychain / Keystore with in-memory fallback (macOS sandbox dev).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? _defaultStorage;

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  String? _memoryAccess;
  String? _memoryRefresh;
  bool _useMemoryFallback = false;

  Future<String?> readAccessToken() async {
    if (_useMemoryFallback) return _memoryAccess;
    try {
      return await _storage.read(key: _kAccess);
    } catch (e) {
      debugPrint('TokenStorage: secure read access failed: $e');
      _useMemoryFallback = true;
      return _memoryAccess;
    }
  }

  Future<String?> readRefreshToken() async {
    if (_useMemoryFallback) return _memoryRefresh;
    try {
      return await _storage.read(key: _kRefresh);
    } catch (e) {
      debugPrint('TokenStorage: secure read refresh failed: $e');
      _useMemoryFallback = true;
      return _memoryRefresh;
    }
  }

  Future<void> writeTokens({required String access, String? refresh}) async {
    _memoryAccess = access;
    _memoryRefresh = refresh;
    if (_useMemoryFallback) return;
    try {
      await _storage.write(key: _kAccess, value: access);
      if (refresh != null) {
        await _storage.write(key: _kRefresh, value: refresh);
      }
    } catch (e) {
      debugPrint('TokenStorage: secure write failed, using memory: $e');
      _useMemoryFallback = true;
    }
  }

  Future<void> clear() async {
    _memoryAccess = null;
    _memoryRefresh = null;
    if (_useMemoryFallback) return;
    try {
      await _storage.delete(key: _kAccess);
      await _storage.delete(key: _kRefresh);
    } catch (e) {
      debugPrint('TokenStorage: secure clear failed: $e');
      _useMemoryFallback = true;
    }
  }
}
