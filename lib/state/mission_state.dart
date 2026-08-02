import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum MissionPhase { idle, active, paused, returning, aborted, completed }

class SurvivorHit {
  final int id;
  final String grid;
  final String detectedAt;
  final int confidence;
  const SurvivorHit(this.id, this.grid, this.detectedAt, this.confidence);
}

class TimelineEvent {
  final String label;
  final String time;
  final bool done;
  const TimelineEvent(this.label, this.time, {this.done = true});
}

class MissionNotice {
  final String time;
  final String message;
  final Color Function(dynamic palette) colorOf;
  const MissionNotice(this.time, this.message, this.colorOf);
}

class MissionState extends ChangeNotifier {
  MissionPhase phase = MissionPhase.idle;
  bool armed = false;

  Duration elapsed = Duration.zero;
  Timer? _ticker;

  double explorationPercent = 0.0;
  int battery = 92;
  double altitude = 1.8;
  double speed = 0.0;
  double signalDbm = -58;
  double tempC = 34;

  // Rolling history for sparkline graphs (last 60 samples)
  final List<double> batteryHistory = [];
  final List<double> altitudeHistory = [];
  final List<double> speedHistory = [];
  final List<double> signalHistory = [];
  final _rand = Random();

  final List<SurvivorHit> survivors = [];
  final List<TimelineEvent> timeline = [
    const TimelineEvent('Takeoff', '--:--', done: false),
  ];
  final List<String> notifications = [];

  MissionState() {
    _seedHistory();
  }

  int get survivorsTotal => 6;

  void _seedHistory() {
    // fill with slight variation around the starting values so
    // sparklines aren't empty/flat even before the mission starts
    for (int i = 0; i < 20; i++) {
      batteryHistory.add(battery.toDouble());
      altitudeHistory.add(altitude + (_rand.nextDouble() - 0.5) * 0.4);
      speedHistory.add(0.0);
      signalHistory.add(signalDbm + (_rand.nextDouble() - 0.5) * 3);
    }
  }

  void arm() {
    if (phase != MissionPhase.idle) return;
    armed = true;
    notifications.insert(0, '${_ts()}  Drone armed');
    notifyListeners();
  }

  void disarm() {
    if (phase != MissionPhase.idle) return;
    armed = false;
    notifications.insert(0, '${_ts()}  Drone disarmed');
    notifyListeners();
  }

  void startMission() {
    if (!armed || phase != MissionPhase.idle) return;
    phase = MissionPhase.active;
    speed = 1.2;
    timeline[0] = const TimelineEvent('Takeoff', '00:00');
    notifications.insert(0, '${_ts()}  Mission started');
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void togglePause() {
    if (phase == MissionPhase.active) {
      phase = MissionPhase.paused;
      speed = 0.0;
      notifications.insert(0, '${_ts()}  Mission paused');
    } else if (phase == MissionPhase.paused) {
      phase = MissionPhase.active;
      speed = 1.2;
      notifications.insert(0, '${_ts()}  Mission resumed');
    }
    notifyListeners();
  }

  void returnToBase() {
    if (phase != MissionPhase.active && phase != MissionPhase.paused) return;
    phase = MissionPhase.returning;
    notifications.insert(0, '${_ts()}  Returning to exit point');
    notifyListeners();
  }

  void abort() {
    if (phase == MissionPhase.idle || phase == MissionPhase.completed) return;
    phase = MissionPhase.aborted;
    speed = 0.0;
    _ticker?.cancel();
    notifications.insert(0, '${_ts()}  MISSION ABORTED by operator');
    notifyListeners();
  }

  void clearNotifications() {
    notifications.clear();
    notifyListeners();
  }

  void _pushHistory(List<double> list, double value, {int maxLen = 60}) {
    list.add(value);
    if (list.length > maxLen) list.removeAt(0);
  }

  void _tick() {
    elapsed += const Duration(seconds: 1);

    if (phase == MissionPhase.active) {
      if (explorationPercent < 1.0) {
        explorationPercent = (explorationPercent + 0.004).clamp(0.0, 1.0);
      }
      if (battery > 15 && elapsed.inSeconds % 4 == 0) battery--;

      // gentle simulated variation so the graphs aren't flat lines
      altitude = (altitude + (_rand.nextDouble() - 0.5) * 0.3).clamp(0.0, 40.0);
      signalDbm = (signalDbm + (_rand.nextDouble() - 0.5) * 2).clamp(
        -90.0,
        -30.0,
      );

      if (survivors.length < survivorsTotal &&
          elapsed.inSeconds > 0 &&
          elapsed.inSeconds % 45 == 0) {
        final n = survivors.length + 1;
        final grid = ['B2', 'E3', 'C5', 'F7', 'A6', 'D8'][n - 1];
        survivors.add(SurvivorHit(n, grid, _fmt(elapsed), 90 + (n % 6)));
        timeline.add(TimelineEvent('Survivor #$n Found', _fmt(elapsed)));
        notifications.insert(0, '${_ts()}  Survivor detected at $grid');
      }

      if (explorationPercent >= 1.0) {
        returnToBase();
      }
    }

    if (phase == MissionPhase.returning && elapsed.inSeconds % 3 == 0) {
      // pretend it reaches the exit after a bit
      if (elapsed.inSeconds > 5) {
        phase = MissionPhase.completed;
        speed = 0.0;
        timeline.add(TimelineEvent('Exited', _fmt(elapsed)));
        notifications.insert(0, '${_ts()}  Mission complete — exited maze');
        _ticker?.cancel();
      }
    }

    // record telemetry history every tick
    _pushHistory(batteryHistory, battery.toDouble());
    _pushHistory(altitudeHistory, altitude);
    _pushHistory(speedHistory, speed);
    _pushHistory(signalHistory, signalDbm);

    notifyListeners();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _ts() => _fmt(elapsed);

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
