import 'dart:convert';

import 'package:controls_app/models/snapshot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../state/EspressoState.dart';
import '../components/Graph.dart';

class EspressoDashboard extends StatefulWidget {
  final dynamic flutterReactiveBle;
  final bool isMakingCoffee = false;

  const EspressoDashboard({
    super.key,
    this.flutterReactiveBle,
  });

  @override
  _EspressoDashboardState createState() => _EspressoDashboardState();
}

class _EspressoDashboardState extends State<EspressoDashboard> {
  bool _isMounted = false;
  bool _isMakingCoffee = false;
  double currTime = 0.0;
  dynamic listener;

  @override
  void dispose() {
    _isMounted = false;
    if(listener ==null){
        listener?.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  void listenToNotifications() {
    var characteristic;
    FlutterReactiveBle? flutterReactiveBle;

    try{
      characteristic = Provider.of<EspressoState>(context, listen: false).characteristic;
      flutterReactiveBle= Provider.of<EspressoState>(context, listen: false).flutterReactiveBle;
    }catch(error){
      print("failed $error");
    }
    if (flutterReactiveBle == null || characteristic == null) {
      print("flutterReactiveBle or characteristic is null, cannot subscribe.");
      return;
    }
    if (!_isMounted) return;
    listener = flutterReactiveBle
        .subscribeToCharacteristic(characteristic)
        .listen(
      (data) {
        if (!_isMounted) return;
        final jsonString =utf8.decode(data);
        final jsonData = jsonDecode(jsonString);
        final newSnapshot =EspressoStateSnapshot.fromJson(jsonData);

          final double elapsedTime =
              (newSnapshot.elapsedTimeFromLastRead.inSeconds.toDouble() +
                  (newSnapshot.elapsedTimeFromLastRead.inMicroseconds %
                          Duration.microsecondsPerSecond) /
                      Duration.microsecondsPerSecond.toDouble());
          currTime = currTime + elapsedTime;

          // Access the shared state directly using Provider
          /// 
          Provider.of<EspressoState>(context, listen: false).updateGraphPressure(elapsedTime, newSnapshot.pressure);

          //weightSpots.add(FlSpot(elapsedTime, newSnapshot.estimatedWeight));
          //flowSpots.add(FlSpot(elapsedTime, newSnapshot.estimatedEspressoFlow)); 

      },
      onError: (dynamic error) {
        print("Error subscribing to characteristic: $error");
      },
      onDone: () {
        print("Notification subscription completed.");
      },
      cancelOnError: true,
    );
  }
 @override
  Widget build(BuildContext context) {
    if(Provider.of<EspressoState>(context, listen: true).characteristic == null){
      return const Text("Espresso machine not connected");

    }
    return Column(
        children: [
          Expanded(
            child:_isMakingCoffee ?
                EspressoGraph(
                  pressureSpots:Provider.of<EspressoState>(context, listen:true).pressureSpots,
                  //weightSpots: weightSpots,
                  //flowSpots: flowSpots,
                )
              : const Text("Waiting")
          ),
          IconButton(
            onPressed: (){
              print("pressed");
              _isMakingCoffee = !_isMakingCoffee;
              if(_isMakingCoffee){
                  listenToNotifications();
                }
            }, 
            icon:const Icon(Icons.coffee_maker)),
          IconButton(
            onPressed: (){
              print("pressed");
              if(_isMakingCoffee){
                  Provider.of<EspressoState>(context, listen:false).resetPressure();
                }
            }, 
            icon:const Icon(Icons.reset_tv_sharp))
        ],
      );
  }
}
