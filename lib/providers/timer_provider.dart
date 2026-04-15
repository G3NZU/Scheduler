import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/work_session.dart';
import '../models/break_entry.dart';
import '../services/hive_service.dart';

/// Represents the current state of the timer UI.
enum TimerState { stopped, working, onBreak }

/// Manages the active work session and drives the UI timer tick.
///
/// Key design: the elapsed time is always calculated from stored timestamps
/// rather than an in-memory counter. This means the app can be killed and
/// restarted without losing time.
class TimerProvider extends ChangeNotifier {
  WorkSession? _activeSession;
  Timer? _ticker;

  /// Current timer state derived from the active session.
  TimerState get state {
    if (_activeSession == null) return TimerState.stopped;
    if (_activeSession!.isOnBreak) return TimerState.onBreak;
    return TimerState.working;
  }

  /// The active session (null if none).
  WorkSession? get activeSession => _activeSession;

  /// Current elapsed worked duration (updates every second via ticker).
  Duration get elapsed => _activeSession?.workedDuration ?? Duration.zero;

  /// Load state from Hive on app start (handles restarts mid-session).
  Future<void> loadFromStorage() async {
    _activeSession = HiveService.getActiveSession();
    if (_activeSession != null) {
      _startTicker();
    }
    notifyListeners();
  }

  /// Start a new work session.
  Future<void> startSession() async {
    if (_activeSession != null) return; // Already running

    _activeSession = WorkSession(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
    );
    await HiveService.saveSession(_activeSession!);
    _startTicker();
    notifyListeners();
  }

  /// Pause: record a break start timestamp.
  Future<void> pauseSession() async {
    if (_activeSession == null || _activeSession!.isOnBreak) return;

    _activeSession!.breaks.add(BreakEntry(startTime: DateTime.now()));
    await HiveService.saveSession(_activeSession!);
    notifyListeners();
  }

  /// Resume: record break end timestamp.
  Future<void> resumeSession() async {
    if (_activeSession == null || !_activeSession!.isOnBreak) return;

    _activeSession!.breaks.last.endTime = DateTime.now();
    await HiveService.saveSession(_activeSession!);
    notifyListeners();
  }

  /// Stop: record session end timestamp and clear active session.
  Future<void> stopSession() async {
    if (_activeSession == null) return;

    // If on break, end the break first
    if (_activeSession!.isOnBreak) {
      _activeSession!.breaks.last.endTime = DateTime.now();
    }

    _activeSession!.endTime = DateTime.now();
    await HiveService.saveSession(_activeSession!);

    _stopTicker();
    _activeSession = null;
    notifyListeners();
  }

  /// Discard the active session without saving it.
  Future<void> discardSession() async {
    if (_activeSession == null) return;

    await HiveService.deleteSession(_activeSession!.id);
    _stopTicker();
    _activeSession = null;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    // Tick every second to update the timer display
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
