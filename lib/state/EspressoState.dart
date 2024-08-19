import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EspressoState with ChangeNotifier {
  QualifiedCharacteristic? _characteristic;
  final _flutterReactiveBle = FlutterReactiveBle();
  Stream<ConnectionStateUpdate>? _connectionStream;
  final Uuid _snapshotServiceUuid = Uuid.parse(
      "02550882-1f94-4b1e-a448-e2f7691ac386"); // Replace with your service UUID
  final Uuid _characteristicUuid = Uuid.parse(
      "799f64c7-362b-44b9-9413-2d2ee8e5a784"); // Replace with your characteristic UUID
  bool _isMachineConnected = false; 
  DeviceConnectionState _deviceConnectionState = DeviceConnectionState.disconnected;

  BuildContext? _context;

  List<FlSpot> _pressureSpots = [];
  final List<FlSpot> _weightSpots= [];
  final List<FlSpot> _flowSpots =[];


  dynamic get characteristic => _characteristic;
  FlutterReactiveBle? get flutterReactiveBle=> _flutterReactiveBle;
  dynamic get pressureSpots => _pressureSpots;
  DeviceConnectionState get deviceConnectionState => _deviceConnectionState;
  Stream<ConnectionStateUpdate>? get connectionStream => _connectionStream;
  


  Future<String?> get storedDeviceId => getSavedDeviceInfo();
  Uuid get snapshotServiceUuid => _snapshotServiceUuid;
  Uuid get characteristicUuid => _characteristicUuid;
  bool get isMachineConnected => _isMachineConnected;
  BuildContext? get context => _context;



  void setContext(BuildContext context){
      _context =context;
      notifyListeners();
    }

  void setIsMachineConnected (bool isConnected){
      _isMachineConnected = isConnected;
      notifyListeners();
    }

  void updateData(QualifiedCharacteristic characteristic ) {
    _characteristic = characteristic;
    notifyListeners();
  }

  void updateGraphPressure(double elapsedTime, double pressure ) {
    _pressureSpots.add(FlSpot(elapsedTime,pressure));
          //weightSpots.add(FlSpot(elapsedTime, newSnapshot.estimatedWeight));
          //flowSpots.add(FlSpot(elapsedTime, newSnapshot.estimatedEspressoFlow)); 
    notifyListeners();
  }

  void resetPressure(){
    _pressureSpots = [];
  }

  Future<void> saveDeviceInfo(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connectedDeviceId', deviceId);
  }
  
  Future<String?> getSavedDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('connectedDeviceId');
  }

  void setCharacteristics(
   QualifiedCharacteristic characteristic,
  ) {
    _characteristic = characteristic;
    notifyListeners();
  }

  void connectToDevice(String deviceId, Uuid serviceUuid, Uuid characteristicUuid) {
    _connectionStream = _flutterReactiveBle.connectToDevice(id: deviceId);

    _connectionStream?.listen((connectionState) async {

      saveDeviceInfo(deviceId);
      _deviceConnectionState = connectionState.connectionState;

      if (connectionState.connectionState == DeviceConnectionState.connected) {
        _isMachineConnected = true;
        notifyListeners();
        print("Connected to the device!");

        final mtu =
            await _flutterReactiveBle.requestMtu(deviceId: deviceId, mtu: 517);
          print("mtu negotiated $mtu");
        _characteristic = QualifiedCharacteristic(
          serviceId: serviceUuid,
          characteristicId: characteristicUuid,
          deviceId: deviceId,
        );
        print("characteristic is set ");
        
        if(_context != null){
          Navigator.pop<BuildContext?>(_context! );
        }
        notifyListeners();
        // Access the shared state directly using Provider and update it

      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
          print("disconected");
          _isMachineConnected = true;
          notifyListeners();
      }
    }, onError: (dynamic error) {
      print("failed to connect: $error");
      _isMachineConnected = true;
      notifyListeners();
    });
  }
}
