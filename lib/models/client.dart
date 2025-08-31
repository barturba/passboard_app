import 'package:uuid/uuid.dart';
import 'password_entry.dart';

class Client {
  final String id;
  final String name;
  final String? description;
  final List<PasswordEntry> passwordEntries;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    String? id,
    required this.name,
    this.description,
    List<PasswordEntry>? passwordEntries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    id = id ?? const Uuid().v4(),
    passwordEntries = passwordEntries ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Create a copy with updated fields
  Client copyWith({
    String? name,
    String? description,
    List<PasswordEntry>? passwordEntries,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      passwordEntries: passwordEntries ?? this.passwordEntries,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Add a password entry
  Client addPasswordEntry(PasswordEntry entry) {
    return copyWith(
      passwordEntries: [...passwordEntries, entry],
      updatedAt: DateTime.now(),
    );
  }

  // Update a password entry
  Client updatePasswordEntry(PasswordEntry updatedEntry) {
    final updatedEntries = passwordEntries.map((entry) {
      return entry.id == updatedEntry.id ? updatedEntry : entry;
    }).toList();

    return copyWith(
      passwordEntries: updatedEntries,
      updatedAt: DateTime.now(),
    );
  }

  // Remove a password entry
  Client removePasswordEntry(String entryId) {
    return copyWith(
      passwordEntries: passwordEntries.where((entry) => entry.id != entryId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Get password entries by type
  List<PasswordEntry> getPasswordEntriesByType(PasswordType type) {
    return passwordEntries.where((entry) => entry.type == type).toList();
  }

  // Get all password types used by this client
  Set<PasswordType> get passwordTypes {
    return passwordEntries.map((entry) => entry.type).toSet();
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'passwordEntries': passwordEntries.map((entry) => entry.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      passwordEntries: (json['passwordEntries'] as List<dynamic>?)
          ?.map((entryJson) => PasswordEntry.fromJson(entryJson as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Client(id: $id, name: $name, passwordEntries: ${passwordEntries.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
