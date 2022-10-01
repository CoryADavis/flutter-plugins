part of health;

class HealthConnectNutrition {
  DateTime startTime;
  DateTime endTime;

  MealType? mealType;

  /// Name for food or drink, provided by the user. Optional field. */
  String? name;

  /// Zinc in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? zinc;

  /// Vitamin K in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? vitaminK;

  /// Biotin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? biotin;

  /// Caffeine in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? caffeine;

  /// Calcium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? calcium;

  /// Energy in [Energy] unit. Optional field. Valid range: 0-100000 kcal. */
  Energy? energy;

  /// Energy from fat in [Energy] unit. Optional field. Valid range: 0-100000 kcal. */
  Energy? energyFromFat;

  /// Chloride in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? chloride;

  /// Cholesterol in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? cholesterol;

  /// Chromium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? chromium;

  /// Copper in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? copper;

  /// Dietary fiber in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? dietaryFiber;

  /// Folate in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? folate;

  /// Folic acid in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? folicAcid;

  /// Iodine in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? iodine;

  /// Iron in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? iron;

  /// Magnesium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? magnesium;

  /// Manganese in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? manganese;

  /// Molybdenum in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? molybdenum;

  /// Monounsaturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? monounsaturatedFat;

  /// Niacin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? niacin;

  /// Pantothenic acid in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? pantothenicAcid;

  /// Phosphorus in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? phosphorus;

  /// Polyunsaturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? polyunsaturatedFat;

  /// Potassium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? potassium;

  /// Protein in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? protein;

  /// Riboflavin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? riboflavin;

  /// Saturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? saturatedFat;

  /// Selenium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? selenium;

  /// Sodium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? sodium;

  /// Sugar in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? sugar;

  /// Thiamin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? thiamin;

  /// Total carbohydrate in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? totalCarbohydrate;

  /// Total fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? totalFat;

  /// Trans fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? transFat;

  /// Unsaturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  Mass? unsaturatedFat;

  /// Vitamin A in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? vitaminA;

  /// Vitamin B12 in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? vitaminB12;

  /// Vitamin B6 in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? vitaminB6;

  /// Vitamin C in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? vitaminC;

  /// Vitamin D in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? vitaminD;

  /// Vitamin E in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  Mass? vitaminE;

