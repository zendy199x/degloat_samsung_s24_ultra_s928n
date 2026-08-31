import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/bloat_group.dart';

class AppList extends StatelessWidget {
  final List<BloatGroup> bloatGroups;

  const AppList({
    super.key,
    required this.bloatGroups,
  });

  String _getLocalizedTitle(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'group_korean_carriers': return l10n.group_korean_carriers;
      case 'group_us_carriers': return l10n.group_us_carriers;
      case 'group_korean_us_apps': return l10n.group_korean_us_apps;
      case 'group_korean_locales': return l10n.group_korean_locales;
      case 'group_smart_suggestions': return l10n.group_smart_suggestions;
      case 'group_samsung_wallet': return l10n.group_samsung_wallet;
      case 'group_samsung_bloat': return l10n.group_samsung_bloat;
      case 'group_meta_ms': return l10n.group_meta_ms;
      case 'group_bixby': return l10n.group_bixby;
      case 'group_game_launcher': return l10n.group_game_launcher;
      case 'group_samsung_services': return l10n.group_samsung_services;
      case 'group_bluetooth_beacons': return l10n.group_bluetooth_beacons;
      case 'group_telemetry': return l10n.group_telemetry;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalCount = bloatGroups.fold<int>(0, (prev, next) => prev + next.packages.length);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final panelBg = isLight ? Colors.white.withValues(alpha: 0.68) : const Color(0xFF101827).withValues(alpha: 0.72);
    final borderColor = isLight ? Colors.black.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.08);
    final accent = isLight ? const Color(0xFF007AFF) : const Color(0xFF5AC8FA);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isLight ? 0.12 : 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.view_list_rounded, color: accent, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.app_list_title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFF1F5F9) : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.app_list_total(totalCount.toString()),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isLight ? Colors.black54 : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: bloatGroups.length,
              itemBuilder: (context, index) {
                final group = bloatGroups[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: panelBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: isLight ? Colors.black.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      iconColor: accent,
                      collapsedIconColor: isLight ? Colors.black54 : Colors.white70,
                      title: Text(
                        _getLocalizedTitle(context, group.titleKey),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isLight ? Colors.black87 : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "${group.packages.length} ${l10n.app_list_group_suffix}",
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isLight ? Colors.black45 : Colors.white54,
                        ),
                      ),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: group.packages.map((pkg) {
                        final friendlyName = SystemConfig.getFriendlyAppName(pkg);
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isLight ? const Color(0xFFEAF2FF) : const Color(0xFF172130),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.android_rounded, size: 13, color: accent),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (friendlyName.isNotEmpty) ...[
                                      Text(
                                        friendlyName,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: isLight ? Colors.black87 : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                    SelectableText(
                                      pkg,
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 10,
                                        color: isLight ? Colors.black54 : Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
