import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/services.dart';

class AddPasswordDialog extends StatefulWidget {
  final String clientId;
  final PasswordEntry? passwordEntry;

  const AddPasswordDialog({
    super.key,
    required this.clientId,
    this.passwordEntry,
  });

  @override
  State<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends State<AddPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();

  PasswordType _selectedType = PasswordType.regular;
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.passwordEntry != null) {
      final entry = widget.passwordEntry!;
      _titleController.text = entry.title;
      _usernameController.text = entry.username;
      _selectedType = entry.type;
      _notesController.text = entry.notes ?? '';

      // Password decryption will be handled in didChangeDependencies
      _passwordController.text = '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.passwordEntry != null && _passwordController.text.isEmpty) {
      // Decrypt the password for editing
      try {
        final encryptionService = context.read<EncryptionService>();
        _passwordController.text = encryptionService.decryptPassword(widget.passwordEntry!.encryptedPassword);
      } catch (e) {
        // If decryption fails, leave the field empty
        _passwordController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.passwordEntry != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Password Entry' : 'Add Password Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Main Login, Admin Access, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username or email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<PasswordType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Password Type',
                  border: OutlineInputBorder(),
                ),
                items: PasswordType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getPasswordTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional notes or instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePasswordEntry,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _savePasswordEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      final encryptionService = context.read<EncryptionService>();

      // Encrypt the password before storing
      final encryptedPassword = encryptionService.encryptPassword(password);

      if (widget.passwordEntry != null) {
        // Update existing password entry
        final updatedEntry = widget.passwordEntry!.copyWith(
          title: title,
          username: username,
          encryptedPassword: encryptedPassword,
          notes: notes,
          type: _selectedType,
        );
        await context.read<AppProvider>().updatePasswordEntry(
          widget.clientId,
          updatedEntry,
        );
      } else {
        // Create new password entry
        final newEntry = PasswordEntry(
          title: title,
          username: username,
          encryptedPassword: encryptedPassword,
          notes: notes,
          type: _selectedType,
        );
        await context.read<AppProvider>().addPasswordEntry(
          widget.clientId,
          newEntry,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.passwordEntry != null
                  ? 'Password entry updated successfully'
                  : 'Password entry added successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
}
