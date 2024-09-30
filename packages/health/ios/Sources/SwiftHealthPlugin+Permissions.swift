import Flutter
import HealthKit

extension SwiftHealthPlugin {

  func checkIfHealthDataAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(HKHealthStore.isHealthDataAvailable())
  }

  func hasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let types = arguments["types"] as? Array<String>,
          let permissions = arguments["permissions"] as? Array<Int> else {
      result(PluginError(message: "Invalid arguments"))
      return
    }
    guard types.count == permissions.count else {
      result(PluginError(message: "Types \(types.count) differs from permissions \(permissions.count)"))
      return
    }

    for (type, access) in zip(types, permissions) {
      guard let dataType = HealthDataTypes(rawValue: type)?.sampleType else {
        logger.error("Unrecognized HealthDataType or HKSampleType for \(type) \(access)")
        continue
      }
      let isAuthorized = hasPermission(type: dataType, access: access)
      if isAuthorized == true { continue }
      result(isAuthorized)
      return
    }
    result(true)
  }

  func hasPermission(type: HKSampleType, access: Int) -> Bool? {
    if access == 1 { // Write
      return healthStore.authorizationStatus(for: type) == .sharingAuthorized
    }
    return nil // READ or READ_WRITE
  }

  func requestAuthorization(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? NSDictionary,
          let types = arguments["types"] as? Array<String>,
          let permissions = arguments["permissions"] as? Array<Int>  else {
      result(PluginError(message: "Invalid Arguments"))
      return
    }
    guard types.count == permissions.count else {
      result(PluginError(message: "Types \(types.count) differs from permissions \(permissions.count)"))
      return
    }

    var reads = Set<HKSampleType>()
    var writes = Set<HKSampleType>()

    for (type, access) in zip(types, permissions) {
      guard let dataType = HealthDataTypes(rawValue: type)?.sampleType else {
        logger.error("Unrecognized HealthDataType or HKSampleType for \(type) \(access)")
        continue
      }
      switch access {
      case 0:
        reads.insert(dataType)
      case 1:
        writes.insert(dataType)
      default:
        reads.insert(dataType)
        writes.insert(dataType)
      }
    }

    healthStore.requestAuthorization(toShare: writes, read: reads) { (success, error) in
      DispatchQueue.main.async {
        result(success)
      }
      if let error {
        logger.error("\(#function) \(error.localizedDescription)")
      }
    }
  }
}
