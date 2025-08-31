import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  static const String _keySalt = 'passboard_salt_2024';
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  EncryptionService() {
    _initializeEncrypter();
  }

  void _initializeEncrypter() {
    // Generate a consistent IV for this session
    // In production, you might want to generate a new IV for each encryption
    final ivBytes = sha256.convert(utf8.encode(_keySalt)).bytes.sublist(0, 16);
    _iv = encrypt.IV(Uint8List.fromList(ivBytes));
  }

  /// Generate encryption key from master password
  encrypt.Key _generateKey(String masterPassword) {
    final keyBytes = sha256.convert(utf8.encode(masterPassword + _keySalt)).bytes;
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  /// Set the master password and initialize the encrypter
  void setMasterPassword(String masterPassword) {
    final key = _generateKey(masterPassword);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  /// Encrypt a plain text password
  String encryptPassword(String plainPassword) {
    if (_encrypter == null) {
      throw Exception('Master password not set. Call setMasterPassword() first.');
    }

    final encrypted = _encrypter.encrypt(plainPassword, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt an encrypted password
  String decryptPassword(String encryptedPassword) {
    if (_encrypter == null) {
      throw Exception('Master password not set. Call setMasterPassword() first.');
    }

    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedPassword);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt password: $e');
    }
  }

  /// Hash a master password for storage/verification
  String hashMasterPassword(String masterPassword) {
    final bytes = utf8.encode(masterPassword + _keySalt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Verify a master password against its hash
  bool verifyMasterPassword(String masterPassword, String storedHash) {
    final computedHash = hashMasterPassword(masterPassword);
    return computedHash == storedHash;
  }

  /// Generate a secure random master password
  String generateSecureMasterPassword({int length = 16}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = encrypt.Key.fromSecureRandom(length);
    final password = String.fromCharCodes(
      List.generate(length, (index) => chars.codeUnitAt(random.bytes[index % random.bytes.length] % chars.length))
    );
    return password;
  }

  /// Test encryption/decryption with the current setup
  bool testEncryption() {
    try {
      const testPassword = 'test_password_123';
      final encrypted = encryptPassword(testPassword);
      final decrypted = decryptPassword(encrypted);
      return decrypted == testPassword;
    } catch (e) {
      return false;
    }
  }
}
