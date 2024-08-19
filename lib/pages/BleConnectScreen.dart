import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/EspressoState.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleConnectScreen extends StatefulWidget {
  const BleConnectScreen({super.key});

  @override
  _BleConnectScreenState createState() => _BleConnectScreenState();
}

class _BleConnectScreenState extends State<BleConnectScreen> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = [];
  late Stream<ConnectionStateUpdate> connectionStream;
  late StreamSubscription<DiscoveredDevice> scanningStream;
  bool _isMounted = false;

  final Uuid serviceUuid = Uuid.parse(
      "02550882-1f94-4b1e-a448-e2f7691ac386"); // Replace with your service UUID
  final Uuid characteristicUuid = Uuid.parse(
      "799f64c7-362b-44b9-9413-2d2ee8e5a784"); // Replace with your characteristic UUID

  @override
  void initState() {
    _isMounted = true;
    super.initState();
    startScanning();
  }

  void startScanning() {
    if (!_isMounted) {
      return;
    }

    scanningStream =
        flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      if (!devices.any((d) => d.id == device.id)) {
        setState(() {
          devices.add(device);
        });
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    scanningStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your coffee machine'),
      ),
      body: devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return Consumer<EspressoState>(
                    builder: (context, EspressoState espressoState, child) {
                  //Provider.of(context, listen: false).setFlutterReactiveBle(flutterReactiveBle);
                  return ListTile(
                    title: Text(devices[index].name.isNotEmpty
                        ? devices[index].name
                        : 'Unknown Device'),
                    subtitle: Text(devices[index].id),
                    onTap: () {
                      espressoState.connectToDevice(
                          devices[index].id, serviceUuid, characteristicUuid);
                    },
                  );
                });
              },
            ),
    );
  }
}
