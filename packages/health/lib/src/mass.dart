part of health;

class Mass {
  double value;
  Type type;

  Mass(this.value, {this.type = Type.KILOGRAMS});
}

enum Type {
  GRAMS,
  KILOGRAMS,
  MILLIGRAMS,
  MICROGRAMS,
  OUNCES,
  POUNDS,
}
