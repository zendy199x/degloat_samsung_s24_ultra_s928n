import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/bloat_group.dart';
import '../utils/package_rules.dart';

class AppInfo {
  final String packageName;
  final String label;
  final bool isSystem;

  AppInfo({
    required this.packageName,
    required this.label,
    required this.isSystem,
  });
}

class ManualAppsPanel extends StatefulWidget {
  final DeviceConnectionStatus connectionStatus;
  final Future<List<String>> Function() onLoadAllPackages;
  final Future<List<String>> Function() onLoadSystemPackages;
  final Future<void> Function(List<String> packages, String action) onExecuteAction;
  final bool isRunningAction;

  const ManualAppsPanel({
    super.key,
    required this.connectionStatus,
    required this.onLoadAllPackages,
    required this.onLoadSystemPackages,
    required this.onExecuteAction,
    required this.isRunningAction,
  });

  @override
  State<ManualAppsPanel> createState() => _ManualAppsPanelState();
}

class _ManualAppsPanelState extends State<ManualAppsPanel> {
  List<AppInfo> _appsList = [];
  final Set<String> _selectedPackages = {};
  bool _isLoading = false;
  String _searchQuery = '';
  String _filter = 'all'; // 'all', 'system', 'user'

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  @override
  void didUpdateWidget(covariant ManualAppsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connectionStatus != oldWidget.connectionStatus) {
      final isConnected = widget.connectionStatus == DeviceConnectionStatus.connectedCorrectModel ||
          widget.connectionStatus == DeviceConnectionStatus.connectedWrongModel ||
          widget.connectionStatus == DeviceConnectionStatus.localRootAvailable ||
          widget.connectionStatus == DeviceConnectionStatus.localShizukuAvailable;
      
      final wasConnected = oldWidget.connectionStatus == DeviceConnectionStatus.connectedCorrectModel ||
          oldWidget.connectionStatus == DeviceConnectionStatus.connectedWrongModel ||
          oldWidget.connectionStatus == DeviceConnectionStatus.localRootAvailable ||
          oldWidget.connectionStatus == DeviceConnectionStatus.localShizukuAvailable;

      if (isConnected && (!wasConnected || _appsList.isEmpty)) {
        _loadPackages();
      }
    }
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _selectedPackages.clear();
    });

    try {
      if (!kIsWeb && Platform.isAndroid) {
        // Fetch apps directly from Android Package Manager for fast, real-time label resolution
        try {
          final List<dynamic>? nativeApps = await const MethodChannel("com.degloat.app/shizuku")
              .invokeMethod<List<dynamic>>("getInstalledApps");
          if (nativeApps != null) {
            final List<AppInfo> apps = nativeApps.map((item) {
              final map = Map<String, dynamic>.from(item);
              return AppInfo(
                packageName: map["packageName"] as String? ?? "",
                label: map["label"] as String? ?? "",
                isSystem: map["isSystem"] as bool? ?? false,
              );
            }).toList();

            apps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

            if (mounted) {
              setState(() {
                _appsList = apps;
                _isLoading = false;
              });
            }
            return;
          }
        } catch (_) {}
      }

      // Desktop ADB or fallback loader
      final pkgs = await widget.onLoadAllPackages();
      final systemPkgs = (await widget.onLoadSystemPackages()).toSet();

      final List<AppInfo> apps = pkgs.map((pkg) {
        String friendlyLabel = SystemConfig.getFriendlyAppName(pkg);
        if (friendlyLabel.isEmpty) {
          friendlyLabel = pkg.split('.').last;
        }
        return AppInfo(
          packageName: pkg,
          label: friendlyLabel,
          isSystem: systemPkgs.contains(pkg),
        );
      }).toList();

      apps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

      if (mounted) {
        setState(() {
          _appsList = apps;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isProtected(String pkg) => PackageRules.shouldSkipDegloat(pkg);

  List<AppInfo> _getFilteredPackages() {
    return _appsList.where((app) {
      // Search filter (searches friendly label or package ID)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final labelMatch = app.label.toLowerCase().contains(query);
        final pkgMatch = app.packageName.toLowerCase().contains(query);
        if (!labelMatch && !pkgMatch) return false;
      }
      // Type filter
      if (_filter == 'system' && !app.isSystem) return false;
      if (_filter == 'user' && app.isSystem) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _getFilteredPackages();
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Refresh Button
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.tab_manual,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isLight ? Colors.black54 : Colors.white70,
                  size: 20,
                ),
                onPressed: _isLoading || widget.isRunningAction ? null : _loadPackages,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: l10n.search_placeholder,
              hintStyle: TextStyle(color: isLight ? Colors.black38 : Colors.white24, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: isLight ? Colors.black38 : Colors.white24, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: isLight ? Colors.white : const Color(0xFF151D30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isLight ? Colors.black12 : Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.06)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF)),
              ),
            ),
            style: TextStyle(fontSize: 13, color: isLight ? Colors.black87 : Colors.white),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 10),

          // Swift-style dropdown filter selector
          PopupMenuButton<String>(
            initialValue: _filter,
            tooltip: 'Filter apps',
            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'all',
                child: Text(l10n.filter_all),
              ),
              PopupMenuItem<String>(
                value: 'system',
                child: Text(l10n.filter_system),
              ),
              PopupMenuItem<String>(
                value: 'user',
                child: Text(l10n.manual_filter_user),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFEAF4FF) : const Color(0xFF121B2B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    size: 16,
                    color: isLight ? const Color(0xFF0A84FF) : const Color(0xFF80D8FF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _filter == 'all'
                        ? l10n.filter_all
                        : _filter == 'system'
                            ? l10n.filter_system
                            : l10n.manual_filter_user,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLight ? Colors.black87 : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: isLight ? Colors.black54 : Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Selection toolbar (Select All)
          if (filtered.isNotEmpty && !_isLoading)
            Row(
              children: [
                Checkbox(
                  value: filtered.every((app) => _isProtected(app.packageName) || _selectedPackages.contains(app.packageName)),
                  tristate: true,
                  activeColor: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        for (var app in filtered) {
                          if (!_isProtected(app.packageName)) _selectedPackages.add(app.packageName);
                        }
                      } else {
                        for (var app in filtered) {
                          _selectedPackages.remove(app.packageName);
                        }
                      }
                    });
                  },
                ),
                Text(
                  l10n.manual_select_all(filtered.length.toString()),
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? Colors.black54 : Colors.white70,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),

          // App List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _appsList.isEmpty ? l10n.manual_no_device : l10n.manual_no_search,
                          style: TextStyle(
                            color: isLight ? Colors.black38 : Colors.white24,
                            fontSize: 11,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final app = filtered[index];
                          final isSys = app.isSystem;
                          final isProt = _isProtected(app.packageName);
                          final isSelected = _selectedPackages.contains(app.packageName);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isLight ? const Color(0xFF00B0FF).withValues(alpha: 0.08) : const Color(0xFF00E5FF).withValues(alpha: 0.05))
                                  : (isLight ? Colors.white : const Color(0xFF151D30)),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isLight
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                              border: Border.all(
                                color: isSelected
                                    ? (isLight ? const Color(0xFF00B0FF).withValues(alpha: 0.4) : const Color(0xFF00E5FF).withValues(alpha: 0.3))
                                    : (isLight ? Colors.black.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.04)),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: isProt
                                  ? Tooltip(
                                      message: l10n.manual_protected_tooltip,
                                      child: const Icon(Icons.shield_rounded, color: Colors.redAccent, size: 18),
                                    )
                                  : Checkbox(
                                      value: isSelected,
                                      activeColor: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedPackages.add(app.packageName);
                                          } else {
                                            _selectedPackages.remove(app.packageName);
                                          }
                                        });
                                      },
                                    ),
                              title: Text(
                                app.label,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isProt
                                      ? (isLight ? Colors.black26 : Colors.white30)
                                      : isSelected
                                          ? (isLight ? const Color(0xFF0091EA) : const Color(0xFF00E5FF))
                                          : (isLight ? Colors.black87 : Colors.white70),
                                  decoration: isProt ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: Text(
                                app.packageName,
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  color: isLight ? Colors.black45 : Colors.white38,
                                  decoration: isProt ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isProt)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        l10n.protected_badge.toUpperCase(),
                                        style: const TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  else if (isSys)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        l10n.manual_app_type_system,
                                        style: const TextStyle(color: Color(0xFFB39DDB), fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        l10n.manual_app_type_user,
                                        style: const TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 8),

          // Actions panel
          if (_selectedPackages.isNotEmpty && !widget.isRunningAction && !_isLoading)
            Container(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: isLight ? Colors.black12 : Colors.white10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        widget.onExecuteAction(_selectedPackages.toList(), 'uninstall');
                        setState(() {
                          _selectedPackages.clear();
                        });
                      },
                      icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                      label: Text(
                        l10n.btn_uninstall_selected(_selectedPackages.length.toString()),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isLight ? const Color(0xFF6200EE) : const Color(0xFFB39DDB),
                        side: BorderSide(color: isLight ? const Color(0xFF6200EE) : const Color(0xFFB39DDB), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        widget.onExecuteAction(_selectedPackages.toList(), 'disable');
                        setState(() {
                          _selectedPackages.clear();
                        });
                      },
                      icon: const Icon(Icons.block_flipped, size: 18),
                      label: Text(
                        l10n.btn_disable_selected(_selectedPackages.length.toString()),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
