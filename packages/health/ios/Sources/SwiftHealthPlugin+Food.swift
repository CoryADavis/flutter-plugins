import Flutter
import Foundation
import HealthKit

extension SwiftHealthPlugin {

  struct WriteFoodDataInput {
    let dateFrom: Date
    let dateTo: Date
    let foodList: [FoodItem]
    let overwrite: Bool

    init(call: FlutterMethodCall) throws {
      guard let arguments = call.arguments as? NSDictionary,
            let foodList = arguments["foodList"] as? Array<Dictionary<String, Any>>,
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber),
            let overwrite = (arguments["overwrite"] as? Bool) else {
        throw PluginError(message: "Invalid Arguments")
      }
      self.dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
      self.dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
      self.overwrite = overwrite
      self.foodList = foodList.compactMap(FoodItem.init)
    }

    struct FoodItem {
      let timestamp: Date
      let nutrients: [String: Double]

      init?(rawFood: Dictionary<String, Any>) {
        guard let timestamp = rawFood["timestamp"] as? NSNumber else {
          // TODO: - Surface these errors to Dart via side channel
          logger.error("Missing timestamp")
          return nil
        }
        self.timestamp = Date(timeIntervalSince1970: timestamp.doubleValue / 1000)
        self.nutrients = rawFood.reduce(into: [String: Double]()) { result, element in
          guard element.key != "timestamp" else { return }
          guard let doubleValue = element.value as? Double else {
            // TODO: - Surface these errors to Dart via side channel
            logger.error("Expected Double value for \(element.key)")
            return
          }
          result[element.key] = doubleValue
        }
      }
    }
  }

  func writeFoodData(input: WriteFoodDataInput, result: @escaping (Result<Bool, PluginError>) -> Void) {
    logger.debug("\(#function)")

    var nutrientAccess: [HealthDataTypes: Bool?] = [:]

    for nutrient in HealthDataTypes.nutrientsToWrite {
      guard let type = nutrient.sampleType else {
        // TODO: - Surface these errors to Dart via side channel
        logger.error("Missing HKSampleType expected for nutrient \(nutrient.rawValue)")
        continue
      }
      nutrientAccess[nutrient] = hasPermission(type: type, access: 1)
    }

    var consumedFoods: Array<HKCorrelation> = []

    for food in input.foodList {
      var foodSamples: Set<HKSample> = []
      for (key, value) in food.nutrients {
        guard let nutrient = HealthDataTypes(rawValue: key) else {
          logger.error("Unexpected nutrient \(key)")
          // TODO: - Surface these errors to Dart via side channel
          continue
        }
        guard let quantityType = nutrient.quantityType else {
          logger.error("Missing HKQuantityType expected for food nutrient \(key)")
          // TODO: - Surface these errors to Dart via side channel
          continue
        }
        guard let unit = nutrient.unit else {
          logger.error("Missing HKUnit expected for food nutrient \(key)")
          // TODO: - Surface these errors to Dart via side channel
          continue
        }
        if nutrientAccess[nutrient] == true {
          let sample = HKQuantitySample(
            type: quantityType,
            quantity: HKQuantity(unit: unit, doubleValue: value),
            start: food.timestamp,
            end: food.timestamp
          )
          foodSamples.insert(sample)
        } else {
          logger.debug("Skipping \(key) \(value) because access is nil or false")
          // TODO: - Surface these errors to Dart via side channel
        }
      }

      if foodSamples.isEmpty {
        logger.debug("\(#function) skipping empty food at timestamp \(food.timestamp)")
        // TODO: - Is Dart ready to receive this error?
        continue
      }

      guard let foodType = HKCorrelationType.correlationType(forIdentifier: .food) else {
        result(.failure(PluginError(message: "Failed to create HKCorrelationType for .food")))
        // TODO: - Surface these errors to Dart via side channel
        return
      }

      consumedFoods.append(
        HKCorrelation(
          type: foodType,
          start: food.timestamp,
          end: food.timestamp,
          objects: foodSamples
        )
      )
    }

    guard let foodType = HKCorrelationType.correlationType(forIdentifier: .food) else {
      result(.failure(PluginError(message: "Failed to create HKCorrelationType for .food")))
      // TODO: - Surface these errors to Dart via side channel
      return
    }

    let query = HKCorrelationQuery(
      type: foodType,
      predicate: HKCorrelationQuery.predicateForSamples(withStart: input.dateFrom, end: input.dateTo, options: []),
      samplePredicates: nil
    ) { query, results, error in
      if let error {
        logger.error("\(#function) querying samples to delete: \(error.localizedDescription)")
        // TODO: - Surface these errors to Dart via side channel
      }
      guard let correlations = results else {
        logger.error("\(#function) nil results")
        // TODO: - Is Dart ready to receive this error?
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
          result(.success(true))
          return
        }

        healthStore.save(consumedFoods) { (success, error) in
          if let error {
            logger.error("\(#function) saving consumedFoods failed: \(error.localizedDescription)")
            // TODO: - Is Dart ready to receive this error?
          }
          result(.success(success))
        }
      }

      if input.overwrite, !samplesToDelete.isEmpty {
        healthStore.delete(samplesToDelete) { (success, error) in
          if let error {
            logger.error("\(#function) deleting failed: \(error.localizedDescription)")
            // TODO: - Is this error worth absorbing? Perhaps surfaced via side channel.
          }
          saveOperation()
        }
      } else {
        saveOperation()
      }
    }

    healthStore.execute(query)
  }

  struct DeleteFoodDataInput {
    let startDate: Date
    let endDate: Date

    init(call: FlutterMethodCall) throws {
      guard let arguments = call.arguments as? NSDictionary,
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber) else {
        throw PluginError(message: "Invalid Arguments")
      }
      self.startDate = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
      self.endDate = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
    }
  }

  func deleteFoodData(input: DeleteFoodDataInput, result: @escaping (Result<Bool, PluginError>) -> Void) {
    logger.debug("\(#function)")

    guard let foodCorrelationType = HKCorrelationType.correlationType(forIdentifier: .food) else {
      result(.failure(PluginError(message: "Failed to create HKCorrelationType for .food")))
      return
    }

    let query = HKCorrelationQuery(
      type: foodCorrelationType,
      predicate: HKCorrelationQuery.predicateForSamples(withStart: input.startDate, end: input.endDate, options: []),
      samplePredicates: nil
    ) { query, results, error in
      if let error {
        logger.error("\(#function) query to prepare delete failed: \(error.localizedDescription)")
        result(.success(false))
        // TODO: - Is Dart ready to be forwarded these errors?
        return
      }
      guard let correlations = results else {
        logger.error("\(#function) nil results")
        result(.success(false))
        return
      }

      var samplesToDelete: Array<HKSample> = []
      for correlation in correlations {
        for sample in correlation.objects {
          samplesToDelete.append(sample)
        }
      }

      if samplesToDelete.isEmpty {
        result(.success(true))
        return
      }

      healthStore.delete(samplesToDelete) { (success, error) in
        if let error {
          logger.error("\(#function) deletion failed: \(error.localizedDescription)")
          // TODO: - Is Dart ready to be forwarded these errors?
        }
        result(.success(success))
      }
    }

    healthStore.execute(query)
  }
}
