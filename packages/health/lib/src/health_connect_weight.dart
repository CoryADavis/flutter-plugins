part of health;

class HealthConnectWeight {
  String uID;
  String weight;
  String zonedDateTime;

  HealthConnectWeight(this.uID, this.weight, this.zonedDateTime);

  factory HealthConnectWeight.fromJson(json) =>
      HealthConnectWeight(json['uid'], json['weight'], json['zonedDateTime']);

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'uid': uID,
        'weight': weight,
        'zonedDateTime': zonedDateTime,
      };

  @override
  String toString() => '${this.runtimeType} - '
      'uid: $uID, '
      'weight: $weight, '
      'zonedDateTime: $zonedDateTime, ';
}
