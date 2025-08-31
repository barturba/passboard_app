import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/services.dart';
import '../widgets/password_entry_card.dart';
import '../widgets/add_password_dialog.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late Client _client;
  final Map<String, String> _decryptedPasswords = {};

  @override
  void initState() {
    super.initState();
    _client = widget.client;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _decryptPasswords();
  }

  Future<void> _decryptPasswords() async {
    final encryptionService = context.read<EncryptionService>();

    // Decrypt passwords for display
    for (final entry in _client.passwordEntries) {
      try {
        _decryptedPasswords[entry.id] = encryptionService.decryptPassword(entry.encryptedPassword);
      } catch (e) {
        // If decryption fails, show a placeholder
        _decryptedPasswords[entry.id] = '••••••••';
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client.name),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editClient,
            tooltip: 'Edit client',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteClient,
            tooltip: 'Delete client',
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          // Update client if it changed
          final updatedClient = provider.clients.firstWhere(
            (c) => c.id == _client.id,
            orElse: () => _client,
          );

          if (updatedClient != _client) {
            _client = updatedClient;
            _decryptPasswords();
          }

          if (_client.passwordEntries.isEmpty) {
            return _buildEmptyState();
          }

          return _buildPasswordEntriesList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPasswordEntry,
        tooltip: 'Add password entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'No password entries yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first password entry for this client',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addPasswordEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add Password Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordEntriesList() {
    // Group password entries by type
    final entriesByType = <PasswordType, List<PasswordEntry>>{};
    for (final entry in _client.passwordEntries) {
      entriesByType[entry.type] = (entriesByType[entry.type] ?? [])..add(entry);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _buildSummaryCard(),
        const SizedBox(height: 16),

        // Password entries grouped by type
        ...entriesByType.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeHeader(entry.key, entry.value.length),
              const SizedBox(height: 8),
              ...entry.value.map((passwordEntry) => PasswordEntryCard(
                entry: passwordEntry,
                decryptedPassword: _decryptedPasswords[passwordEntry.id],
                onEdit: () => _editPasswordEntry(passwordEntry),
                onDelete: () => _deletePasswordEntry(passwordEntry),
              )),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalEntries = _client.passwordEntries.length;
    final typesCount = _client.passwordTypes.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.business,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _client.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_client.description != null && _client.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _client.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalEntries password entr${totalEntries == 1 ? 'y' : 'ies'} • $typesCount type${typesCount == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeHeader(PasswordType type, int count) {
    final typeLabel = _getPasswordTypeLabel(type);
    final typeColor = _getPasswordTypeColor(type, context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: typeColor.withOpacity(0.3)),
          ),
          child: Text(
            '$typeLabel ($count)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: typeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _addPasswordEntry() {
    showDialog(
      context: context,
      builder: (context) => AddPasswordDialog(clientId: _client.id),
    );
  }

  void _editPasswordEntry(PasswordEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AddPasswordDialog(
        clientId: _client.id,
        passwordEntry: entry,
      ),
    );
  }

  void _deletePasswordEntry(PasswordEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deletePasswordEntry(_client.id, entry.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${entry.title} deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editClient() {
    // TODO: Navigate to edit client dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit client coming soon!')),
    );
  }

  void _deleteClient() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete "${_client.name}" and all its password entries?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteClient(_client.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_client.name} deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getPasswordTypeLabel(PasswordType type) {
    switch (type) {
      case PasswordType.regular:
        return 'Regular';
      case PasswordType.enable:
        return 'Enable';
      case PasswordType.admin:
        return 'Admin';
      case PasswordType.service:
        return 'Service';
      case PasswordType.custom:
        return 'Custom';
    }
  }

  Color _getPasswordTypeColor(PasswordType type, BuildContext context) {
    switch (type) {
      case PasswordType.regular:
        return Theme.of(context).colorScheme.primary;
      case PasswordType.enable:
        return Theme.of(context).colorScheme.secondary;
      case PasswordType.admin:
        return Theme.of(context).colorScheme.tertiary;
      case PasswordType.service:
        return Theme.of(context).colorScheme.surfaceContainerHighest == Theme.of(context).colorScheme.surface
            ? Theme.of(context).colorScheme.outline
            : Theme.of(context).colorScheme.onSurface;
      case PasswordType.custom:
        return Theme.of(context).colorScheme.outline;
    }
  }
}
