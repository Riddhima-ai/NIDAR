import 'dart:async';

import 'package:flutter/material.dart';

import '../services/websocket_service.dart';
import '../services/api_service.dart';

enum MissionPhase {
  idle,
  active,
  paused,
  returning,
  aborted,
  completed,
}

class SurvivorHit {
  final int id;
  final String grid;
  final String detectedAt;
  final int confidence;

  const SurvivorHit(
    this.id,
    this.grid,
    this.detectedAt,
    this.confidence,
  );
}

class TimelineEvent {
  final String label;
  final String time;
  final bool done;

  const TimelineEvent(
    this.label,
    this.time, {
    this.done = true,
  });
}

class MissionNotice {
  final String time;
  final String message;
  final Color Function(dynamic palette) colorOf;

  const MissionNotice(
    this.time,
    this.message,
    this.colorOf,
  );
}

class MissionState extends ChangeNotifier {
  final WebSocketService _webSocket = WebSocketService();

  final ApiService _api = ApiService();

  StreamSubscription<Map<String, dynamic>>? _telemetrySubscription;

  MissionPhase phase = MissionPhase.idle;

  bool armed = false;

  Duration elapsed = Duration.zero;

  double explorationPercent = 0.0;

  int battery = 92;

  double altitude = 1.8;

  double speed = 0.0;

  double signalDbm = -58;

  double tempC = 34;

  double droneX = 0.0;

  double droneY = 0.0;

  double droneZ = 0.0;

  double droneYaw = 0.0;

  final Map<String, int> occupancyGrid = {};

  final List<Map<String, double>> dronePath = [];

  final List<double> batteryHistory = [];

  final List<double> altitudeHistory = [];

  final List<double> speedHistory = [];

  final List<double> signalHistory = [];

  final List<SurvivorHit> survivors = [];

  final List<TimelineEvent> timeline = [
    const TimelineEvent(
      'Takeoff',
      '--:--',
      done: false,
    ),
  ];

  final List<String> notifications = [];

  MissionState() {
    _seedHistory();
    _listenToTelemetry();
    _loadInitialBackendStatus();
  }

  Future<void> _loadInitialBackendStatus() async {
    try {
      final status = await _api.getStatus();

      _handleBackendData(status);

      debugPrint('==============================');
      debugPrint('INITIAL BACKEND STATE LOADED');
      debugPrint('Battery: $battery');
      debugPrint('Armed: $armed');
      debugPrint('Phase: $phase');
      debugPrint(
        'Exploration: '
        '${(explorationPercent * 100).toStringAsFixed(1)}%',
      );
      debugPrint('Drone X: $droneX');
      debugPrint('Drone Y: $droneY');
      debugPrint('Drone Z: $droneZ');
      debugPrint('Drone Yaw: $droneYaw');
      debugPrint('Survivors: ${survivors.length}');
      debugPrint('Map cells: ${occupancyGrid.length}');
      debugPrint('Path points: ${dronePath.length}');
      debugPrint('==============================');
    } catch (e) {
      debugPrint('==============================');
      debugPrint('REST API ERROR: $e');
      debugPrint('==============================');

      notifications.insert(
        0,
        '${_ts()} REST API error: $e',
      );

      notifyListeners();
    }
  }

  int get survivorsTotal => 6;

  void _seedHistory() {
    for (int i = 0; i < 20; i++) {
      batteryHistory.add(battery.toDouble());
      altitudeHistory.add(altitude);
      speedHistory.add(0.0);
      signalHistory.add(signalDbm);
    }
  }

  void _listenToTelemetry() {
    _telemetrySubscription =
        _webSocket.telemetryStream.listen(
      (data) {
        debugPrint(
          'WS TELEMETRY: '
          'x=${_extractX(data)} '
          'y=${_extractY(data)} '
          'state=${data['mission_state']}',
        );

        _handleBackendData(data);
      },
      onError: (error) {
        notifications.insert(
          0,
          '${_ts()} WebSocket error: $error',
        );

        notifyListeners();
      },
      onDone: () {
        notifications.insert(
          0,
          '${_ts()} WebSocket disconnected',
        );

        notifyListeners();
      },
    );
  }

