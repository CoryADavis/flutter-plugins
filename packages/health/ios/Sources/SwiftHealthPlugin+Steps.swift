import Flutter
import HealthKit

extension SwiftHealthPlugin {
  func getTotalStepsInInterval(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? NSDictionary
    let startEpoch = (arguments?["startDate"] as? NSNumber) ?? 0
    let startTime = Date(timeIntervalSince1970: startEpoch.doubleValue / 1000)
    let startDateStartOfDay = Calendar(identifier: .gregorian).startOfDay(for: startTime)
    let endEpoch = (arguments?["endDate"] as? NSNumber) ?? 0
    let endTime = Date(timeIntervalSince1970: endEpoch.doubleValue / 1000)

    guard let sampleType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
      result(PluginError(message: "Failed to create HKQuantityType.stepCount"))
      return
    }

    guard healthStore.authorizationStatus(for: sampleType) == .sharingAuthorized else {
      result(nil)
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
        DispatchQueue.main.async {
          result(nil)
        }
        return
      }
      
      guard let queryResult else {
        logger.warning("\(#function) query returned nil without error")
        DispatchQueue.main.async {
          result(0)
        }
        return
      }

      queryResult.enumerateStatistics(from: startDateStartOfDay, to: endTime) { statistics, stop in
        guard let quantity = statistics.sumQuantity() else {
          DispatchQueue.main.async {
            result(0)
          }
          return
        }
        let steps = quantity.doubleValue(for: HKUnit.count())
        DispatchQueue.main.async {
          result(Int(steps))
        }
      }
    }

    healthStore.execute(query)
  }
}
