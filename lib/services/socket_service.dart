import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class SocketService extends ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io('http://10.0.2.2:3004', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    _socket!.onConnect((_) {
      print('Socket conectado');
      _isConnected = true;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      print('Socket desconectado');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.onConnectError((data) {
      print('Error de conexión: $data');
      _isConnected = false;
      notifyListeners();
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  void on(String event, dynamic Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}
