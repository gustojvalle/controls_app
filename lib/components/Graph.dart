import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EspressoGraph extends StatelessWidget {
  final List<FlSpot> pressureSpots;
  //final List<FlSpot> weightSpots;
  //final List<FlSpot> flowSpots;

  const EspressoGraph({super.key, 
    required this.pressureSpots,
    //required this.weightSpots,
    //required this.flowSpots,
  });


  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        // minX: 0,
        // maxX: 50,

      
        lineBarsData: [
          LineChartBarData(
            spots: pressureSpots,
            isCurved: true,
            color: Colors.red,
            dotData:const  FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          // LineChartBarData(
          //   spots: weightSpots,
          //   isCurved: true,
          //   dotData: const FlDotData(show: false),
          //   belowBarData: BarAreaData(show: false),
          // ),
          // LineChartBarData(
          //   spots: flowSpots,
          //   isCurved: true,
          //   dotData: const FlDotData(show: false),
          //   belowBarData: BarAreaData(show: false),
          // ),
        ],
      ),
    );
  }
}