  HealthConnectNutrition(this.startTime, this.endTime,
      {this.mealType,
      this.name,
      this.vitaminK,
      this.zinc,
      this.biotin,
      this.caffeine,
      this.calcium,
      this.chloride,
      this.cholesterol,
      this.chromium,
      this.copper,
      this.dietaryFiber,
      this.energy,
      this.energyFromFat,
      this.folate,
      this.folicAcid,
      this.iodine,
      this.iron,
      this.magnesium,
      this.manganese,
      this.molybdenum,
      this.monounsaturatedFat,
      this.niacin,
      this.pantothenicAcid,
      this.phosphorus,
      this.polyunsaturatedFat,
      this.potassium,
      this.protein,
      this.riboflavin,
      this.saturatedFat,
      this.selenium,
      this.sodium,
      this.sugar,
      this.thiamin,
      this.totalCarbohydrate,
      this.totalFat,
      this.transFat,
      this.unsaturatedFat,
      this.vitaminA,
      this.vitaminB6,
      this.vitaminB12,
      this.vitaminC,
      this.vitaminD,
      this.vitaminE});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['startTime'] =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startTime).toString();
    map['endTime'] =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endTime).toString();

    if (mealType != null) {
      map['mealType'] = getMealType(mealType!);
    }
    if (name != null) {
      map['name'] = name;
    }
    if (zinc != null) {
      map['zinc'] = {'value': zinc?.value, 'type': _enumToString(zinc?.type)};
    }
    if (vitaminK != null) {
      map['vitaminK'] = {
        'value': vitaminK?.value,
        'type': _enumToString(vitaminK?.type)
      };
    }
    if (biotin != null) {
      map['biotin'] = {
        'value': biotin?.value,
        'type': _enumToString(biotin?.type)
      };
    }
    if (caffeine != null) {
      map['caffeine'] = {
        'value': caffeine?.value,
        'type': _enumToString(caffeine?.type)
      };
    }
    if (calcium != null) {
      map['calcium'] = {
        'value': calcium?.value,
        'type': _enumToString(calcium?.type)
      };
    }
    if (energy != null) {
      map['energy'] = {
        'value': energy?.value,
        'type': _enumToString(energy?.type)
      };
    }
    if (energyFromFat != null) {
      map['energyFromFat'] = {
        'value': energyFromFat?.value,
        'type': _enumToString(energyFromFat?.type)
      };
    }
    if (chloride != null) {
      map['chloride'] = {
        'value': chloride?.value,
        'type': _enumToString(chloride?.type)
      };
    }
    if (cholesterol != null) {
      map['cholesterol'] = {
        'value': cholesterol?.value,
        'type': _enumToString(cholesterol?.type)
      };
    }
    if (chromium != null) {
      map['chromium'] = {
        'value': chromium?.value,
        'type': _enumToString(chromium?.type)
      };
    }
    if (copper != null) {
      map['copper'] = {
        'value': copper?.value,
        'type': _enumToString(copper?.type)
      };
    }
    if (dietaryFiber != null) {
      map['dietaryFiber'] = {
        'value': dietaryFiber?.value,
        'type': _enumToString(dietaryFiber?.type)
      };
    }
    if (folate != null) {
      map['folate'] = {
        'value': folate?.value,
        'type': _enumToString(folate?.type)
      };
    }
    if (folicAcid != null) {
      map['folicAcid'] = {
        'value': folicAcid?.value,
        'type': _enumToString(folicAcid?.type)
      };
    }
    if (iodine != null) {
      map['iodine'] = {
        'value': iodine?.value,
        'type': _enumToString(iodine?.type)
      };
    }
    if (iron != null) {
      map['iron'] = {'value': iron?.value, 'type': _enumToString(iron?.type)};
    }
    if (magnesium != null) {
      map['magnesium'] = {
        'value': magnesium?.value,
        'type': _enumToString(magnesium?.type)
      };
    }
    if (manganese != null) {
      map['manganese'] = {
        'value': manganese?.value,
        'type': _enumToString(manganese?.type)
      };
    }
    if (molybdenum != null) {
      map['molybdenum'] = {
        'value': molybdenum?.value,
        'type': _enumToString(molybdenum?.type)
      };
    }
    if (monounsaturatedFat != null) {
      map['monounsaturatedFat'] = {
        'value': monounsaturatedFat?.value,
        'type': _enumToString(monounsaturatedFat?.type)
      };
    }
    if (niacin != null) {
      map['niacin'] = {
        'value': niacin?.value,
        'type': _enumToString(niacin?.type)
      };
    }
    if (pantothenicAcid != null) {
      map['pantothenicAcid'] = {
        'value': pantothenicAcid?.value,
        'type': _enumToString(pantothenicAcid?.type)
      };
    }
    if (phosphorus != null) {
      map['phosphorus'] = {
        'value': phosphorus?.value,
        'type': _enumToString(phosphorus?.type)
      };
    }
    if (polyunsaturatedFat != null) {
      map['polyunsaturatedFat'] = {
        'value': polyunsaturatedFat?.value,
        'type': _enumToString(polyunsaturatedFat?.type)
      };
    }
    if (potassium != null) {
      map['potassium'] = {
        'value': potassium?.value,
        'type': _enumToString(potassium?.type)
      };
    }
    if (protein != null) {
      map['protein'] = {
        'value': protein?.value,
        'type': _enumToString(protein?.type)
      };
    }
    if (riboflavin != null) {
      map['riboflavin'] = {
        'value': riboflavin?.value,
        'type': _enumToString(riboflavin?.type)
      };
    }
    if (saturatedFat != null) {
      map['saturatedFat'] = {
        'value': saturatedFat?.value,
        'type': _enumToString(saturatedFat?.type)
      };
    }
    if (selenium != null) {
      map['selenium'] = {
        'value': selenium?.value,
        'type': _enumToString(selenium?.type)
      };
    }
    if (sodium != null) {
      map['sodium'] = {
        'value': sodium?.value,
        'type': _enumToString(sodium?.type)
      };
    }
    if (sugar != null) {
      map['sugar'] = {
        'value': sugar?.value,
        'type': _enumToString(sugar?.type)
      };
    }
    if (thiamin != null) {
      map['thiamin'] = {
        'value': thiamin?.value,
        'type': _enumToString(thiamin?.type)
      };
    }
    if (totalCarbohydrate != null) {
      map['totalCarbohydrate'] = {
        'value': totalCarbohydrate?.value,
        'type': _enumToString(totalCarbohydrate?.type)
      };
    }
    if (totalFat != null) {
      map['totalFat'] = {
        'value': totalFat?.value,
        'type': _enumToString(totalFat?.type)
      };
    }
    if (transFat != null) {
      map['transFat'] = {
        'value': transFat?.value,
        'type': _enumToString(transFat?.type)
      };
    }
    if (unsaturatedFat != null) {
      map['unsaturatedFat'] = {
        'value': unsaturatedFat?.value,
        'type': _enumToString(unsaturatedFat?.type)
      };
    }
    if (vitaminA != null) {
      map['vitaminA'] = {
        'value': vitaminA?.value,
        'type': _enumToString(vitaminA?.type)
      };
    }
    if (vitaminB12 != null) {
      map['vitaminB12'] = {
        'value': vitaminB12?.value,
        'type': _enumToString(vitaminB12?.type)
      };
    }
    if (vitaminB6 != null) {
      map['vitaminB6'] = {
        'value': vitaminB6?.value,
        'type': _enumToString(vitaminB6?.type)
      };
    }
    if (vitaminC != null) {
      map['vitaminC'] = {
        'value': vitaminC?.value,
        'type': _enumToString(vitaminC?.type)
      };
    }
    if (vitaminD != null) {
      map['vitaminD'] = {
        'value': vitaminD?.value,
        'type': _enumToString(vitaminD?.type)
      };
    }
    if (vitaminE != null) {
      map['vitaminE'] = {
        'value': vitaminE?.value,
        'type': _enumToString(vitaminE?.type)
      };
    }
    return map;
  }
}

enum MealType {
  UNKNOWN,
  BREAKFAST,
  LUNCH,
  DINNER,
  SNACK,
}

String getMealType(MealType data) {
  if (data == MealType.UNKNOWN) {
    return "unknown";
  } else if (data == MealType.BREAKFAST) {
    return "breakfast";
  } else if (data == MealType.DINNER) {
    return "dinner";
  } else if (data == MealType.LUNCH) {
    return "lunch";
  } else if (data == MealType.SNACK) {
    return "snack";
  }
  return "";
}
