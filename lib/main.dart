import 'package:controls_app/components/BottomNavigationBar.dart';
import 'package:controls_app/state/EspressoState.dart';
import 'package:controls_app/state/MachineConfigState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/BleConnectScreen.dart';

void main() {
  runApp(
      MultiProvider(
              providers: [
                ChangeNotifierProvider<EspressoState>(create:(_) => EspressoState() ),
                ChangeNotifierProvider<MachineConfigState>(create:(_) =>MachineConfigState() ),
              ],
              child: MyApp())
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const BottomNavigationBarExample());
  }
}
