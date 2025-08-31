import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _clientsKey = 'encrypted_clients';
  static const String _appSettingsKey = 'app_settings';
  static const String _masterPasswordHashKey = 'master_password_hash';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Initialize storage service
  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Master password hash operations
  Future<void> saveMasterPasswordHash(String hash) async {
    await _prefs.setString(_masterPasswordHashKey, hash);
  }

  Future<String?> getMasterPasswordHash() async {
    return _prefs.getString(_masterPasswordHashKey);
  }

  Future<void> deleteMasterPasswordHash() async {
    await _prefs.remove(_masterPasswordHashKey);
  }

  // Clients data operations
  Future<void> saveClients(List<Client> clients, String masterPassword) async {
    final clientsJson = clients.map((client) => client.toJson()).toList();
    final clientsString = jsonEncode(clientsJson);

    // Store using SharedPreferences (less secure but works without entitlements)
    await _prefs.setString(_clientsKey, clientsString);
  }

  Future<List<Client>> loadClients() async {
    final clientsString = _prefs.getString(_clientsKey);
    if (clientsString == null || clientsString.isEmpty) {
      return [];
    }

    try {
      final clientsJson = jsonDecode(clientsString) as List<dynamic>;
      return clientsJson.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      // If there's an error loading clients, return empty list
      return [];
    }
  }

  Future<void> clearAllClients() async {
    await _prefs.remove(_clientsKey);
  }

  // App settings operations (stored in regular preferences since they're not sensitive)
  Future<void> saveAppSettings(AppSettings settings) async {
    final settingsJson = jsonEncode(settings.toJson());
    await _prefs.setString(_appSettingsKey, settingsJson);
  }

  Future<AppSettings> loadAppSettings() async {
    final settingsString = _prefs.getString(_appSettingsKey);
    if (settingsString == null || settingsString.isEmpty) {
      return const AppSettings();
    }

    try {
      final settingsJson = jsonDecode(settingsString);
      return AppSettings.fromJson(settingsJson);
    } catch (e) {
      return const AppSettings();
    }
  }

  // Clear all data (for reset functionality)
  Future<void> clearAllData() async {
    await _prefs.clear();
  }

  // Export data for backup
  Future<String> exportData() async {
    final clients = await loadClients();
    final settings = await loadAppSettings();
    final masterPasswordHash = await getMasterPasswordHash();

    final exportData = {
      'clients': clients.map((client) => client.toJson()).toList(),
      'settings': settings.toJson(),
      'masterPasswordHash': masterPasswordHash,
      'exportDate': DateTime.now().toIso8601String(),
    };

    return jsonEncode(exportData);
  }

  // Import data from backup
  Future<bool> importData(String jsonData) async {
    try {
      final importData = jsonDecode(jsonData) as Map<String, dynamic>;

      // Import clients
      final clientsJson = importData['clients'] as List<dynamic>?;
      if (clientsJson != null) {
        final clients = clientsJson.map((json) => Client.fromJson(json)).toList();
        // Note: We don't have master password here, so we'll store as-is
        // In a real implementation, you'd need to handle re-encryption
        await saveClients(clients, ''); // Empty password for now
      }

      // Import settings
      final settingsJson = importData['settings'] as Map<String, dynamic>?;
      if (settingsJson != null) {
        final settings = AppSettings.fromJson(settingsJson);
        await saveAppSettings(settings);
      }

      // Import master password hash
      final masterPasswordHash = importData['masterPasswordHash'] as String?;
      if (masterPasswordHash != null) {
        await saveMasterPasswordHash(masterPasswordHash);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if data exists
  Future<bool> hasData() async {
    final clientsString = _prefs.getString(_clientsKey);
    return clientsString != null && clientsString.isNotEmpty;
  }
}
