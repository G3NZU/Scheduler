import 'package:flutter/material.dart';
import '../providers/timer_provider.dart';
import '../services/calculation_service.dart';

/// Large timer display widget showing HH:MM:SS.
/// Colour changes based on [state].
class TimerDisplay extends StatelessWidget {
  final Duration elapsed;
  final TimerState state;

  const TimerDisplay({
    super.key,
    required this.elapsed,
    required this.state,
  });

  Color _stateColor(BuildContext context) {
    switch (state) {
      case TimerState.working:
        return Theme.of(context).colorScheme.primary;
      case TimerState.onBreak:
        return Theme.of(context).colorScheme.tertiary;
      case TimerState.stopped:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _stateLabel() {
    switch (state) {
      case TimerState.working:
        return 'Working';
      case TimerState.onBreak:
        return 'On Break';
      case TimerState.stopped:
        return 'Stopped';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(context);
    return Column(
      children: [
        Text(
          CalculationService.formatDuration(elapsed),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: color,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _stateLabel(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
