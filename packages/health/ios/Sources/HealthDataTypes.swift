import HealthKit

enum HealthDataTypes: String, CaseIterable {
  case ACTIVE_ENERGY_BURNED
  case BASAL_ENERGY_BURNED
  case BLOOD_GLUCOSE
  case BLOOD_OXYGEN
  case BLOOD_PRESSURE_DIASTOLIC
  case BLOOD_PRESSURE_SYSTOLIC
  case BODY_FAT_PERCENTAGE
  case BODY_MASS_INDEX
  case BODY_TEMPERATURE
  case DISTANCE_WALKING_RUNNING
  case ELECTRODERMAL_ACTIVITY
  case EXERCISE_TIME
  case FLIGHTS_CLIMBED
  case FORCED_EXPIRATORY_VOLUME
  case HEART_RATE
  case HEART_RATE_VARIABILITY_SDNN
  case HEIGHT
  case HIGH_HEART_RATE_EVENT
  case IRREGULAR_HEART_RATE_EVENT
  case LOW_HEART_RATE_EVENT
  case MINDFULNESS
  case RESTING_HEART_RATE
  case SLEEP_ASLEEP
  case SLEEP_AWAKE
  case SLEEP_IN_BED
  case STEPS
  case WAIST_CIRCUMFERENCE
  case WALKING_HEART_RATE
  case WATER
  case WEIGHT
  case WORKOUT

  case DIETARY_CAFFEINE
  case DIETARY_CALCIUM
  case DIETARY_CARBS_CONSUMED
  case DIETARY_CHOLESTEROL
  case DIETARY_COPPER
  case DIETARY_ENERGY_CONSUMED
  case DIETARY_FAT_MONOUNSATURATED
  case DIETARY_FAT_POLYUNSATURATED
  case DIETARY_FAT_SATURATED
  case DIETARY_FATS_CONSUMED
  case DIETARY_FIBER
  case DIETARY_FOLATE
  case DIETARY_IRON
  case DIETARY_MAGNESIUM
  case DIETARY_MANGANESE
  case DIETARY_NIACIN
  case DIETARY_PANTOTHENIC_ACID
  case DIETARY_PHOSPHORUS
  case DIETARY_POTASSIUM
  case DIETARY_PROTEIN_CONSUMED
  case DIETARY_RIBOFLAVIN
  case DIETARY_SELENIUM
  case DIETARY_SODIUM
  case DIETARY_SUGAR
  case DIETARY_THIAMIN
  case DIETARY_VITAMIN_A
  case DIETARY_VITAMIN_B12
  case DIETARY_VITAMIN_B6
  case DIETARY_VITAMIN_C
  case DIETARY_VITAMIN_D
  case DIETARY_VITAMIN_E
  case DIETARY_VITAMIN_K
  case DIETARY_WATER
  case DIETARY_ZINC

  static let nutrientsToWrite: [HealthDataTypes] = HealthDataTypes.allCases.filter { $0.rawValue.hasPrefix("DIETARY") }
}

extension HealthDataTypes {

