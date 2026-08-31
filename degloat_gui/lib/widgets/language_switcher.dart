import 'package:flutter/material.dart';

class LanguageSwitcher extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSwitcher({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF4F6FA) : const Color(0xFF1B1F2A);
    final dividerColor = isLight ? const Color(0xFFD9DEE8) : const Color(0xFF2F3747);
    final borderColor = isLight ? const Color(0xFFE1E5EE) : const Color(0xFF394153);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.black.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: "EN",
            isActive: currentLanguage == 'en',
            onTap: () => onLanguageChanged('en'),
            isLight: isLight,
          ),
          Container(width: 1, height: 12, color: dividerColor),
          _LanguageButton(
            label: "VI",
            isActive: currentLanguage == 'vi',
            onTap: () => onLanguageChanged('vi'),
            isLight: isLight,
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLight;

  const _LanguageButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isLight ? const Color(0xFF007AFF) : const Color(0xFF5AC8FA);
    final inactiveColor = isLight ? const Color(0xFF6B7280) : const Color(0xFF9AA4B2);
    final activeBgColor = isLight ? const Color(0xFF007AFF).withValues(alpha: 0.12) : const Color(0xFF5AC8FA).withValues(alpha: 0.12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ),
    );
  }
}
