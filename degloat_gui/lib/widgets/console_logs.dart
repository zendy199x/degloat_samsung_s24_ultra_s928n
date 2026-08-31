import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/log_line.dart';

class ConsoleLogs extends StatelessWidget {
  final List<LogLine> logs;
  final bool isRunningAction;
  final ScrollController scrollController;
  final VoidCallback? onStopPressed;
  final VoidCallback onClearPressed;
  final BuildContext screenContext;

  const ConsoleLogs({
    super.key,
    required this.logs,
    required this.isRunningAction,
    required this.scrollController,
    required this.onClearPressed,
    required this.screenContext,
    this.onStopPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
            color: const Color(0xFF010409).withValues(alpha: 0.78),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 450;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B0F19),
                      border: Border(bottom: BorderSide(color: Colors.white10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.code_rounded, color: Colors.white60, size: 16),
                            ),
                            const SizedBox(width: 8),
                            if (!isNarrow)
                              Text(
                                l10n.console_header,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            if (isRunningAction) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 8,
                                      height: 8,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Color(0xFF00E5FF),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      l10n.btn_stop.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF00E5FF),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (isRunningAction && onStopPressed != null) ...[
                              isNarrow
                                  ? IconButton(
                                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent, size: 18),
                                      onPressed: onStopPressed,
                                      tooltip: l10n.btn_stop,
                                      visualDensity: VisualDensity.compact,
                                    )
                                  : TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      icon: const Icon(Icons.stop_circle_outlined, size: 16),
                                      label: Text(
                                        l10n.btn_stop,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: onStopPressed,
                                    ),
                              const SizedBox(width: 4),
                            ],
                            isNarrow
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 18),
                                    onPressed: onClearPressed,
                                    tooltip: l10n.btn_clear_logs,
                                    visualDensity: VisualDensity.compact,
                                  )
                                : TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white54,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: Text(
                                      l10n.btn_clear_logs,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    onPressed: onClearPressed,
                                  ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white54),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                final allText = logs.map((l) => l.text).join('\n');
                                Clipboard.setData(ClipboardData(text: allText));
                                ScaffoldMessenger.of(screenContext).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.copied_snackbar),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              tooltip: l10n.btn_copy_logs,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF010409),
                  padding: const EdgeInsets.all(16),
                  child: logs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.terminal_rounded, size: 40, color: Colors.white10),
                              const SizedBox(height: 10),
                              Text(
                                l10n.console_empty_title,
                                style: const TextStyle(color: Colors.white24, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.console_empty_subtitle,
                                style: const TextStyle(color: Colors.white24, fontSize: 10.5),
                              ),
                            ],
                          ),
                        )
                      : Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: logs
                                    .map(
                                      (log) => Container(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: SelectableText(
                                          log.text,
                                          style: TextStyle(
                                            fontFamily: 'Courier',
                                            fontSize: 12,
                                            color: log.color,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