  var unit: HKUnit? {
    switch self {
    case .ACTIVE_ENERGY_BURNED: HKUnit.kilocalorie()
    case .BASAL_ENERGY_BURNED: HKUnit.kilocalorie()
    case .BLOOD_GLUCOSE: HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
    case .BLOOD_OXYGEN: HKUnit.percent()
    case .BLOOD_PRESSURE_DIASTOLIC: HKUnit.millimeterOfMercury()
    case .BLOOD_PRESSURE_SYSTOLIC: HKUnit.millimeterOfMercury()
    case .BODY_FAT_PERCENTAGE: HKUnit.percent()
    case .BODY_MASS_INDEX: HKUnit.count()
    case .BODY_TEMPERATURE: HKUnit.degreeCelsius()
    case .DIETARY_CAFFEINE: HKUnit.gramUnit(with: .milli)
    case .DIETARY_CALCIUM: HKUnit.gramUnit(with: .milli)
    case .DIETARY_CARBS_CONSUMED: HKUnit.gram()
    case .DIETARY_CHOLESTEROL: HKUnit.gramUnit(with: .milli)
    case .DIETARY_COPPER: HKUnit.gramUnit(with: .milli)
    case .DIETARY_ENERGY_CONSUMED: HKUnit.kilocalorie()
    case .DIETARY_FAT_MONOUNSATURATED: HKUnit.gram()
    case .DIETARY_FAT_POLYUNSATURATED: HKUnit.gram()
    case .DIETARY_FAT_SATURATED: HKUnit.gram()
    case .DIETARY_FATS_CONSUMED: HKUnit.gram()
    case .DIETARY_FIBER: HKUnit.gram()
    case .DIETARY_FOLATE: HKUnit.gramUnit(with: .micro)
    case .DIETARY_IRON: HKUnit.gramUnit(with: .milli)
    case .DIETARY_MAGNESIUM: HKUnit.gramUnit(with: .milli)
    case .DIETARY_MANGANESE: HKUnit.gramUnit(with: .milli)
    case .DIETARY_NIACIN: HKUnit.gramUnit(with: .milli)
    case .DIETARY_PANTOTHENIC_ACID: HKUnit.gramUnit(with: .milli)
    case .DIETARY_PHOSPHORUS: HKUnit.gramUnit(with: .milli)
    case .DIETARY_POTASSIUM: HKUnit.gramUnit(with: .milli)
    case .DIETARY_PROTEIN_CONSUMED: HKUnit.gram()
    case .DIETARY_RIBOFLAVIN: HKUnit.gramUnit(with: .milli)
    case .DIETARY_SELENIUM: HKUnit.gramUnit(with: .micro)
    case .DIETARY_SODIUM: HKUnit.gramUnit(with: .milli)
    case .DIETARY_SUGAR: HKUnit.gram()
    case .DIETARY_THIAMIN: HKUnit.gramUnit(with: .milli)
    case .DIETARY_VITAMIN_A: HKUnit.gramUnit(with: .micro)
    case .DIETARY_VITAMIN_B12: HKUnit.gramUnit(with: .micro)
    case .DIETARY_VITAMIN_B6: HKUnit.gramUnit(with: .milli)
    case .DIETARY_VITAMIN_C: HKUnit.gramUnit(with: .milli)
    case .DIETARY_VITAMIN_D: HKUnit.gramUnit(with: .micro)
    case .DIETARY_VITAMIN_E: HKUnit.gramUnit(with: .milli)
    case .DIETARY_VITAMIN_K: HKUnit.gramUnit(with: .micro)
    case .DIETARY_WATER: HKUnit.liter()
    case .DIETARY_ZINC: HKUnit.gramUnit(with: .milli)
    case .DISTANCE_WALKING_RUNNING: HKUnit.meter()
    case .ELECTRODERMAL_ACTIVITY: HKUnit.siemen()
    case .EXERCISE_TIME: HKUnit.minute()
    case .FLIGHTS_CLIMBED: HKUnit.count()
    case .FORCED_EXPIRATORY_VOLUME: HKUnit.liter()
    case .HEART_RATE_VARIABILITY_SDNN: HKUnit.secondUnit(with: .milli)
    case .HEART_RATE: HKUnit.count().unitDivided(by: HKUnit.minute())
    case .HEIGHT: HKUnit.meter()
    case .HIGH_HEART_RATE_EVENT: HKUnit.count()
    case .IRREGULAR_HEART_RATE_EVENT: HKUnit.count()
    case .LOW_HEART_RATE_EVENT: HKUnit.count()
    case .RESTING_HEART_RATE: HKUnit.count().unitDivided(by: HKUnit.minute())
    case .STEPS: HKUnit.count()
    case .WAIST_CIRCUMFERENCE: HKUnit.meter()
    case .WALKING_HEART_RATE: HKUnit.count().unitDivided(by: HKUnit.minute())
    case .WATER: HKUnit.liter()
    case .WEIGHT: HKUnit.gramUnit(with: .kilo)

    case .MINDFULNESS: nil
    case .SLEEP_ASLEEP: nil
    case .SLEEP_AWAKE: nil
    case .SLEEP_IN_BED: nil
    case .WORKOUT: nil
    }
  }

