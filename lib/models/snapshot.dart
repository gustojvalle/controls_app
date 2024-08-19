class EspressoStateSnapshot {
  final double pressure;
  final double boilerTemp;
  final double estimatedEspressoFlow;
  final DateTime time;
  final Duration elapsedTimeFromLastRead;
  final double estimatedWeight;
  //final double measuredFlow;
  final double espressoFlow;
  final double pressureChangeSpeed;
  final double pumpFlow;

  EspressoStateSnapshot({
    required this.pressure,
    required this.boilerTemp,
    required this.estimatedEspressoFlow,
    required this.time,
    required this.elapsedTimeFromLastRead,
    required this.estimatedWeight,
    //required this.measuredFlow,
    required this.espressoFlow,
    required this.pressureChangeSpeed,
    required this.pumpFlow,
  });

  factory EspressoStateSnapshot.fromJson(Map<String, dynamic> json) {
    final jsonTime = json['time'] as Map<String, dynamic>;
    print(jsonTime);
    
    // Extract seconds and nanoseconds
    final int seconds = jsonTime['secs_since_epoch'] as int;
    final int nanoseconds = jsonTime['nanos_since_epoch'] as int;
    
    // Convert seconds and nanoseconds to a DateTime object
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(seconds * 1000).add(Duration(microseconds: nanoseconds ~/ 1000));
    final jsonDuration = json['elapsed_time_from_last_read'] as Map<String, dynamic>;

    // Extract seconds and nanoseconds
    final int secondsDuration = jsonDuration['secs'] as int;
    final int nanosecondsDuration = jsonDuration['nanos'] as int;
    
    // Convert to a Duration object
    final Duration elapsedTimeFromLastRead = Duration(seconds: secondsDuration, microseconds: nanosecondsDuration ~/ 1000);

    return EspressoStateSnapshot(
      pressure: json['pressure'],
      boilerTemp: json['boiler_temp'],
      estimatedEspressoFlow: json['estimated_espresso_flow'],
      time: time,
      elapsedTimeFromLastRead: elapsedTimeFromLastRead,
      estimatedWeight: json['estimated_weight'],
      //measuredFlow: json['measured_flow'],
      espressoFlow: json['espresso_flow'],
      pressureChangeSpeed: json['pressure_change_speed'],
      pumpFlow: json['pump_flow'],
    );
  }
}
