part of health;

class HealthConnectBodyFat {
  String uID;
  String bodyFat;
  String zonedDateTime;

  HealthConnectBodyFat(this.uID, this.bodyFat, this.zonedDateTime);

  factory HealthConnectBodyFat.fromJson(json) =>
      HealthConnectBodyFat(json['uid'], json['bodyFat'], json['zonedDateTime']);

  /// Converts the [HealthDataPoint] to a json object
  Map<String, dynamic> toJson() => {
        'uid': uID,
        'bodyFat': bodyFat,
        'zonedDateTime': zonedDateTime,
      };

  @override
  String toString() => '${this.runtimeType} - '
      'uid: $uID, '
      'bodyFat: $bodyFat, '
      'zonedDateTime: $zonedDateTime, ';
}
