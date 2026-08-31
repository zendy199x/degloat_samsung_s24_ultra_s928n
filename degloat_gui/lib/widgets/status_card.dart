import 'package:flutter/material.dart';

import '../services/json_localization_service.dart';

class StatusCard extends StatelessWidget {
  final Color statusColor;
  final String statusTitle;
  final String statusSubtitle;
  final IconData icon;
  final bool isPulsing;
  final bool isChecking;
  final VoidCallback? onRefresh;

  const StatusCard({
    super.key,
    required this.statusColor,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.icon,
    this.isPulsing = false,
    this.isChecking = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? Colors.black54 : Colors.white60;
    final titleColor = isLight ? Colors.black87 : Colors.white70;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          _StatusIconPulse(
            color: statusColor,
            icon: icon,
            isPulsing: isPulsing || isChecking,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.5,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                icon: isChecking
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: statusColor,
                        ),
                      )
                    : Icon(Icons.refresh, color: statusColor, size: 22),
                onPressed: isChecking ? null : onRefresh,
                tooltip: jsonLocalizationService.get('refresh_status'),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusIconPulse extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool isPulsing;

  const _StatusIconPulse({
    required this.color,
    required this.icon,
    required this.isPulsing,
  });

  @override
  State<_StatusIconPulse> createState() => _StatusIconPulseState();
}

class _StatusIconPulseState extends State<_StatusIconPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _StatusIconPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.animateTo(1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: widget.color.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
        );
      },
    );
  }
}
