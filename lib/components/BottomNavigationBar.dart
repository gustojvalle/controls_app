import 'package:controls_app/pages/BleConnectScreen.dart';
import 'package:controls_app/pages/EspressoDashboard.dart';
import 'package:controls_app/pages/MachineConfiguration.dart';
import 'package:controls_app/state/EspressoState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
  MachineConfiguration(),
  EspressoDashboard(),
  const Text(
      'Extras',
      style: optionStyle,
    ),
  ];

  void _checkIfMachineIsAvailable() async {
    try{
        final espressoState = Provider.of<EspressoState>(context, listen: false);
        final machineId = await espressoState.getSavedDeviceInfo() ?? "";
        print("trying to connect to: $machineId");
        espressoState.connectToDevice(machineId,
        espressoState.snapshotServiceUuid,espressoState.characteristicUuid);
      }catch(err){
        print("Mechine not available: $err");
      }

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _connectToMachine(BuildContext context){
    return showModalBottomSheet(
        context: context, 
        builder: (BuildContext context){
            return BleConnectScreen(); 
          }
        );


  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1),(){
    _checkIfMachineIsAvailable(); 
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
        Consumer<EspressoState>(

          builder:  (context, EspressoState espressoState, child){
            return IconButton(onPressed: (){
              _connectToMachine(context);
            }, 
            icon: const Icon(Icons.coffee_maker),
            color:espressoState.isMachineConnected ? Colors.greenAccent :Colors.red,
          );
        }
        )

        ],
        title: const Text('Anita Control'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Machine configuration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Espresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Extras',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
