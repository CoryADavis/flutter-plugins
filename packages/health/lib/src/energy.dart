part of health;

class Energy {
  double value;
  EType type;

  Energy(this.value, {this.type = EType.CALORIES});
}

enum EType { CALORIES, KILOCALORIES, JOULES, KILOJOULES }
