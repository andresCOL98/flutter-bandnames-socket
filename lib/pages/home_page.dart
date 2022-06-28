import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_name/models/band.dart';
import 'package:band_name/services/socket_service.dart';

class HomePage extends StatefulWidget {
  

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> _bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands( dynamic payload ){
    _bands = (payload as List).map( (band) => Band.fromMap(band) ).toList();
      setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandeNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            child: (socketService.serverStatus == ServerStatus.online)
              ? Icon(Icons.check_circle, color: Colors.blue[300],)
              : const Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [

          if(_bands.isNotEmpty) _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: _bands.length,
              itemBuilder: ( context, index) => _bandTile(_bands[index]),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon( Icons.add ),
        elevation: 1,
        onPressed: addNewBand
      ),
    );
  }

  _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),),
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle( fontSize: 20 ),),
        onTap: () => socketService.socket.emit('vote-band', { "id" : band.id }),
      ),
    );
  }

  addNewBand(){

    final textController = TextEditingController();

    if( !Platform.isAndroid ) {
      // Android

      return showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('New band name: '),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
      );
    }

    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('New band name:'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          MaterialButton(
            child: const Text('Add'),
            elevation: 5,
            textColor: Colors.blue,
            onPressed: (){
              addBandToList(textController.text);
            } 
          )
        ],
      )
    );
    
  }

  addBandToList( String name ){

    debugPrint(name);
    final socketService = Provider.of<SocketService>(context, listen: false);

    if( name.length > 1 ){
      socketService.socket.emit('add-band', { "name" : name });
    }

    Navigator.pop(context);
  }

  _showGraph() {
    Map<String, double> dataMap = {};

    for (Band band in _bands){
      dataMap.putIfAbsent(band.name, () => band.votes!.toDouble());
    }

    return SizedBox(
      width: double.infinity,
      height: 200.0,
      child: PieChart(dataMap: dataMap)
    );
  }

}