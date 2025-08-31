import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class PasswordEntryCard extends StatefulWidget {
  final PasswordEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? decryptedPassword;

  const PasswordEntryCard({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
    this.decryptedPassword,
  });

  @override
  State<PasswordEntryCard> createState() => _PasswordEntryCardState();
}

class _PasswordEntryCardState extends State<PasswordEntryCard> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.entry.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildPasswordTypeChip(context),
                if (widget.onEdit != null || widget.onDelete != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          widget.onEdit?.call();
                          break;
                        case 'delete':
                          widget.onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (widget.onEdit != null)
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
                      if (widget.onDelete != null)
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

            // Username field
            _buildCopyableField(
              context,
              label: 'Username',
              value: widget.entry.username,
              icon: Icons.person,
            ),

            const SizedBox(height: 8),

            // Password field
            _buildPasswordField(context),

            // Notes field (if present)
            if (widget.entry.notes != null && widget.entry.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.entry.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDateTime(widget.entry.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyableField(BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(value, '$label copied'),
                    tooltip: 'Copy $label',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final displayPassword = widget.decryptedPassword ?? '••••••••';
    final actualPassword = widget.decryptedPassword ?? '';

    return Row(
      children: [
        Icon(
          Icons.lock,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _showPassword ? actualPassword : displayPassword,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                    tooltip: _showPassword ? 'Hide password' : 'Show password',
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: actualPassword.isNotEmpty
                        ? () => _copyToClipboard(actualPassword, 'Password copied')
                        : null,
                    tooltip: 'Copy password',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTypeChip(BuildContext context) {
    final typeLabel = _getPasswordTypeLabel(widget.entry.type);
    final typeColor = _getPasswordTypeColor(widget.entry.type, context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Text(
        typeLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: typeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
