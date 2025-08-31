import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/keychain_service.dart';

class KeychainSettingsDialog extends StatefulWidget {
  const KeychainSettingsDialog({super.key});

  @override
  State<KeychainSettingsDialog> createState() => _KeychainSettingsDialogState();
}

class _KeychainSettingsDialogState extends State<KeychainSettingsDialog> {
  final KeychainService _keychainService = KeychainService();

  bool _keychainEnabled = false;
  bool _biometricsEnabled = false;
  bool _biometricsAvailable = false;
  List<String> _availableBiometrics = [];
  bool _hasStoredPassword = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKeychainStatus();
  }

  Future<void> _loadKeychainStatus() async {
    final status = await _keychainService.getKeychainStatus();
    setState(() {
      _keychainEnabled = status['keychainEnabled'] ?? false;
      _biometricsEnabled = status['biometricsEnabled'] ?? false;
      _biometricsAvailable = status['biometricsAvailable'] ?? false;
      _availableBiometrics = List<String>.from(status['availableBiometrics'] ?? []);
      _hasStoredPassword = status['hasStoredPassword'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggleKeychain(bool value) async {
    if (value) {
      await _keychainService.enableKeychain();
    } else {
      await _keychainService.disableKeychain();
    }
    await _loadKeychainStatus();
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      await _keychainService.enableBiometrics();
    } else {
      await _keychainService.disableBiometrics();
    }
    await _loadKeychainStatus();
  }

  Future<void> _storeCurrentPassword() async {
    // This would be called after user enters their master password
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store password functionality would be implemented here')),
    );
  }

  Future<void> _clearStoredData() async {
    await _keychainService.clearAllData();
    await _loadKeychainStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All stored keychain data cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        title: Text('Keychain Settings'),
        content: Center(child: CircularProgressIndicator()),
      );
    }

    return AlertDialog(
      title: const Text('Keychain Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Keychain Integration
            SwitchListTile(
              title: const Text('Enable Keychain Integration'),
              subtitle: const Text('Store master password securely in system keychain'),
              value: _keychainEnabled,
              onChanged: _toggleKeychain,
            ),

            if (_keychainEnabled) ...[
              const Divider(),

              // Biometric Authentication
              if (_biometricsAvailable) ...[
                SwitchListTile(
                  title: const Text('Biometric Authentication'),
                  subtitle: Text('Use ${_availableBiometrics.join(", ")} for quick unlock'),
                  value: _biometricsEnabled,
                  onChanged: _toggleBiometrics,
                ),
              ] else ...[
                ListTile(
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text('Not available on this device'),
                  leading: const Icon(Icons.fingerprint, color: Colors.grey),
                  enabled: false,
                ),
              ],

              const Divider(),

              // Stored Password Status
              ListTile(
                title: const Text('Stored Password'),
                subtitle: _hasStoredPassword
                    ? const Text('Master password is stored securely')
                    : const Text('No password stored'),
                leading: Icon(
                  _hasStoredPassword ? Icons.lock : Icons.lock_open,
                  color: _hasStoredPassword ? Colors.green : Colors.grey,
                ),
                trailing: _hasStoredPassword
                    ? IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _storeCurrentPassword,
                        tooltip: 'Update stored password',
                      )
                    : IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _storeCurrentPassword,
                        tooltip: 'Store current password',
                      ),
              ),

              const Divider(),

              // Security Information
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Security Information',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Master password is encrypted before storage\n'
                        '• System keychain provides additional security layer\n'
                        '• Biometric authentication requires device authentication\n'
                        '• You can clear all stored data at any time',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),

              // Clear Data Button
              Center(
                child: TextButton.icon(
                  onPressed: _clearStoredData,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text(
                    'Clear All Stored Data',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
