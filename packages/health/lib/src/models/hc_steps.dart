part of health;

class HealthConnectSteps extends HealthConnectData {
  /// in milliliters
  final int steps;
  final DateTime startTime;
  final DateTime endTime;

  HealthConnectSteps(
    this.startTime,
    this.endTime, {
    required super.uID,
    required super.packageName,
    required this.steps,
    required super.healthDataType,
  });

  factory HealthConnectSteps.fromJson(json, HealthDataType healthDataType) =>
      HealthConnectSteps(
        DateTime.fromMillisecondsSinceEpoch(json['startDateTime']),
        DateTime.fromMillisecondsSinceEpoch(json['endDateTime']),
        uID: json['uid'],
        packageName: json['packageName'],
        steps: json['steps'],
        healthDataType: healthDataType,
      );

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'startTime':
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startTime).toString(),
        'endTime':
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endTime).toString(),
        'uid': uID,
        'steps': steps,
      };

  @override
  String toString() => '${this.runtimeType} - '
      '${toJson().toString()}';

  /// Adds two steps. The resulting package name is null if the package names are different. uID is null.
  HealthConnectSteps operator +(HealthConnectSteps other) {
    final sum = steps + other.steps;
    final newPackageName =
        packageName == other.packageName ? packageName : null;
    final newStartTime =
        startTime.isBefore(other.startTime) ? startTime : other.startTime;
    final newEndTime = endTime.isAfter(other.endTime) ? endTime : other.endTime;
    return HealthConnectSteps(
      newStartTime,
      newEndTime,
      uID: null,
      packageName: newPackageName,
      steps: sum,
      healthDataType: healthDataType,
    );
  }
}
