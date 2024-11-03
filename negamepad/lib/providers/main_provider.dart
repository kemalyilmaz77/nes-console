
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/button_model.dart';

class MainProvider with ChangeNotifier{
  List<ButtonMode> buttonModes = [

    ButtonMode(
      widget: const Icon(Icons.start, size: 30, color: Colors.white),
      color: Colors.green,
      width: 80,
      height: 40,
      x: 310,
      y: 150,
      borderRadius: 40,
      key: '3',
    ),
    ButtonMode(
      widget: const Icon(Icons.more_horiz, size: 30, color: Colors.white),
      color: Colors.yellow,
      width: 80,
      height: 40,
      x: 410,
      y: 150,
      borderRadius: 40,
      key: '2',
    ),
    ButtonMode(
      widget: const Icon(Icons.close, size: 40, color: Colors.white),
      color: Colors.green,
      width: 80,
      height: 80,
      x: 600,
      y: 290,
      borderRadius: 40,
      key: '0',
    ),
    ButtonMode(
      widget: const Icon(Icons.circle_outlined, size: 40, color: Colors.white),
      color: Colors.red,
      width: 80,
      height: 80,
      x: 700,
      y: 190,
      borderRadius: 40,
      key: '1',
    ),
    ButtonMode(
      widget: const Icon(Icons.close, size: 40, color: Colors.white),
      color: Colors.red,
      width: 80,
      height: 40,
      x: 720,
      y: 0,
      borderRadius: 40,
      key: 'back',
    ),
  ];

  bool _isConnected=false;
  bool _isLogin=false;
  bool _isQR=false;


  bool get isQR => _isQR;

  set isQR(bool value) {
    _isQR = value;
    notifyListeners();
  }

  bool get isLogin => _isLogin;

  set isLogin(bool value) {
    _isLogin = value;
    notifyListeners();
  }

  bool get isConnected => _isConnected;

  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  Socket? socket;

  void sendKey(String type,String? key){
    if(socket?.connected??false){
      socket?.emit('playerData', {'event': type, 'key': key});
    }

  }

  void login(uid){
    isQR=false;
    socket?.emit('uuid', uid);
  }


  MainProvider(){
   init();
  }

  void init(){
     socket = io('http://192.168.1.128:3000',
        OptionBuilder()
            .setTransports(['websocket'])
            .build()
    );
    socket?.connect();

    socket?.on('connect', (data){
      isConnected=true;

    });
     socket?.on('disconnect', (data){
        isConnected=false;
        isQR=false;
     });

     socket?.on('uuid', (data){
        isLogin=data['connected']??false;
        isQR=false;
     });
  }
}