import Flutter
import HealthKit

extension SwiftHealthPlugin {
  func getTotalStepsInInterval(call: FlutterMethodCall, result: @escaping (Result<Int?, PluginError>) -> Void) {
    let arguments = call.arguments as? NSDictionary
    let startEpoch = (arguments?["startDate"] as? NSNumber) ?? 0
    let startTime = Date(timeIntervalSince1970: startEpoch.doubleValue / 1000)
    let startDateStartOfDay = Calendar(identifier: .gregorian).startOfDay(for: startTime)
    let endEpoch = (arguments?["endDate"] as? NSNumber) ?? 0
    let endTime = Date(timeIntervalSince1970: endEpoch.doubleValue / 1000)

    guard let sampleType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
      result(.failure(PluginError(message: "Failed to create HKQuantityType.stepCount")))
      return
    }

    guard healthStore.authorizationStatus(for: sampleType) == .sharingAuthorized else {
      result(.success(nil))
      return
    }

    let query = HKStatisticsCollectionQuery(
      quantityType: sampleType,
      quantitySamplePredicate: HKQuery.predicateForSamples(
        withStart: startTime,
        end: endTime,
        options: []
      ),
      options: [.cumulativeSum],
      anchorDate: startDateStartOfDay,
      intervalComponents: DateComponents(day: 1)
    )

    query.initialResultsHandler = { query, queryResult, error in
      if let error {
        logger.error("\(#function) query failed: \(error.localizedDescription)")
        result(.success(nil))
        return
      }
      
      guard let queryResult else {
        logger.warning("\(#function) query returned nil without error")
        result(.success(0))
        return
      }

      queryResult.enumerateStatistics(from: startDateStartOfDay, to: endTime) { statistics, stop in
        guard let quantity = statistics.sumQuantity() else {
          result(.success(0))
          return
        }
        let steps = Int(quantity.doubleValue(for: HKUnit.count()))
        result(.success(steps))
      }
    }

    healthStore.execute(query)
  }
}
