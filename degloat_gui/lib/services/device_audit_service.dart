import 'dart:io';

import '../models/bloat_group.dart';
import '../utils/package_rules.dart';

class DeviceAuditSummary {
  final Set<String> allInstalled;
  final Set<String> activeInstalled;
  final int totalBloatFound;
  final int totalBloat;
  final Set<String> missingProtected;
  final String csc;

  const DeviceAuditSummary({
    required this.allInstalled,
    required this.activeInstalled,
    required this.totalBloatFound,
    required this.totalBloat,
    required this.missingProtected,
    required this.csc,
  });
}

class DeviceAuditService {
  static Future<DeviceAuditSummary> runAudit({
    required Future<ProcessResult> Function(String, {List<String>? args}) runShell,
  }) async {
    final packagesResult = await runShell('pm list packages');
    final allInstalled = packagesResult.stdout.toString().split('\n')
        .map((line) => line.replaceFirst('package:', '').trim())
        .where((line) => line.isNotEmpty)
        .toSet();

    final disabledResult = await runShell('pm list packages -d');
    final disabledInstalled = disabledResult.stdout.toString().split('\n')
        .map((line) => line.replaceFirst('package:', '').trim())
        .where((line) => line.isNotEmpty)
        .toSet();

    final activeInstalled = allInstalled.difference(disabledInstalled);

    int totalBloatFound = 0;
    int totalBloat = 0;

    for (final group in SystemConfig.bloatGroups) {
      for (final pkg in group.packages) {
        totalBloat++;
        if (activeInstalled.contains(pkg) && !PackageRules.shouldSkipDegloat(pkg)) {
          totalBloatFound++;
        }
      }
    }

    final cscResult = await runShell('getprop ro.csc.sales_code');
    final missingProtected = SystemConfig.protectedPackages.difference(allInstalled);

    return DeviceAuditSummary(
      allInstalled: allInstalled,
      activeInstalled: activeInstalled,
      totalBloatFound: totalBloatFound,
      totalBloat: totalBloat,
      missingProtected: missingProtected,
      csc: cscResult.stdout.toString().trim(),
    );
  }
}
