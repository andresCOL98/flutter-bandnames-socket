import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_name/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    SocketService socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center ,
          children: [
            Text('ServerStatus: ${ socketService.serverStatus }')
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton( 
        child: const Icon(Icons.message),
        onPressed: (){
            debugPrint(socketService.socket.connected.toString());
            socketService.emit('emitir-mensaje', { 
              'nombre':'Flutter', 
              'mensaje':'Hola desde Flutter'
            });
        },
      ),
   );
  }
}