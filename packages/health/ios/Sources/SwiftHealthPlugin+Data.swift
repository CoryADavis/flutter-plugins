import Flutter
import HealthKit

extension SwiftHealthPlugin {

  struct WriteDataInput {
    let value: Double
    let dataType: HealthDataTypes
    let dateFrom: Date
    let dateTo: Date
    let overwrite: Bool

    init(call: FlutterMethodCall) throws {
      guard let arguments = call.arguments as? NSDictionary,
            let value = (arguments["value"] as? Double),
            let type = (arguments["dataTypeKey"] as? String),
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber),
            let overwrite = (arguments["overwrite"] as? Bool) else {
        throw PluginError(message: "Invalid Arguments")
      }
      guard let dataType = HealthDataTypes(rawValue: type) else {
        throw PluginError(message: "Unrecognized dataTypeKey \(type)")
      }
      self.value = value
      self.dataType = dataType
      self.dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
      self.dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
      self.overwrite = overwrite
    }
  }

  func writeData(input: WriteDataInput, result: @escaping (Result<Bool, PluginError>) -> Void) {
    logger.debug("\(#function) \(input.dataType.rawValue) \(input.value)")

    let sample: HKObject? = if let unit = input.dataType.unit, let quantityType = input.dataType.quantityType {
      HKQuantitySample(
        type: quantityType,
        quantity: HKQuantity(unit: unit, doubleValue: input.value),
        start: input.dateFrom,
        end: input.dateTo
      )
    } else if let categoryType = input.dataType.categoryType {
      HKCategorySample(
        type: categoryType,
        value: Int(input.value),
        start: input.dateFrom,
        end: input.dateTo
      )
    } else {
      nil
    }
    guard let sample else {
      result(.failure(PluginError(message: "Failed to create HKObject for \(input.dataType.rawValue)")))
      return
    }

    let saveOperation = {
      healthStore.save(sample) { (success, error) in
        if let error {
          // TODO: - Is Dart ready to be forwarded these errors?
          logger.error("\(#function) saving \(input.dataType.rawValue) failed: \(error.localizedDescription)")
        }
        result(.success(success))
      }
    }

    if input.overwrite {
      guard let categoryType = input.dataType.categoryType else {
        logger.error("\(#function) deleting \(input.dataType.rawValue) failed: HKCategoryType could not be resolved")
        // TODO: - Dart should get telemetry about this. Add a telemetry return stream.
        saveOperation()
        return
      }
      healthStore.deleteObjects(
        of: categoryType,
        predicate: HKQuery.predicateForSamples(
          withStart: input.dateFrom,
          end: input.dateTo,
          options: []
        )
      ) { (_, _, error) in
        if let error {
          logger.error("\(#function) deleting \(input.dataType.rawValue) failed: \(error.localizedDescription)")
          // TODO: - Dart should get telemetry about this. Add a telemetry return stream.
        }
        saveOperation()
      }
    } else {
      saveOperation()
    }
  }

  struct DeleteDataInput {
    let dataType: HealthDataTypes
    let sampleType: HKSampleType
    let startDate: Date
    let endDate: Date

    init(call: FlutterMethodCall) throws {
      guard let arguments = call.arguments as? NSDictionary,
            let type = (arguments["dataTypeKey"] as? String),
            let startDate = (arguments["startTime"] as? NSNumber),
            let endDate = (arguments["endTime"] as? NSNumber) else {
        throw PluginError(message: "Invalid Arguments")
      }
      guard let dataType = HealthDataTypes(rawValue: type) else {
        throw PluginError(message: "HealthDataType for \(type)")
      }
      guard let sampleType = dataType.sampleType else {
        throw PluginError(message: "HKSampleType for \(type)")
      }
      self.dataType = dataType
      self.sampleType = sampleType
      self.startDate = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
      self.endDate = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
    }
  }

  func deleteData(input: DeleteDataInput, result: @escaping (Result<Bool, PluginError>) -> Void) {
    logger.debug("\(#function) \(input.dataType.rawValue)")

    healthStore.deleteObjects(
      of: input.sampleType,
      predicate: HKQuery.predicateForSamples(
        withStart: input.startDate,
        end: input.endDate,
        options: []
      )
    ) { (success, _, error) in
      if let error {
        // TODO: - Is Dart ready to be forwarded these errors?
        logger.error("\(#function) failed to delete sample \(input.dataType.rawValue): \(error.localizedDescription)")
      }
      result(.success(success))
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
