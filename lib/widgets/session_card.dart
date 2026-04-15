import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/work_session.dart';
import '../services/calculation_service.dart';

/// Card widget displaying a single completed work session.
class SessionCard extends StatelessWidget {
  final WorkSession session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startStr = DateFormat('HH:mm').format(session.startTime);
    final endStr = session.endTime != null
        ? DateFormat('HH:mm').format(session.endTime!)
        : '--:--';
    final workedStr =
        CalculationService.formatDurationShort(session.workedDuration);
    final breakStr = session.breaks.isNotEmpty
        ? CalculationService.formatDurationShort(session.totalBreakDuration)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time range
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startStr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '→ $endStr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Worked + break time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.work_outline,
                        size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      workedStr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (breakStr != null)
                  Row(
                    children: [
                      Icon(Icons.free_breakfast_outlined,
                          size: 12, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        'Break: $breakStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
