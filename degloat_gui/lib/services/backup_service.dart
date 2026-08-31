import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Secure backup metadata structure with device verification.
class BackupMetadata {
  final String backupId; // Unique backup identifier
  final String deviceSerial; // Device serial number
  final String deviceModel; // Device model name
  final String deviceImei; // Device IMEI (if available)
  final DateTime createdAt; // Backup creation timestamp
  final List<String> removedPackages; // Packages that were removed
  final int packageCount; // Total count of backed up packages
  final String appVersion; // App version at time of backup

  BackupMetadata({
    required this.backupId,
    required this.deviceSerial,
    required this.deviceModel,
    required this.deviceImei,
    required this.createdAt,
    required this.removedPackages,
    required this.packageCount,
    required this.appVersion,
  });

  /// Convert to JSON for file storage
  Map<String, dynamic> toJson() => {
    'backupId': backupId,
    'deviceSerial': deviceSerial,
    'deviceModel': deviceModel,
    'deviceImei': deviceImei,
    'createdAt': createdAt.toIso8601String(),
    'removedPackages': removedPackages,
    'packageCount': packageCount,
    'appVersion': appVersion,
  };

  /// Create from JSON
  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
    backupId: json['backupId'] as String? ?? 'unknown',
    deviceSerial: json['deviceSerial'] as String? ?? '',
    deviceModel: json['deviceModel'] as String? ?? '',
    deviceImei: json['deviceImei'] as String? ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    removedPackages: List<String>.from(json['removedPackages'] ?? []),
    packageCount: json['packageCount'] as int? ?? 0,
    appVersion: json['appVersion'] as String? ?? '1.0.0',
  );
}

/// Backup file structure with metadata and package data
class BackupFile {
  final BackupMetadata metadata;
  final List<String> allPackages; // All packages to restore
  final Map<String, dynamic> rawData; // Raw backup data

  BackupFile({
    required this.metadata,
    required this.allPackages,
    required this.rawData,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'packages': allPackages,
  };
}

/// Safe backup service with device verification and metadata tracking
class BackupService {
  /// Get the backup directory path (cross-platform)
  static String getBackupDirectory() {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    final backupDir = '$home/.degloat_backups';
    final dir = Directory(backupDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return backupDir;
  }

  /// Generate unique backup filename with device serial and timestamp
  static String generateBackupFilename(String deviceSerial, String deviceImei) {
    final timestamp = DateTime.now().toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    // Use both serial and IMEI for unique identification
    final identifier = '$deviceSerial-$deviceImei'.replaceAll(RegExp(r'[^\w-]'), '_');
    return 'backup_${identifier}_$timestamp.json';
  }

  /// Save backup file with device verification metadata
  static Future<bool> saveBackup({
    required String deviceSerial,
    required String deviceModel,
    required String deviceImei,
    required List<String> removedPackages,
    required List<String> allPackages,
  }) async {
    try {
      final backupDir = getBackupDirectory();
      final filename = generateBackupFilename(deviceSerial, deviceImei);
      final filepath = '$backupDir/$filename';

      final metadata = BackupMetadata(
        backupId: DateTime.now().millisecondsSinceEpoch.toString(),
        deviceSerial: deviceSerial,
        deviceModel: deviceModel,
        deviceImei: deviceImei,
        createdAt: DateTime.now(),
        removedPackages: removedPackages,
        packageCount: allPackages.length,
        appVersion: '1.0.0', // Update as needed
      );

      final backupData = {
        'metadata': metadata.toJson(),
        'packages': allPackages,
      };

      final file = File(filepath);
      await file.writeAsString(jsonEncode(backupData), flush: true);
      debugPrint('Backup saved: $filepath');
      return true;
    } catch (e) {
      debugPrint('Error saving backup: $e');
      return false;
    }
  }

  /// Load backup file with device verification
  static Future<BackupFile?> loadBackup({
    required String filepath,
    required String currentDeviceSerial,
    required String currentDeviceImei,
  }) async {
    try {
      final file = File(filepath);
      if (!file.existsSync()) {
        debugPrint('Backup file not found: $filepath');
        return null;
      }

      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final metadataJson = data['metadata'] as Map<String, dynamic>? ?? {};
      final metadata = BackupMetadata.fromJson(metadataJson);

      // Verify device matches
      if (!_verifyDeviceMatch(metadata, currentDeviceSerial, currentDeviceImei)) {
        debugPrint(
          'Device mismatch! Backup is for ${metadata.deviceSerial} (IMEI: ${metadata.deviceImei}), '
          'but current device is $currentDeviceSerial (IMEI: $currentDeviceImei)',
        );
        return null;
      }

      final packages = List<String>.from(data['packages'] ?? []);
      return BackupFile(
        metadata: metadata,
        allPackages: packages,
        rawData: data,
      );
    } catch (e) {
      debugPrint('Error loading backup: $e');
      return null;
    }
  }

  /// Verify if backup device matches current device
  static bool _verifyDeviceMatch(
    BackupMetadata metadata,
    String currentSerial,
    String currentImei,
  ) {
    // If IMEI is available, it's the most reliable identifier
    if (metadata.deviceImei.isNotEmpty && currentImei.isNotEmpty) {
      return metadata.deviceImei == currentImei;
    }

    // Fall back to serial number
    return metadata.deviceSerial == currentSerial;
  }

  /// List all available backups
  static Future<List<FileSystemEntity>> listAvailableBackups() async {
    try {
      final backupDir = Directory(getBackupDirectory());
      if (!backupDir.existsSync()) return [];

      return backupDir
          .listSync()
          .where((entity) => entity.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    } catch (e) {
      debugPrint('Error listing backups: $e');
      return [];
    }
  }

  /// Get backup info from file without full load
  static Future<BackupMetadata?> getBackupMetadata(String filepath) async {
    try {
      final file = File(filepath);
      if (!file.existsSync()) return null;

      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final metadataJson = data['metadata'] as Map<String, dynamic>? ?? {};
      return BackupMetadata.fromJson(metadataJson);
    } catch (e) {
      debugPrint('Error reading backup metadata: $e');
      return null;
    }
  }

  /// Delete a backup file
  static Future<bool> deleteBackup(String filepath) async {
    try {
      final file = File(filepath);
      if (file.existsSync()) {
        await file.delete();
        debugPrint('Backup deleted: $filepath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }
}
