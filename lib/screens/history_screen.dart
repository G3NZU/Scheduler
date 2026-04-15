import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/work_session.dart';
import '../services/hive_service.dart';
import '../services/calculation_service.dart';
import '../widgets/session_card.dart';

/// History screen showing past sessions grouped by calendar day.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      // ValueListenableBuilder rebuilds whenever the Hive box changes
      body: ValueListenableBuilder<Box<WorkSession>>(
        valueListenable: HiveService.sessionsBox.listenable(),
        builder: (context, box, _) {
          final sessions = HiveService.getAllSessions()
              .where((s) => !s.isActive) // Only completed sessions
              .toList();

          if (sessions.isEmpty) {
            return const Center(
              child: Text('No sessions recorded yet.'),
            );
          }

          // Group sessions by calendar day
          final Map<String, List<WorkSession>> grouped = {};
          for (final s in sessions) {
            final key = DateFormat('yyyy-MM-dd').format(s.startTime);
            grouped.putIfAbsent(key, () => []).add(s);
          }

          final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final dayKey = days[index];
              final daySessions = grouped[dayKey]!;
              final dayDate = DateFormat('yyyy-MM-dd').parse(dayKey);
              final totalWorked = daySessions.fold<Duration>(
                Duration.zero,
                (prev, s) => prev + s.workedDuration,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          _dayLabel(dayDate),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          CalculationService.formatDurationShort(totalWorked),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  ...daySessions.map((s) => SessionCard(session: s)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE, MMMM d').format(date);
  }
}
