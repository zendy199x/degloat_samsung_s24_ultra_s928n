import '../models/bloat_group.dart';

class PackageRules {
  /// Ultra-safe degloat skip list - Knox security packages only
  /// Xóa nhầm Knox packages có thể gây device bootloop
  static bool shouldSkipDegloat(String pkg) {
    final lower = pkg.toLowerCase();

    // Check hardcoded protected list first
    if (SystemConfig.protectedPackages.contains(pkg)) return true;

    // Knox Security Framework
    if (lower.contains('knox')) return true;
    if (lower.contains('kguard')) return true;
    if (lower.contains('klms')) return true;
    if (lower.contains('securitylogagent')) return true;

    return false;
  }

  static bool shouldSkipMissingWarning(String pkg) => false;
}
