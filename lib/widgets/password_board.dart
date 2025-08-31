import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/services.dart';

class PasswordBoard extends StatefulWidget {
  const PasswordBoard({super.key});

  @override
  State<PasswordBoard> createState() => _PasswordBoardState();
}

class _PasswordBoardState extends State<PasswordBoard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, bool> _showPasswords = {};
  final Map<String, String> _decryptedPasswords = {};

  @override
  void initState() {
    super.initState();
    _decryptAllPasswords();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh decrypted passwords when dependencies change
    _decryptAllPasswords();
  }

  Future<void> _decryptAllPasswords() async {
    final encryptionService = context.read<EncryptionService>();
    final clients = context.read<AppProvider>().clients;

    for (final client in clients) {
      for (final entry in client.passwordEntries) {
        try {
          final decrypted = encryptionService.decryptPassword(entry.encryptedPassword);
          _decryptedPasswords[entry.id] = decrypted;
        } catch (e) {
          _decryptedPasswords[entry.id] = '';
        }
      }
    }

    if (mounted) setState(() {});
  }

  List<PasswordEntry> _getAllEntries() {
    final allEntries = <PasswordEntry>[];
    final clients = context.read<AppProvider>().clients;

    for (final client in clients) {
      allEntries.addAll(client.passwordEntries);
    }
    return allEntries;
  }

  List<PasswordEntry> _getFilteredEntries() {
    final allEntries = _getAllEntries();

    if (_searchQuery.isEmpty) return allEntries;

    return allEntries.where((entry) {
      return entry.title.toLowerCase().contains(_searchQuery) ||
             entry.username.toLowerCase().contains(_searchQuery) ||
             (entry.notes?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  String _getClientNameForEntry(PasswordEntry entry) {
    final clients = context.read<AppProvider>().clients;
    for (final client in clients) {
      if (client.passwordEntries.any((e) => e.id == entry.id)) {
        return client.name;
      }
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _getFilteredEntries();
    final allEntries = _getAllEntries();
    final clients = context.read<AppProvider>().clients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Board'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _decryptedPasswords.clear();
              });
              _decryptAllPasswords();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: _showImportExportDialog,
            tooltip: 'Import/Export',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPasswordDialog(context),
            tooltip: 'Add Password',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                _buildStatItem('${clients.length}', 'Clients'),
                const SizedBox(width: 24),
                _buildStatItem('${allEntries.length}', 'Passwords'),
                const SizedBox(width: 24),
                _buildStatItem('${filteredEntries.length}', 'Showing'),
                const Spacer(),
                Text(
                  'Last updated: ${_formatLastUpdate()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search passwords...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text('Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                SizedBox(width: 80, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),

          // Password entries
          Expanded(
            child: ListView.builder(
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                final entryId = entry.id;
                final showPassword = _showPasswords[entryId] ?? false;
                final decryptedPassword = _decryptedPasswords[entryId] ?? '';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1))),
                  ),
                  child: Row(
                    children: [
                      // Title
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Username
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                entry.username,
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 14),
                              onPressed: () => _copyToClipboard(entry.username, 'Username copied'),
                              tooltip: 'Copy username',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            ),
                          ],
                        ),
                      ),

                      // Password
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                showPassword && decryptedPassword.isNotEmpty
                                    ? decryptedPassword
                                    : '•' * (decryptedPassword.isNotEmpty ? decryptedPassword.length : 8),
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                showPassword ? Icons.visibility_off : Icons.visibility,
                                size: 14,
                              ),
                              onPressed: decryptedPassword.isNotEmpty ? () {
                                setState(() {
                                  _showPasswords[entryId] = !(_showPasswords[entryId] ?? false);
                                });
                              } : null,
                              tooltip: showPassword ? 'Hide password' : 'Show password',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 14),
                              onPressed: decryptedPassword.isNotEmpty
                                  ? () => _copyToClipboard(decryptedPassword, 'Password copied')
                                  : null,
                              tooltip: 'Copy password',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            ),
                          ],
                        ),
                      ),

                      // Client
                      Expanded(
                        flex: 2,
                        child: Text(
                          _getClientNameForEntry(entry),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Type
                      Expanded(
                        flex: 1,
                        child: _buildCompactTypeChip(entry.type),
                      ),

                      // Actions
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              onPressed: () => _editPasswordEntry(entry),
                              tooltip: 'Edit',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 16, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _deletePasswordEntry(entry),
                              tooltip: 'Delete',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTypeChip(PasswordType type) {
    final typeLabel = _getPasswordTypeLabel(type);
    final typeColor = _getPasswordTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Text(
        typeLabel,
        style: TextStyle(
          color: typeColor,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getPasswordTypeLabel(PasswordType type) {
    switch (type) {
      case PasswordType.regular: return 'Reg';
      case PasswordType.enable: return 'En';
      case PasswordType.admin: return 'Adm';
      case PasswordType.service: return 'Svc';
      case PasswordType.custom: return 'Cust';
    }
  }

  Color _getPasswordTypeColor(PasswordType type) {
    final context = this.context;
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

  Future<void> _copyToClipboard(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddPasswordDialog(BuildContext context) {
    final clients = context.read<AppProvider>().clients;

    if (clients.isEmpty) {
      // No clients exist, need to create one first
      _showCreateClientDialog(context);
    } else {
      // Show client selection dialog, then password dialog
      _showClientSelectionDialog(context);
    }
  }

  void _showCreateClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                hintText: 'e.g., Google, AWS, Company Inc.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description of the client',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newClient = Client(
                  name: name,
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );
                context.read<AppProvider>().addClient(newClient);
                Navigator.of(context).pop();
                // Now show password creation for the new client
                _showPasswordDialogForClient(context, newClient.id, newClient.name);
              }
            },
            child: const Text('Create & Add Password'),
          ),
        ],
      ),
    );
  }

  void _showClientSelectionDialog(BuildContext context) {
    final clients = context.read<AppProvider>().clients;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Client'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                title: Text(client.name),
                subtitle: client.description != null ? Text(client.description!) : null,
                onTap: () {
                  Navigator.of(context).pop();
                  _showPasswordDialogForClient(context, client.id, client.name);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCreateClientDialog(context);
            },
            child: const Text('New Client'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialogForClient(BuildContext context, String clientId, String clientName) {
    showDialog(
      context: context,
      builder: (context) => AddPasswordDialog(clientId: clientId),
    );
  }

  void _editPasswordEntry(PasswordEntry entry) {
    final clientId = _findClientIdForEntry(entry);
    if (clientId != null) {
      showDialog(
        context: context,
        builder: (context) => AddPasswordDialog(
          clientId: clientId,
          passwordEntry: entry,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not find client for this password entry')),
      );
    }
  }

  void _deletePasswordEntry(PasswordEntry entry) {
    showDialog(
      context: context,
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
              final clientId = _findClientIdForEntry(entry);
              if (clientId != null) {
                context.read<AppProvider>().deletePasswordEntry(clientId, entry.id);
              }
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

  void _showImportExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import/Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Data'),
              subtitle: const Text('Save all data to a backup file'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final exportData = await context.read<AppProvider>().exportData();
                  // In a real app, you'd save this to a file
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export functionality coming soon!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Import Data'),
              subtitle: const Text('Restore from a backup file'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import functionality coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Master Password'),
              subtitle: const Text('Change encryption password'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Master password settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: const Text('Light/Dark mode settings'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear All Data'),
              subtitle: const Text('Remove all passwords and clients'),
              onTap: () {
                Navigator.of(context).pop();
                _showClearDataConfirmation();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your passwords and clients. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().clearAllData();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatLastUpdate() {
    final allEntries = _getAllEntries();
    if (allEntries.isEmpty) return 'Never';

    final mostRecent = allEntries
        .map((e) => e.updatedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final now = DateTime.now();
    final difference = now.difference(mostRecent);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${mostRecent.month}/${mostRecent.day}/${mostRecent.year}';
    }
  }

  String? _findClientIdForEntry(PasswordEntry entry) {
    final clients = context.read<AppProvider>().clients;
    for (final client in clients) {
      if (client.passwordEntries.any((e) => e.id == entry.id)) {
        return client.id;
      }
    }
    return null;
  }
}
