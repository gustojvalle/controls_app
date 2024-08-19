import 'package:controls_app/state/MachineConfigState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TemperatureSelector extends StatefulWidget {
  const TemperatureSelector({super.key});

  @override
  _TemperatureSelectorState createState() => _TemperatureSelectorState();
}

class _TemperatureSelectorState extends State<TemperatureSelector> {


  @override
  Widget build(BuildContext context) {
    return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    IconButton(
                      iconSize: 24,
                      onPressed: (){
                        Provider.of<MachineConfigState>(context, listen: false).directionalTempSetPoint(false);
                      }, 
                      icon:const Icon(Icons.chevron_left_rounded)
                      ),
                    Text(
                        Provider.of<MachineConfigState>(context, listen: true).tempSetPoint.toString() ?? "-"
                    ),
                    IconButton(
                      iconSize: 24,
                      onPressed: (){
                        Provider.of<MachineConfigState>(context, listen: false).directionalTempSetPoint(true);
                      }, 

                      icon:const Icon(Icons.chevron_right)
                      )
                ]
      );
  }
}
