import Flutter
import HealthKit

extension SwiftHealthPlugin {
  func getTotalStepsInInterval(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? NSDictionary
    let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
    let endDate = (arguments?["endDate"] as? NSNumber) ?? 0

    guard let sampleType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
      result(PluginError(message: "Failed to create HKQuantityType.stepCount"))
      return
    }

    guard healthStore.authorizationStatus(for: sampleType) == .sharingAuthorized else {
      result(nil)
      return
    }

    let query = HKStatisticsQuery(
      quantityType: sampleType,
      quantitySamplePredicate: HKQuery.predicateForSamples(
        withStart: Date(timeIntervalSince1970: startDate.doubleValue / 1000),
        end: Date(timeIntervalSince1970: endDate.doubleValue / 1000),
        options: .strictStartDate
      ),
      options: .cumulativeSum
    ) { query, queryResult, error in

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
          result(nil)
        }
        return
      }

      let steps = queryResult.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
      DispatchQueue.main.async {
        result(Int(steps))
      }
    }

    healthStore.execute(query)
  }
}
