

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;
  
  ServerStatus get serverStatus => _serverStatus;
  io.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){
    debugPrint("por aca paso?");
    // Dart client
    _socket = io.io('https://192.168.0.4:3003/', 
        {
          'transports': ['websocket'],
          'autoConnect': true,
        }
    );
    _socket.connect();


    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      debugPrint("aqui mi so");
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    // _socket!.on('nuevo-mensaje', ( payload ) => {
    //   print('nuevo mensaje $payload ')
    // });

  }

}