  void _handleBackendData(
    Map<String, dynamic> data,
  ) {
    if (data['battery'] != null) {
      battery = _toDouble(data['battery']).round();
    }

    if (data['altitude'] != null) {
      altitude = _toDouble(data['altitude']);
    }

    final velocity = data['velocity'];

    if (velocity is num) {
      speed = velocity.toDouble();
    } else if (velocity is Map) {
      final vx = _toDouble(velocity['x']);
      final vy = _toDouble(velocity['y']);
      final vz = _toDouble(velocity['z']);

      speed = _magnitude(vx, vy, vz);
    }

    _updateDronePosition(data);

    if (data['armed'] != null) {
      armed = data['armed'] == true;
    }

    final missionState = data['mission_state'];

    if (missionState is String) {
      _updateMissionPhase(missionState);
    }

    if (data['coverage'] != null) {
      final rawCoverage =
          _toDouble(data['coverage']);

      if (rawCoverage > 1.0) {
        explorationPercent =
            (rawCoverage / 100.0).clamp(0.0, 1.0);
      } else {
        explorationPercent =
            rawCoverage.clamp(0.0, 1.0);
      }
    }

    if (data['mission_timer'] != null) {
      final timer = data['mission_timer'];

      if (timer is num) {
        elapsed = Duration(
          seconds: timer.round(),
        );
      }
    }

    if (data['signal_dbm'] != null) {
      signalDbm =
          _toDouble(data['signal_dbm']);
    } else if (data['signal'] != null) {
      signalDbm =
          _toDouble(data['signal']);
    }

    if (data['temperature'] != null) {
      tempC =
          _toDouble(data['temperature']);
    } else if (data['temp'] != null) {
      tempC =
          _toDouble(data['temp']);
    }

    _updateSurvivors(
      data['survivors'],
    );

    _updateOccupancyGrid(
      data['occupancy_grid_updates'],
    );

    _updateDronePath(
      data['path'],
    );

    _pushHistory(
      batteryHistory,
      battery.toDouble(),
    );

    _pushHistory(
      altitudeHistory,
      altitude,
    );

    _pushHistory(
      speedHistory,
      speed,
    );

    _pushHistory(
      signalHistory,
      signalDbm,
    );

    notifyListeners();
  }

  void _updateDronePosition(
    Map<String, dynamic> data,
  ) {
    dynamic position;

    if (data['pose'] is Map) {
      position = data['pose'];
    } else if (data['position'] is Map) {
      position = data['position'];
    } else if (data['pos'] is Map) {
      position = data['pos'];
    }

    if (position is Map) {
      if (position['x'] != null) {
        droneX =
            _toDouble(position['x']);
      }

      if (position['y'] != null) {
        droneY =
            _toDouble(position['y']);
      }

      if (position['z'] != null) {
        droneZ =
            _toDouble(position['z']);
      }

      if (position['yaw'] != null) {
        droneYaw =
            _toDouble(position['yaw']);
      }

      return;
    }

    if (data['x'] != null) {
      droneX =
          _toDouble(data['x']);
    }

    if (data['y'] != null) {
      droneY =
          _toDouble(data['y']);
    }

    if (data['z'] != null) {
      droneZ =
          _toDouble(data['z']);
    }

    if (data['yaw'] != null) {
      droneYaw =
          _toDouble(data['yaw']);
    }
  }

  double _extractX(
    Map<String, dynamic> data,
  ) {
    if (data['pose'] is Map) {
      return _toDouble(
        (data['pose'] as Map)['x'],
      );
    }

    if (data['position'] is Map) {
      return _toDouble(
        (data['position'] as Map)['x'],
      );
    }

    return _toDouble(data['x']);
  }

  double _extractY(
    Map<String, dynamic> data,
  ) {
    if (data['pose'] is Map) {
      return _toDouble(
        (data['pose'] as Map)['y'],
      );
    }

    if (data['position'] is Map) {
      return _toDouble(
        (data['position'] as Map)['y'],
      );
    }

    return _toDouble(data['y']);
  }

  double _magnitude(
    double x,
    double y,
    double z,
  ) {
    return (x * x + y * y + z * z).sqrt();
  }

  void _updateOccupancyGrid(
    dynamic gridData,
  ) {
    if (gridData is! List) {
      return;
    }

    for (final cell in gridData) {
      if (cell is! Map) {
        continue;
      }

      final row =
          _toDouble(cell['row']).toInt();

      final col =
          _toDouble(cell['col']).toInt();

      final value =
          _toDouble(cell['value']).toInt();

      if (row < 0 ||
          row >= 15 ||
          col < 0 ||
          col >= 15) {
        continue;
      }

      occupancyGrid['$row,$col'] = value;

      if (value == 1) {
        debugPrint(
          'OBSTACLE RECEIVED: row=$row col=$col',
        );
      }
    }
  }

  void _updateDronePath(
    dynamic pathData,
  ) {
    if (pathData is! List) {
      return;
    }

    final newPath =
        <Map<String, double>>[];

    for (final point in pathData) {
      if (point is! Map) {
        continue;
      }

      final x =
          _toDouble(point['x']);

      final y =
          _toDouble(point['y']);

      newPath.add({
        'x': x,
        'y': y,
      });
    }

    dronePath
      ..clear()
      ..addAll(newPath);
  }

