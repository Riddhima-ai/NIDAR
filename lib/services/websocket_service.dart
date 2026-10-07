import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static const String _url = 'ws://localhost:8000/ws';

  WebSocketChannel? _channel;

  StreamController<Map<String, dynamic>> _telemetryController =
      StreamController<Map<String, dynamic>>.broadcast();

  Timer? _reconnectTimer;

  bool _disposed = false;
  bool _connecting = false;

  Stream<Map<String, dynamic>> get telemetryStream {
    return _telemetryController.stream;
  }

  WebSocketService() {
    _connect();
  }

  void _connect() {
    if (_disposed || _connecting) {
      return;
    }

    _connecting = true;

    print('WS: Connecting to backend...');

    try {
      final channel = WebSocketChannel.connect(
        Uri.parse(_url),
      );

      _channel = channel;

      channel.stream.listen(
        (message) {
          _connecting = false;

          try {
            final decoded = jsonDecode(message as String);

            if (decoded is Map<String, dynamic>) {
              _telemetryController.add(decoded);
            } else if (decoded is Map) {
              _telemetryController.add(
                Map<String, dynamic>.from(decoded),
              );
            }
          } catch (e) {
            print('WS: Failed to decode message: $e');
          }
        },

        onError: (error) {
          print('WS: Connection error: $error');

          _connecting = false;

          _scheduleReconnect();
        },

        onDone: () {
          print('WS: Backend disconnected');

          _connecting = false;

          _scheduleReconnect();
        },

        cancelOnError: true,
      );
    } catch (e) {
      print('WS: Connection failed: $e');

      _connecting = false;

      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) {
      return;
    }

    if (_reconnectTimer != null &&
        _reconnectTimer!.isActive) {
      return;
    }

    print('WS: Reconnecting in 2 seconds...');

    _reconnectTimer = Timer(
      const Duration(seconds: 2),
      () {
        if (!_disposed) {
          _connect();
        }
      },
    );
  }

  void sendCommand(String command) {
    if (_channel == null) {
      print(
        'WS: Cannot send "$command" - not connected',
      );
      return;
    }

    try {
      _channel!.sink.add(command);

      print('WS COMMAND SENT: $command');
    } catch (e) {
      print(
        'WS: Failed to send command "$command": $e',
      );

      _scheduleReconnect();
    }
  }

  void dispose() {
    _disposed = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;

    _telemetryController.close();
  }
}