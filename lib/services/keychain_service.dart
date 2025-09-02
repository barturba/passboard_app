import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';

class KeychainService {
  static const String _masterPasswordKey = 'master_password';
  static const String _useKeychainKey = 'use_keychain';
  static const String _useBiometricsKey = 'use_biometrics';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  KeychainService()
      : _secureStorage = const FlutterSecureStorage(),
        _localAuth = LocalAuthentication();

  // Check if device supports biometrics
  Future<bool> get canUseBiometrics async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Check if keychain integration is enabled
  Future<bool> get isKeychainEnabled async {
    final value = await _secureStorage.read(key: _useKeychainKey);
    return value == 'true';
  }

  // Check if biometric authentication is enabled
  Future<bool> get isBiometricsEnabled async {
    final value = await _secureStorage.read(key: _useBiometricsKey);
    return value == 'true';
  }

  // Enable keychain integration
  Future<void> enableKeychain() async {
    await _secureStorage.write(key: _useKeychainKey, value: 'true');
  }

  // Disable keychain integration
  Future<void> disableKeychain() async {
    await _secureStorage.write(key: _useKeychainKey, value: 'false');
    // Remove stored master password when disabling
    await _secureStorage.delete(key: _masterPasswordKey);
    await disableBiometrics();
  }

  // Enable biometric authentication
  Future<void> enableBiometrics() async {
    await _secureStorage.write(key: _useBiometricsKey, value: 'true');
  }

  // Disable biometric authentication
  Future<void> disableBiometrics() async {
    await _secureStorage.write(key: _useBiometricsKey, value: 'false');
  }

  // Store master password in keychain
  Future<void> storeMasterPassword(String password) async {
    final encryptedPassword = _encryptPassword(password);
    await _secureStorage.write(key: _masterPasswordKey, value: encryptedPassword);
  }

  // Retrieve master password from keychain
  Future<String?> getStoredMasterPassword() async {
    final encryptedPassword = await _secureStorage.read(key: _masterPasswordKey);
    if (encryptedPassword != null) {
      return _decryptPassword(encryptedPassword);
    }
    return null;
  }

  // Authenticate with biometrics and retrieve master password
  Future<String?> authenticateAndGetPassword() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your stored master password',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        return await getStoredMasterPassword();
      }
    } catch (e) {
      // Handle authentication error
    }
    return null;
  }

  // Check if master password is stored
  Future<bool> get hasStoredPassword async {
    final password = await _secureStorage.read(key: _masterPasswordKey);
    return password != null;
  }

  // Simple encryption/decryption for additional security layer
  // Note: flutter_secure_storage already encrypts data, this is extra protection
  String _encryptPassword(String password) {
    final bytes = utf8.encode(password);
    // Simple XOR encryption with a fixed key (for demo purposes)
    // In production, use proper encryption with random keys
    const key = 0x5A;
    final encrypted = bytes.map((byte) => byte ^ key).toList();
    return base64Encode(encrypted);
  }

  String _decryptPassword(String encryptedPassword) {
    final bytes = base64Decode(encryptedPassword);
    const key = 0x5A;
    final decrypted = bytes.map((byte) => byte ^ key).toList();
    return utf8.decode(decrypted);
  }

  // Clear all stored data
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
  }

  // Get keychain status information
  Future<Map<String, dynamic>> getKeychainStatus() async {
    return {
      'keychainEnabled': await isKeychainEnabled,
      'biometricsEnabled': await isBiometricsEnabled,
      'biometricsAvailable': await canUseBiometrics,
      'availableBiometrics': (await getAvailableBiometrics()).map((type) => type.name).toList(),
      'hasStoredPassword': await hasStoredPassword,
    };
  }
}