  double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          '$value',
        ) ??
        0.0;
  }

  void _updateMissionPhase(
    String state,
  ) {
    final normalized =
        state.toUpperCase();

    switch (normalized) {
      case 'IDLE':
      case 'STANDBY':
        phase = MissionPhase.idle;
        break;

      case 'ACTIVE':
      case 'RUNNING':
      case 'SEARCHING':
        phase = MissionPhase.active;
        break;

      case 'PAUSED':
        phase = MissionPhase.paused;
        break;

      case 'RETURNING':
      case 'RETURN':
      case 'RTL':
        phase = MissionPhase.returning;
        break;

      case 'ABORTED':
      case 'ABORT':
        phase = MissionPhase.aborted;
        break;

      case 'COMPLETED':
      case 'COMPLETE':
        phase = MissionPhase.completed;
        break;
    }
  }

  void _updateSurvivors(
    dynamic survivorData,
  ) {
    if (survivorData is! List) {
      return;
    }

    survivors.clear();

    for (
      int i = 0;
      i < survivorData.length;
      i++
    ) {
      final survivor =
          survivorData[i];

      if (survivor is! Map) {
        continue;
      }

      final rawId =
          survivor['id'] ?? i + 1;

      final survivorId =
          rawId is int
              ? rawId
              : int.tryParse(
                    '$rawId',
                  ) ??
                  i + 1;

      final rawGrid =
          survivor['grid_ref'] ??
          survivor['grid'] ??
          survivor['location'] ??
          'Unknown';

      final grid = '$rawGrid';

      final rawDetectedAt =
          survivor['detected_at'] ??
          survivor['detectedAt'] ??
          _fmt(elapsed);

      final detectedAt =
          '$rawDetectedAt';

      final rawConfidence =
          survivor['confidence'] ?? 0;

      int confidence;

      if (rawConfidence is num) {
        final value =
            rawConfidence.toDouble();

        if (value <= 1.0) {
          confidence =
              (value * 100).round();
        } else {
          confidence =
              value.round();
        }
      } else {
        confidence =
            int.tryParse(
                  '$rawConfidence',
                ) ??
                0;
      }

      confidence =
          confidence.clamp(0, 100);

      survivors.add(
        SurvivorHit(
          survivorId,
          grid,
          detectedAt,
          confidence,
        ),
      );
    }
  }

  void arm() {
    if (phase != MissionPhase.idle) {
      return;
    }

    _webSocket.sendCommand('ARM');

    notifications.insert(
      0,
      '${_ts()} Arm command sent',
    );

    notifyListeners();
  }

  void disarm() {
    if (phase != MissionPhase.idle) {
      return;
    }

    _webSocket.sendCommand('DISARM');

    notifications.insert(
      0,
      '${_ts()} Disarm command sent',
    );

    notifyListeners();
  }

  void startMission() {
    if (!armed ||
        phase != MissionPhase.idle) {
      return;
    }

    _webSocket.sendCommand('START');

    notifications.insert(
      0,
      '${_ts()} Start command sent',
    );

    notifyListeners();
  }

  void togglePause() {
    if (phase == MissionPhase.active) {
      _webSocket.sendCommand('PAUSE');

      notifications.insert(
        0,
        '${_ts()} Pause command sent',
      );
    } else if (phase ==
        MissionPhase.paused) {
      _webSocket.sendCommand('RESUME');

      notifications.insert(
        0,
        '${_ts()} Resume command sent',
      );
    }

    notifyListeners();
  }

  void returnToBase() {
    if (phase != MissionPhase.active &&
        phase != MissionPhase.paused) {
      return;
    }

    _webSocket.sendCommand('RETURN');

    notifications.insert(
      0,
      '${_ts()} Return command sent',
    );

    notifyListeners();
  }

  void abort() {
    if (phase == MissionPhase.idle ||
        phase == MissionPhase.completed) {
      return;
    }

    _webSocket.sendCommand('ABORT');

    notifications.insert(
      0,
      '${_ts()} MISSION ABORT command sent',
    );

    notifyListeners();
  }

  void clearNotifications() {
    notifications.clear();
    notifyListeners();
  }

  void _pushHistory(
    List<double> list,
    double value, {
    int maxLen = 60,
  }) {
    list.add(value);

    if (list.length > maxLen) {
      list.removeAt(0);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final s = d.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$m:$s';
  }

  String _ts() => _fmt(elapsed);

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _webSocket.dispose();
    super.dispose();
  }
}

extension DoubleSqrt on double {
  double sqrt() {
    double x = this;

    if (x <= 0) {
      return 0;
    }

    double guess = x / 2;

    for (int i = 0; i < 10; i++) {
      guess =
          (guess + x / guess) / 2;
    }

    return guess;
  }
}