  var sampleType: HKSampleType? {
    quantityType ?? categoryType ?? workoutType
  }

  var quantityType: HKQuantityType? {
    switch self {
    case .ACTIVE_ENERGY_BURNED: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
    case .BASAL_ENERGY_BURNED: HKSampleType.quantityType(forIdentifier: .basalEnergyBurned)
    case .BLOOD_GLUCOSE: HKSampleType.quantityType(forIdentifier: .bloodGlucose)
    case .BLOOD_OXYGEN: HKSampleType.quantityType(forIdentifier: .oxygenSaturation)
    case .BLOOD_PRESSURE_DIASTOLIC: HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)
    case .BLOOD_PRESSURE_SYSTOLIC: HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)
    case .BODY_FAT_PERCENTAGE: HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)
    case .BODY_MASS_INDEX: HKSampleType.quantityType(forIdentifier: .bodyMassIndex)
    case .BODY_TEMPERATURE: HKSampleType.quantityType(forIdentifier: .bodyTemperature)
    case .DIETARY_CARBS_CONSUMED: HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)
    case .DIETARY_ENERGY_CONSUMED: HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)
    case .DIETARY_FATS_CONSUMED: HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)
    case .DIETARY_PROTEIN_CONSUMED: HKSampleType.quantityType(forIdentifier: .dietaryProtein)
    case .ELECTRODERMAL_ACTIVITY: HKSampleType.quantityType(forIdentifier: .electrodermalActivity)
    case .FORCED_EXPIRATORY_VOLUME: HKSampleType.quantityType(forIdentifier: .forcedExpiratoryVolume1)
    case .HEART_RATE: HKSampleType.quantityType(forIdentifier: .heartRate)
    case .HEART_RATE_VARIABILITY_SDNN: HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
    case .HEIGHT: HKSampleType.quantityType(forIdentifier: .height)
    case .RESTING_HEART_RATE: HKSampleType.quantityType(forIdentifier: .restingHeartRate)
    case .STEPS: HKSampleType.quantityType(forIdentifier: .stepCount)
    case .WAIST_CIRCUMFERENCE: HKSampleType.quantityType(forIdentifier: .waistCircumference)
    case .WALKING_HEART_RATE: HKSampleType.quantityType(forIdentifier: .walkingHeartRateAverage)
    case .WEIGHT: HKSampleType.quantityType(forIdentifier: .bodyMass)
    case .DISTANCE_WALKING_RUNNING: HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
    case .FLIGHTS_CLIMBED: HKSampleType.quantityType(forIdentifier: .flightsClimbed)
    case .WATER: HKSampleType.quantityType(forIdentifier: .dietaryWater)
    case .EXERCISE_TIME: HKSampleType.quantityType(forIdentifier: .appleExerciseTime)
    case .DIETARY_FAT_SATURATED: HKSampleType.quantityType(forIdentifier: .dietaryFatSaturated)
    case .DIETARY_FAT_POLYUNSATURATED: HKSampleType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)
    case .DIETARY_FAT_MONOUNSATURATED: HKSampleType.quantityType(forIdentifier: .dietaryFatMonounsaturated)
    case .DIETARY_CHOLESTEROL: HKSampleType.quantityType(forIdentifier: .dietaryCholesterol)
    case .DIETARY_SODIUM: HKSampleType.quantityType(forIdentifier: .dietarySodium)
    case .DIETARY_POTASSIUM: HKSampleType.quantityType(forIdentifier: .dietaryPotassium)
    case .DIETARY_FIBER: HKSampleType.quantityType(forIdentifier: .dietaryFiber)
    case .DIETARY_SUGAR: HKSampleType.quantityType(forIdentifier: .dietarySugar)
    case .DIETARY_VITAMIN_A: HKSampleType.quantityType(forIdentifier: .dietaryVitaminA)
    case .DIETARY_THIAMIN: HKSampleType.quantityType(forIdentifier: .dietaryThiamin)
    case .DIETARY_RIBOFLAVIN: HKSampleType.quantityType(forIdentifier: .dietaryRiboflavin)
    case .DIETARY_NIACIN: HKSampleType.quantityType(forIdentifier: .dietaryNiacin)
    case .DIETARY_PANTOTHENIC_ACID: HKSampleType.quantityType(forIdentifier: .dietaryPantothenicAcid)
    case .DIETARY_VITAMIN_B6: HKSampleType.quantityType(forIdentifier: .dietaryVitaminB6)
    case .DIETARY_VITAMIN_B12: HKSampleType.quantityType(forIdentifier: .dietaryVitaminB12)
    case .DIETARY_VITAMIN_C: HKSampleType.quantityType(forIdentifier: .dietaryVitaminC)
    case .DIETARY_VITAMIN_D: HKSampleType.quantityType(forIdentifier: .dietaryVitaminD)
    case .DIETARY_VITAMIN_E: HKSampleType.quantityType(forIdentifier: .dietaryVitaminE)
    case .DIETARY_VITAMIN_K: HKSampleType.quantityType(forIdentifier: .dietaryVitaminK)
    case .DIETARY_FOLATE: HKSampleType.quantityType(forIdentifier: .dietaryFolate)
    case .DIETARY_CALCIUM: HKSampleType.quantityType(forIdentifier: .dietaryCalcium)
    case .DIETARY_IRON: HKSampleType.quantityType(forIdentifier: .dietaryIron)
    case .DIETARY_MAGNESIUM: HKSampleType.quantityType(forIdentifier: .dietaryMagnesium)
    case .DIETARY_PHOSPHORUS: HKSampleType.quantityType(forIdentifier: .dietaryPhosphorus)
    case .DIETARY_ZINC: HKSampleType.quantityType(forIdentifier: .dietaryZinc)
    case .DIETARY_WATER: HKSampleType.quantityType(forIdentifier: .dietaryWater)
    case .DIETARY_CAFFEINE: HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)
    case .DIETARY_COPPER: HKSampleType.quantityType(forIdentifier: .dietaryCopper)
    case .DIETARY_MANGANESE: HKSampleType.quantityType(forIdentifier: .dietaryManganese)
    case .DIETARY_SELENIUM: HKSampleType.quantityType(forIdentifier: .dietarySelenium)

    case .HIGH_HEART_RATE_EVENT: nil
    case .IRREGULAR_HEART_RATE_EVENT: nil
    case .LOW_HEART_RATE_EVENT: nil
    case .MINDFULNESS: nil
    case .SLEEP_ASLEEP: nil
    case .SLEEP_AWAKE: nil
    case .SLEEP_IN_BED: nil
    case .WORKOUT: nil
    }
  }

  var categoryType: HKCategoryType? {
    switch self {
    case .MINDFULNESS: HKSampleType.categoryType(forIdentifier: .mindfulSession)
    case .SLEEP_IN_BED: HKSampleType.categoryType(forIdentifier: .sleepAnalysis)
    case .SLEEP_ASLEEP: HKSampleType.categoryType(forIdentifier: .sleepAnalysis)
    case .SLEEP_AWAKE: HKSampleType.categoryType(forIdentifier: .sleepAnalysis)
    case .HIGH_HEART_RATE_EVENT: HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)
    case .LOW_HEART_RATE_EVENT: HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)
    case .IRREGULAR_HEART_RATE_EVENT: HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)
    default: nil
    }
  }

  var workoutType:  HKWorkoutType? {
    switch self {
    case .WORKOUT: HKSampleType.workoutType()
    default: nil
    }
  }
}
