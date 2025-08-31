import 'package:flutter/material.dart';
import '../models/models.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (client.description != null && client.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              client.description!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPasswordEntriesSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordEntriesSummary(BuildContext context) {
    if (client.passwordEntries.isEmpty) {
      return Text(
        'No password entries',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final entryCount = client.passwordEntries.length;
    final types = client.passwordTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$entryCount password entr${entryCount == 1 ? 'y' : 'ies'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: types.map((type) {
            final count = client.getPasswordEntriesByType(type).length;
            return Chip(
              label: Text(
                '${_getPasswordTypeLabel(type)} ($count)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              backgroundColor: _getPasswordTypeColor(type, context),
              labelStyle: TextStyle(
                color: _getPasswordTypeTextColor(type, context),
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
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
        return Theme.of(context).colorScheme.primaryContainer;
      case PasswordType.enable:
        return Theme.of(context).colorScheme.secondaryContainer;
      case PasswordType.admin:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case PasswordType.service:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
      case PasswordType.custom:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  Color _getPasswordTypeTextColor(PasswordType type, BuildContext context) {
    switch (type) {
      case PasswordType.regular:
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case PasswordType.enable:
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case PasswordType.admin:
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case PasswordType.service:
        return Theme.of(context).colorScheme.onSurface;
      case PasswordType.custom:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}
