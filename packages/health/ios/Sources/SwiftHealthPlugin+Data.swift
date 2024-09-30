import Flutter
import HealthKit

extension SwiftHealthPlugin {

  func writeData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let value = (arguments["value"] as? Double),
          let type = (arguments["dataTypeKey"] as? String),
          let startDate = (arguments["startTime"] as? NSNumber),
          let endDate = (arguments["endTime"] as? NSNumber),
          let overwrite = (arguments["overwrite"] as? Bool) else {
      DispatchQueue.main.async {
        result(PluginError(message: "Invalid Arguments"))
      }
      return
    }
    guard let dataType = HealthDataTypes(rawValue: type) else {
      DispatchQueue.main.async {
        result(PluginError(message: "Unrecognized dataTypeKey \(type)"))
      }
      return
    }

    logger.debug("\(#function) \(dataType.rawValue) \(value)")

    let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
    let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)

    let sample: HKObject? = if let unit = dataType.unit, let quantityType = dataType.quantityType {
      HKQuantitySample(
        type: quantityType,
        quantity: HKQuantity(unit: unit, doubleValue: value),
        start: dateFrom,
        end: dateTo
      )
    } else if let categoryType = dataType.categoryType {
      HKCategorySample(
        type: categoryType,
        value: Int(value),
        start: dateFrom,
        end: dateTo
      )
    } else {
      nil
    }
    guard let sample else {
      DispatchQueue.main.async {
        result(PluginError(message: "Failed to create HKObject for \(type)"))
      }
      return
    }

    let saveOperation = {
      healthStore.save(sample) { (success, error) in
        if let error {
          logger.error("\(#function) saving \(type) failed: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
          result(success)
        }
      }
    }

    if overwrite {
      guard let categoryType = dataType.categoryType else {
        logger.error("\(#function) deleting \(type) failed: HKCategoryType could not be resolved")
        saveOperation()
        return
      }
      healthStore.deleteObjects(
        of: categoryType,
        predicate: HKQuery.predicateForSamples(
          withStart: dateFrom,
          end: dateTo,
          options: []
        )
      ) { (_, _, error) in
        if let error {
          logger.error("\(#function) deleting \(type) failed: \(error.localizedDescription)")
        }
        saveOperation()
      }
    } else {
      saveOperation()
    }
  }

  func deleteData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let type = (arguments["dataTypeKey"] as? String),
          let startDate = (arguments["startTime"] as? NSNumber),
          let endDate = (arguments["endTime"] as? NSNumber) else {
      DispatchQueue.main.async {
        result(PluginError(message: "Invalid Arguments"))
      }
      return
    }
    guard let sampleType = HealthDataTypes(rawValue: type)?.sampleType else {
      DispatchQueue.main.async {
        result(PluginError(message: "HealthDataType or HKSampleType for \(type)"))
      }
      return
    }

    logger.debug("\(#function) \(type)")

    healthStore.deleteObjects(
      of: sampleType,
      predicate: HKQuery.predicateForSamples(
        withStart: Date(timeIntervalSince1970: startDate.doubleValue / 1000),
        end: Date(timeIntervalSince1970: endDate.doubleValue / 1000),
        options: []
      )
    ) { (success, _, error) in
      if let error {
        logger.error("\(#function) failed to delete sample \(type): \(error.localizedDescription)")
      }
      DispatchQueue.main.async {
        result(success)
      }
    }
  }

  func getData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? NSDictionary
    let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
    let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
    let endDate = (arguments?["endDate"] as? NSNumber) ?? 0
    let limit = (arguments?["limit"] as? Int) ?? HKObjectQueryNoLimit

    guard let type = HealthDataTypes(rawValue: dataTypeKey) else {
      result(PluginError(message: "Unrecognized \(dataTypeKey)"))
      return
    }
    guard let sampleType = type.sampleType else {
      result(PluginError(message: "Failed to resolve HKSampleType for \(dataTypeKey)"))
      return
    }
    guard let unit = type.unit else {
      result(PluginError(message: "Failed to resolve HKUnit for \(dataTypeKey)"))
      return
    }

    let predicate = HKQuery.predicateForSamples(
      withStart: Date(timeIntervalSince1970: startDate.doubleValue / 1000),
      end: Date(timeIntervalSince1970: endDate.doubleValue / 1000),
      options: .strictStartDate
    )
    let sort = NSSortDescriptor(
      key: HKSampleSortIdentifierEndDate,
      ascending: false
    )

    let query =  HKSampleQuery(
      sampleType: sampleType,
      predicate: predicate,
      limit: limit,
      sortDescriptors: [sort]
    ) { _, samples, error in

      if let error {
        logger.error("\(#function) query failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
          result(nil)
        }
        return
      }

      guard let samples else {
        DispatchQueue.main.async {
          result(nil)
        }
        return
      }

      if let samples = samples as? [HKQuantitySample] {
        let dictionaries = samples.map { sample -> NSDictionary in
          return [
            "uuid": "\(sample.uuid)",
            "value": sample.quantity.doubleValue(for: unit),
            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
            "source_id": sample.sourceRevision.source.bundleIdentifier,
            "source_name": sample.sourceRevision.source.name,
            "metadata": sample.metadata ?? [:],
          ]
        }
        DispatchQueue.main.async { [dictionaries] in
          result(dictionaries)
        }
        return
      }

      if var samples = samples as? [HKCategorySample] {
        if type == .SLEEP_IN_BED {
          samples = samples.filter { $0.value == 0 }
        }
        if type == .SLEEP_AWAKE {
          samples = samples.filter { $0.value == 2 }
        }
        if type == .SLEEP_ASLEEP {
          samples = samples.filter { $0.value == 1 }
        }
        let categories = samples.map { sample -> NSDictionary in
          return [
            "uuid": "\(sample.uuid)",
            "value": sample.value,
            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
            "source_id": sample.sourceRevision.source.bundleIdentifier,
            "source_name": sample.sourceRevision.source.name
          ]
        }
        DispatchQueue.main.async {
          result(categories)
        }
        return
      }

      if let samples = samples as? [HKWorkout] {
        let dictionaries = samples.map { sample -> NSDictionary in
          return [
            "uuid": "\(sample.uuid)",
            "value": Int(sample.duration),
            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
            "source_id": sample.sourceRevision.source.bundleIdentifier,
            "source_name": sample.sourceRevision.source.name
          ]
        }
        DispatchQueue.main.async {
          result(dictionaries)
        }
        return
      }

      logger.error("\(#function) Unexpectedly did not find an expected query result")
      DispatchQueue.main.async {
        result(nil)
      }
    }

    healthStore.execute(query)
  }
}
