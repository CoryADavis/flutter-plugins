import Flutter
import Foundation
import HealthKit

extension SwiftHealthPlugin {

  func writeFoodData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let foodList = arguments["foodList"] as? Array<Dictionary<String, Any>>,
          let startDate = (arguments["startTime"] as? NSNumber),
          let endDate = (arguments["endTime"] as? NSNumber),
          let overwrite = (arguments["overwrite"] as? Bool) else {
      DispatchQueue.main.async {
        result(PluginError(message: "Invalid Arguments"))
      }
      return
    }

    logger.debug("\(#function)")

    var nutrientAccess: [HealthDataTypes: Bool?] = [:]

    for nutrient in HealthDataTypes.nutrientsToWrite {
      guard let type = nutrient.sampleType else {
        logger.error("Missing HKSampleType expected for nutrient \(nutrient.rawValue)")
        continue
      }
      nutrientAccess[nutrient] = hasPermission(type: type, access: 1)
    }

    let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
    let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)

    var consumedFoods: Array<HKCorrelation> = []

    for var food in foodList {
      guard let timestamp = food.removeValue(forKey: "timestamp") as? NSNumber else {
        logger.error("Missing timestamp")
        continue
      }
      let date = Date(timeIntervalSince1970: timestamp.doubleValue / 1000)

      var foodSamples: Set<HKSample> = []
      for (key, value) in food {
        guard let nutrient = HealthDataTypes(rawValue: key)else {
          logger.error("Unexpected nutrient \(key)")
          continue
        }
        guard let quantityType = nutrient.quantityType else {
          logger.error("Missing HKQuantityType expected for food nutrient \(key)")
          continue
        }
        guard let unit = nutrient.unit else {
          logger.error("Missing HKUnit expected for food nutrient \(key)")
          continue
        }
        guard let value = value as? Double else {
          logger.error("Expected Double value for \(key)")
          continue
        }
        if nutrientAccess[nutrient] == true {
          let sample = HKQuantitySample(
            type: quantityType,
            quantity: HKQuantity(unit: unit, doubleValue: value),
            start: date,
            end: date
          )
          foodSamples.insert(sample)
        } else {
          logger.debug("Skipping \(key) \(value) because access is nil or false")
        }
      }

      if foodSamples.isEmpty {
        logger.debug("\(#function) skipping empty food at timestamp \(timestamp)")
        continue
      }

      guard let foodType = HKCorrelationType.correlationType(forIdentifier: .food) else {
        DispatchQueue.main.async {
          result(PluginError(message: "Failed to create HKCorrelationType for .food"))
        }
        return
      }

      consumedFoods.append(
        HKCorrelation(
          type: foodType,
          start: date,
          end: date,
          objects: foodSamples
        )
      )
    }

    guard let foodType = HKCorrelationType.correlationType(forIdentifier: .food) else {
      DispatchQueue.main.async {
        result(PluginError(message: "Failed to create HKCorrelationType for .food"))
      }
      return
    }

    let query = HKCorrelationQuery(
      type: foodType,
      predicate: HKCorrelationQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: []),
      samplePredicates: nil
    ) { query, results, error in
      if let error {
        logger.error("\(#function) querying samples to delete: \(error.localizedDescription)")
      }
      guard let correlations = results else {
        logger.error("\(#function) nil results")
        return
      }

      var samplesToDelete: Array<HKSample> = []
      for correlation in correlations {
        for sample in correlation.objects {
          samplesToDelete.append(sample)
        }
      }

      let saveOperation = {
        if consumedFoods.isEmpty {
          DispatchQueue.main.async {
            result(true)
          }
          return
        }

        healthStore.save(consumedFoods) { (success, error) in
          if let error {
            logger.error("\(#function) saving consumedFoods failed: \(error.localizedDescription)")
          }
          DispatchQueue.main.async {
            result(success)
          }
        }
      }

      if overwrite, !samplesToDelete.isEmpty {
        healthStore.delete(samplesToDelete) { (success, error) in
          if let error {
            logger.error("\(#function) deleting failed: \(error.localizedDescription)")
          }
          saveOperation()
        }
      } else {
        saveOperation()
      }
    }

    healthStore.execute(query)
  }

  func deleteFoodData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let startDate = (arguments["startTime"] as? NSNumber),
          let endDate = (arguments["endTime"] as? NSNumber) else {
      DispatchQueue.main.async {
        result(PluginError(message: "Invalid Arguments"))
      }
      return
    }

    logger.debug("\(#function)")

    let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
    let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)

    guard let foodCorrelationType = HKCorrelationType.correlationType(forIdentifier: .food) else {
      DispatchQueue.main.async {
        result(PluginError(message: "Failed to create HKCorrelationType for .food"))
      }
      return
    }

    let query = HKCorrelationQuery(
      type: foodCorrelationType,
      predicate: HKCorrelationQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: []),
      samplePredicates: nil
    ) { query, results, error in
      if let error {
        logger.error("\(#function) query to prepare delete failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
          result(false)
        }
        return
      }
      guard let correlations = results else {
        logger.error("\(#function) nil results")
        DispatchQueue.main.async {
          result(false)
        }
        return
      }

      var samplesToDelete: Array<HKSample> = []
      for correlation in correlations {
        for sample in correlation.objects {
          samplesToDelete.append(sample)
        }
      }

      if samplesToDelete.isEmpty {
        DispatchQueue.main.async {
          result(true)
        }
        return
      }

      healthStore.delete(samplesToDelete) { (success, error) in
        if let error {
          logger.error("\(#function) deletion failed: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
          result(success)
        }
      }
    }

    healthStore.execute(query)
  }
}
