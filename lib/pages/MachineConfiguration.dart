import 'dart:convert';

import 'package:controls_app/components/TemperatureSelector.dart';
import 'package:controls_app/state/EspressoState.dart';
import 'package:controls_app/state/MachineConfigState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class MachineConfiguration extends StatefulWidget {
  const MachineConfiguration({super.key});

  @override
  _MachineConfigurationStatecreate createState() => _MachineConfigurationStatecreate();
}

class _MachineConfigurationStatecreate extends State<MachineConfiguration> {

  bool steam = false;
  bool  machineOn = false;
  bool _isMounted = false; 

  dynamic listener;
  String? _deviceId; 

  void _steamToggleCallback(bool? toggle) {
    setState(() {
       steam = toggle ?? false;
       Provider.of<MachineConfigState>(context,listen: false).setSteamState(toggle ?? false);
    });
  }

  void _machineOnCallback(bool? toggle) {
    setState(() {
       machineOn = toggle ?? false;
       Provider.of<MachineConfigState>(context,listen: false).setSteamState(toggle ?? false);
       _publishConfig({"temperature":80, "led": toggle??false});
       
    });
  }

  void _onData(data){
      print("data: $data");

    }

  Future<QualifiedCharacteristic?> _createCharacteristic() async {
      final  MachineConfigState machineConfig = Provider.of<MachineConfigState>(context, listen: false);
      final EspressoState espressoState = Provider.of<EspressoState>(context, listen: false);
      final deviceId = await espressoState.getSavedDeviceInfo() ?? "";
      setState(() {
        _deviceId = deviceId;
      });

      return  QualifiedCharacteristic(
            characteristicId:machineConfig.machineConfigCharacteristicUuid, 
            serviceId:machineConfig.machineConfigServiceUuid, 
            deviceId: _deviceId ?? "");
    }

  void _subscribeToMachineConfig()async {
        if (!_isMounted) return;
        
        final EspressoState espressoState = Provider.of<EspressoState>(context, listen: false);
        final  MachineConfigState machineConfig = Provider.of<MachineConfigState>(context, listen: false);
        final String deviceId = await espressoState.getSavedDeviceInfo() ?? "";

        var machineConfigCharacteristic = machineConfig.machineConfigCharacteristic;
        if (machineConfig.machineConfigCharacteristic == null){
            machineConfigCharacteristic = await _createCharacteristic();
          }

        if (deviceId.isEmpty || espressoState.deviceConnectionState == DeviceConnectionState.disconnected) return;
        listener = espressoState.flutterReactiveBle?.subscribeToCharacteristic(machineConfigCharacteristic!).listen(_onData);
    }

    Future<void> _publishConfig(dynamic data) async {
        final  MachineConfigState machineConfig = Provider.of<MachineConfigState>(context, listen: false);
        final EspressoState espressoState = Provider.of<EspressoState>(context, listen: false);
        var machineConfigCharacteristic = machineConfig.machineConfigCharacteristic;
        if (machineConfig.machineConfigCharacteristic == null){
            machineConfigCharacteristic = await _createCharacteristic();
        }
        final jsonEncoder = JsonEncoder();
        final objectString =jsonEncoder.convert(data);
        print("objectString $objectString");
        List<int> byteArray = utf8.encode(objectString);
        final length = byteArray.length;

        print("here it is $length");

          espressoState.flutterReactiveBle?.writeCharacteristicWithResponse(machineConfigCharacteristic!, value:byteArray).then((_){
              print("success on writing");
            }).catchError((error){
                print("error $error");
              });
      }


  // Define any methods that will update the state here
 
  @override
  void initState() {
    _isMounted = true;
    _subscribeToMachineConfig();
    super.initState();

  }
  
  @override 
  void dispose(){
    _isMounted = false;
    super.dispose();

  }


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Table(
              children:
                <TableRow>[
                const TableRow( 
                  children: [
                      SizedBox(),
                      Center(
                          child: Text("Reading")
                        ),
                      Center(
                          child: Text("Set point")
                        ),
                    ]
                  ), 
                const TableRow( 
                  children: [ 
                  Chip(
                       label: Text( "Temperature" )
                    ) 
                  ,
                  Center(
                    child:Text("-"),
                  ),
                  TemperatureSelector()
                  ]
                ),
                TableRow( 
                  children: [ 
                    const Chip(label: Text("Steam")),
                    const SizedBox(),
                    Switch(value: steam, 
                        onChanged:_steamToggleCallback
                   )  
                  ]
                ),
                TableRow( 
                  children: [ 
                    const Chip(label: Text("Machine on")),
                    const SizedBox(),
                    Switch(
                        value:machineOn, 
                        onChanged:_machineOnCallback
                   )  
                  ]
                )
            ],
          ),
          Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
              TextButton(
              style: 
                const ButtonStyle(
                  backgroundColor:WidgetStatePropertyAll<Color>(Colors.blueAccent), 
                ),
              onPressed: ()async {
                final  MachineConfigState machineConfig = Provider.of<MachineConfigState>(context, listen: false);
                await _publishConfig({"temperature": machineConfig.tempSetPoint});
                print("confirm");

              }, 
              child: const Text("Confirm config")
              )
            ],
          ),
        ],
      );
  }
}
