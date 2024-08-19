import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class MachineConfigState with ChangeNotifier {
  bool _steamState = false;
  int  _tempSetPoint = 0;
  bool _machineOn = false;
  QualifiedCharacteristic? _machineConfigCharacteristic; 

  final Uuid _machineConfigServiceUui =Uuid.parse(
      "497b30e0-c4be-4bca-8a38-cc74e84cd4ce"); // Replace with your service UUID
  final Uuid _machineConfigCharacteristicUuid = Uuid.parse(
      "35124b97-6292-4c46-ae49-21171df21527"); // Replace with your characteristic UUID

  bool get steamState => _steamState;
  bool get machineOn => _machineOn;
  int? get  tempSetPoint => _tempSetPoint;
  Uuid get machineConfigServiceUuid => _machineConfigServiceUui;
  Uuid get machineConfigCharacteristicUuid=> _machineConfigCharacteristicUuid;
  QualifiedCharacteristic? get machineConfigCharacteristic=> _machineConfigCharacteristic;

  

  void setSteamState(bool state){
      _steamState = state;
      notifyListeners();
    }

  void setMachineConfigCharacteristic(QualifiedCharacteristic characteristic){
      _machineConfigCharacteristic = characteristic;
      notifyListeners();
    }

  void setMachineOn(bool state){
      _machineOn = state;
      notifyListeners();
    }
  void setTempSetPoint(int state){
      _tempSetPoint = state;
      notifyListeners();
    }
  void directionalTempSetPoint(bool isUp){
      int modifier = isUp ? 1 : -1;
      int newSetPoint = _tempSetPoint + modifier;
      print(newSetPoint);
        _tempSetPoint = newSetPoint;
        notifyListeners();
    }
    
    void confirmConfiguration(){

    }

}


