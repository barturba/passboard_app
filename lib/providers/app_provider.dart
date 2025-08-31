import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class AppProvider with ChangeNotifier {
  List<Client> _clients = [];
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  String? _error;

  final StorageService _storageService;
  final EncryptionService _encryptionService;

  AppProvider(this._storageService, this._encryptionService) {
    loadData();
  }

  // Getters
  List<Client> get clients => _clients;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load data from storage
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clients = await _storageService.loadClients();
      _settings = await _storageService.loadAppSettings();
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new client
  Future<void> addClient(Client client) async {
    _clients.add(client);
    await _saveClients();
    notifyListeners();
  }

  // Update an existing client
  Future<void> updateClient(Client updatedClient) async {
    final index = _clients.indexWhere((client) => client.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      await _saveClients();
      notifyListeners();
    }
  }

  // Delete a client
  Future<void> deleteClient(String clientId) async {
    _clients.removeWhere((client) => client.id == clientId);
    await _saveClients();
    notifyListeners();
  }

  // Add password entry to client
  Future<void> addPasswordEntry(String clientId, PasswordEntry entry) async {
    final clientIndex = _clients.indexWhere((client) => client.id == clientId);
    if (clientIndex != -1) {
      final updatedClient = _clients[clientIndex].addPasswordEntry(entry);
      _clients[clientIndex] = updatedClient;
      await _saveClients();
      notifyListeners();
    }
  }

  // Update password entry
  Future<void> updatePasswordEntry(String clientId, PasswordEntry updatedEntry) async {
    final clientIndex = _clients.indexWhere((client) => client.id == clientId);
    if (clientIndex != -1) {
      final updatedClient = _clients[clientIndex].updatePasswordEntry(updatedEntry);
      _clients[clientIndex] = updatedClient;
      await _saveClients();
      notifyListeners();
    }
  }

  // Delete password entry
  Future<void> deletePasswordEntry(String clientId, String entryId) async {
    final clientIndex = _clients.indexWhere((client) => client.id == clientId);
    if (clientIndex != -1) {
      final updatedClient = _clients[clientIndex].removePasswordEntry(entryId);
      _clients[clientIndex] = updatedClient;
      await _saveClients();
      notifyListeners();
    }
  }

  // Update app settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveAppSettings(_settings);
    notifyListeners();
  }

  // Save clients to storage
  Future<void> _saveClients() async {
    try {
      // Note: In a real implementation, you'd pass the master password here
      // For now, we're assuming the encryption service is already initialized
      await _storageService.saveClients(_clients, '');
    } catch (e) {
      _error = 'Failed to save data: $e';
      notifyListeners();
    }
  }

  // Search clients and password entries
  List<Client> searchClients(String query) {
    if (query.isEmpty) return _clients;

    final lowercaseQuery = query.toLowerCase();
    return _clients.where((client) {
      // Search in client name and description
      if (client.name.toLowerCase().contains(lowercaseQuery) ||
          (client.description?.toLowerCase().contains(lowercaseQuery) ?? false)) {
        return true;
      }

      // Search in password entries
      return client.passwordEntries.any((entry) =>
          entry.title.toLowerCase().contains(lowercaseQuery) ||
          entry.username.toLowerCase().contains(lowercaseQuery) ||
          entry.notes?.toLowerCase().contains(lowercaseQuery) == true);
    }).toList();
  }

  // Get clients sorted by name
  List<Client> get clientsSortedByName {
    final sortedClients = List<Client>.from(_clients);
    sortedClients.sort((a, b) => a.name.compareTo(b.name));
    return sortedClients;
  }

  // Clear all data
  Future<void> clearAllData() async {
    _clients = [];
    _settings = const AppSettings();
    await _storageService.clearAllData();
    notifyListeners();
  }

  // Export data
  Future<String> exportData() async {
    return await _storageService.exportData();
  }

  // Import data
  Future<bool> importData(String jsonData) async {
    final success = await _storageService.importData(jsonData);
    if (success) {
      await loadData();
    }
    return success;
  }
}
