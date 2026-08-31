import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class KnoxBadge extends StatelessWidget {
  const KnoxBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bgColor = isLight
        ? const Color(0xFFEAF7EE)
        : const Color(0xFF0D2618).withValues(alpha: 0.7);
    final borderColor = isLight
        ? const Color(0xFFC6EBD2)
        : const Color(0xFF69D58F).withValues(alpha: 0.25);
    final contentColor = isLight
        ? const Color(0xFF1E7A45)
        : const Color(0xFF9CE9B5);

    return Tooltip(
      message: l10n.knox_guard_tooltip,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: isLight ? Colors.black.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: contentColor.withValues(alpha: isLight ? 0.1 : 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: contentColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.knox_guard_active,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: contentColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
