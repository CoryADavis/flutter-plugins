import Flutter
import Foundation
import HealthKit

public final class SwiftHealthPlugin: NSObject, FlutterPlugin, Sendable {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "flutter_health",
      binaryMessenger: registrar.messenger()
    )
    let instance = SwiftHealthPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    switch call.method {

    case "hasPermissions":
      hasPermissions(call: call, result: result)

    case "checkIfHealthDataAvailable":
      checkIfHealthDataAvailable(call: call, result: result)

    case "requestAuthorization":
      requestAuthorization(call: call, result: result)

    case "getTotalStepsInInterval":
      getTotalStepsInInterval(call: call, result: result)

    case "getData":
      getData(call: call, result: result)

    // MARK: - These must swap back to main for result calls

    case "deleteData":
      healthKitQueue.async { [self] in
        deleteData(call: call, result: result)
      }

    case "deleteFoodData":
      healthKitQueue.async { [self] in
        deleteFoodData(call: call, result: result)
      }

    case "writeFoodData":
      healthKitQueue.async { [self] in
        writeFoodData(call: call, result: result)
      }

    case "writeData":
      healthKitQueue.async { [self] in
        writeData(call: call, result: result)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
