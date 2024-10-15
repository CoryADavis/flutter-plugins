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

  struct GetDataInput {
    let type: HealthDataTypes
    let sampleType: HKSampleType
    let unit: HKUnit
    let dateFrom: Date
    let dateTo: Date
    let limit: Int

    init(call: FlutterMethodCall) throws {
      guard let arguments = call.arguments as? NSDictionary,
            let dataTypeKey = (arguments["dataTypeKey"] as? String) else {
        throw PluginError(message: "Invalid Arguments")
      }
      guard let type = HealthDataTypes(rawValue: dataTypeKey) else {
        throw PluginError(message: "Unrecognized \(dataTypeKey)")
      }
      guard let sampleType = type.sampleType else {
        throw PluginError(message: "Failed to resolve HKSampleType for \(dataTypeKey)")
      }
      guard let unit = type.unit else {
        throw PluginError(message: "Failed to resolve HKUnit for \(dataTypeKey)")
      }
      self.type = type
      self.sampleType = sampleType
      self.unit = unit
      let startDate = (arguments["startDate"] as? NSNumber) ?? 0
      let endDate = (arguments["endDate"] as? NSNumber) ?? 0
      self.dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
      self.dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
      self.limit = (arguments["limit"] as? Int) ?? HKObjectQueryNoLimit
    }
  }

  func getData(input: GetDataInput, onCompletion: @escaping (Result<[[String: Any]], PluginError>) -> Void) {
    let predicate = HKQuery.predicateForSamples(
      withStart: input.dateFrom,
      end: input.dateTo,
      options: .strictStartDate
    )
    let sort = NSSortDescriptor(
      key: HKSampleSortIdentifierEndDate,
      ascending: false
    )
    let query =  HKSampleQuery(
      sampleType: input.sampleType,
      predicate: predicate,
      limit: input.limit,
      sortDescriptors: [sort],
      resultsHandler: { _, samples, error in
        if let error {
          logger.error("\(#function) query failed: \(error.localizedDescription)")
          onCompletion(.failure(PluginError(message: error.localizedDescription)))
          return
        }
        guard let samples else {
          onCompletion(.success([]))
          return
        }
        Self.parseGetDataQueryResults(
          type: input.type,
          unit: input.unit,
          samples: samples,
          onCompletion: onCompletion
        )
      }
    )
    healthStore.execute(query)
  }

  private static func parseGetDataQueryResults(
    type: HealthDataTypes,
    unit: HKUnit,
    samples: [HKSample],
    onCompletion: @escaping (Result<[[String: Any]], PluginError>) -> Void
  ) {
    if let samples = samples as? [HKQuantitySample] {
      let dictionaries = samples.map { sample -> [String: Any] in
        let metadata = sample.metadata?.reduce(into: [String: Any](), { dict, element in
          if let value = element.value as? NSString {
            dict[element.key] = String(value)
          } else if let value = element.value as? NSNumber {
            dict[element.key] = value
          } else if let value = element.value as? NSDate {
            dict[element.key] = NSNumber(integerLiteral: Int(value.timeIntervalSince1970 * 1000))
          } else {
            logger.error("\(#function) Unexpected metadata type for \(type.rawValue) \(element.key)")
          }
        })
        return [
          "uuid": "\(sample.uuid.uuidString)",
          "value": NSNumber(floatLiteral: sample.quantity.doubleValue(for: unit)),
          "date_from": NSNumber(integerLiteral: Int(sample.startDate.timeIntervalSince1970 * 1000)),
          "date_to": NSNumber(integerLiteral: Int(sample.endDate.timeIntervalSince1970 * 1000)),
          "source_id": sample.sourceRevision.source.bundleIdentifier,
          "source_name": sample.sourceRevision.source.name,
          "metadata": metadata ?? [:],
        ]
      }
      onCompletion(.success(dictionaries))
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
      let dictionaries = samples.map { sample -> [String: Any] in
        return [
          "uuid": "\(sample.uuid.uuidString)",
          "value": NSNumber(integerLiteral: sample.value),
          "date_from": NSNumber(integerLiteral: Int(sample.startDate.timeIntervalSince1970 * 1000)),
          "date_to": NSNumber(integerLiteral: Int(sample.endDate.timeIntervalSince1970 * 1000)),
          "source_id": sample.sourceRevision.source.bundleIdentifier,
          "source_name": sample.sourceRevision.source.name
        ]
      }
      onCompletion(.success(dictionaries))
      return
    }

    if let samples = samples as? [HKWorkout] {
      let dictionaries = samples.map { sample -> [String: Any] in
        return [
          "uuid": "\(sample.uuid.uuidString)",
          "value": NSNumber(integerLiteral: Int(sample.duration)),
          "date_from": NSNumber(integerLiteral: Int(sample.startDate.timeIntervalSince1970 * 1000)),
          "date_to": NSNumber(integerLiteral: Int(sample.endDate.timeIntervalSince1970 * 1000)),
          "source_id": sample.sourceRevision.source.bundleIdentifier,
          "source_name": sample.sourceRevision.source.name
        ]
      }
      onCompletion(.success(dictionaries))
      return
    }

    logger.error("\(#function) Unexpected query result type for \(type.rawValue)")
    onCompletion(.failure(PluginError(message: "Unexpected query result type for \(type.rawValue)")))
  }
}
