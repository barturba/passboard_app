class AppSettings {
  final bool isBiometricEnabled;
  final bool isFirstLaunch;
  final String? masterPasswordHash;
  final DateTime? lastBackupDate;

  const AppSettings({
    this.isBiometricEnabled = false,
    this.isFirstLaunch = true,
    this.masterPasswordHash,
    this.lastBackupDate,
  });

  AppSettings copyWith({
    bool? isBiometricEnabled,
    bool? isFirstLaunch,
    String? masterPasswordHash,
    DateTime? lastBackupDate,
  }) {
    return AppSettings(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      masterPasswordHash: masterPasswordHash ?? this.masterPasswordHash,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isBiometricEnabled': isBiometricEnabled,
      'isFirstLaunch': isFirstLaunch,
      'masterPasswordHash': masterPasswordHash,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
      isFirstLaunch: json['isFirstLaunch'] as bool? ?? true,
      masterPasswordHash: json['masterPasswordHash'] as String?,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
    );
  }
}
