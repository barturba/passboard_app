import 'package:uuid/uuid.dart';

enum PasswordType {
  regular,
  enable,
  admin,
  service,
  custom
}

class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String encryptedPassword;
  final String? notes;
  final PasswordType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  PasswordEntry({
    String? id,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    this.notes,
    this.type = PasswordType.regular,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Create a copy with updated fields
  PasswordEntry copyWith({
    String? title,
    String? username,
    String? encryptedPassword,
    String? notes,
    PasswordType? type,
    DateTime? updatedAt,
  }) {
    return PasswordEntry(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'encryptedPassword': encryptedPassword,
      'notes': notes,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      username: json['username'] as String,
      encryptedPassword: json['encryptedPassword'] as String,
      notes: json['notes'] as String?,
      type: PasswordType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PasswordType.regular,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'PasswordEntry(id: $id, title: $title, username: $username, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
