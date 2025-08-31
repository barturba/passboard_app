import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import 'password_board.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final KeychainService _keychainService = KeychainService();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _canUseBiometrics = false;
  bool _isKeychainEnabled = false;
  String? _storedPassword;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthenticationStatus() async {
    setState(() => _isLoading = true);

    try {
      // Check if keychain integration is enabled
      _isKeychainEnabled = await _keychainService.isKeychainEnabled;

      if (_isKeychainEnabled) {
        // Check if biometrics are available and enabled
        _canUseBiometrics = await _keychainService.canUseBiometrics &&
                           await _keychainService.isBiometricsEnabled;

        if (_canUseBiometrics) {
          // Try biometric authentication
          final authenticatedPassword = await _keychainService.authenticateAndGetPassword();
          if (authenticatedPassword != null) {
            await _authenticateWithPassword(authenticatedPassword);
            return;
          }
        }

        // Check if password is stored (without biometrics)
        _storedPassword = await _keychainService.getStoredMasterPassword();
      }
    } catch (e) {
      // Handle errors gracefully
    }

    setState(() => _isLoading = false);
  }

  Future<void> _authenticateWithPassword(String password) async {
    // Get the encryption service
    final encryptionService = context.read<EncryptionService>();

    // For now, we'll use a simple check against the demo password
    // In a real app, you'd have proper password verification
    const demoPassword = 'demo_master_password_2024';

    if (password == demoPassword) {
      encryptionService.setMasterPassword(password);
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password')),
      );
    }
  }

  Future<void> _handlePasswordSubmit() async {
    final password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      await _authenticateWithPassword(password);

      // If authentication successful and keychain is enabled, offer to store password
      if (_isAuthenticated && _isKeychainEnabled && _storedPassword == null) {
        _showStorePasswordDialog(password);
      }
    }
  }

  Future<void> _showStorePasswordDialog(String password) async {
    final shouldStore = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Store Password'),
        content: const Text(
          'Would you like to store your master password securely in the system keychain '
          'for easier future access?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Store Password'),
          ),
        ],
      ),
    );

    if (shouldStore == true) {
      try {
        await _keychainService.storeMasterPassword(password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password stored securely')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to store password')),
        );
      }
    }
  }

  Future<void> _tryBiometricAuth() async {
    setState(() => _isLoading = true);

    try {
      final password = await _keychainService.authenticateAndGetPassword();
      if (password != null) {
        await _authenticateWithPassword(password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication error')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return const PasswordBoard();
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Checking authentication...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock Password Board'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),

            Text(
              'Enter Master Password',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              'Your passwords are securely encrypted',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Biometric authentication button (if available)
            if (_canUseBiometrics && _storedPassword != null) ...[
              ElevatedButton.icon(
                onPressed: _tryBiometricAuth,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock with Biometrics'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'OR',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],

            // Password input field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Master Password',
                hintText: 'Enter your master password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    // Toggle password visibility (implement if needed)
                  },
                ),
              ),
              onSubmitted: (_) => _handlePasswordSubmit(),
            ),
            const SizedBox(height: 24),

            // Unlock button
            ElevatedButton(
              onPressed: _handlePasswordSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Unlock'),
            ),

            // Keychain status info
            if (_isKeychainEnabled) ...[
              const SizedBox(height: 24),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _storedPassword != null ? Icons.key : Icons.key_off,
                            color: _storedPassword != null
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Keychain Status',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _storedPassword != null
                            ? '✓ Master password stored securely'
                            : 'No password stored in keychain',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_canUseBiometrics) ...[
                        const SizedBox(height: 4),
                        const Text(
                          '✓ Biometric authentication available',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
