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
      if HKHealthStore.isHealthDataAvailable() == false {
        result(false)
      }
      hasPermissions(call: call, result: result)

    case "checkIfHealthDataAvailable":
      checkIfHealthDataAvailable(call: call, result: result)

    case "requestAuthorization":
      if HKHealthStore.isHealthDataAvailable() == false {
        result(false)
      }
      requestAuthorization(call: call, result: result)

    case "getTotalStepsInInterval":
      if HKHealthStore.isHealthDataAvailable() == false {
        result(nil)
      }
      getTotalStepsInInterval(call: call) { outcome in
        DispatchQueue.main.async {
          switch outcome {
          case .success(let steps):
            result(steps)
          case .failure(let error):
            let error = FlutterError(
              code: "health-steps",
              message: error.localizedDescription,
              details: nil
            )
            result(error)
          }
        }
      }

    case "getData":
      if HKHealthStore.isHealthDataAvailable() == false {
        result([])
      }
      do {
        let input = try GetDataInput(call: call)
        getData(input: input) { completion in
          switch completion {
          case .failure(let error):
            let error = FlutterError(
              code: "health",
              message: error.localizedDescription,
              details: nil
            )
            if Thread.isMainThread {
              result(error)
            } else {
              DispatchQueue.main.async { [error] in
                result(error)
              }
            }

          case .success(let success):
            if Thread.isMainThread {
              result(success)
            } else {
              DispatchQueue.main.async { [success] in
                result(success)
              }
            }
          }
        }
      } catch {
        let error = FlutterError(
          code: "health-input",
          message: error.localizedDescription,
          details: nil
        )
        result(error)
      }

    // MARK: - These must swap back to main for result calls

    case "deleteData":
      if HKHealthStore.isHealthDataAvailable() == false {
        result(false)
      }
      do {
        let input = try DeleteDataInput(call: call)
        healthKitQueue.async { [self] in
          deleteData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed):
                result(didSucceed)
              case .failure(let error):
                let error = FlutterError(
                  code: "health",
                  message: error.localizedDescription,
                  details: nil
                )
                result(error)
              }
            }
          }
        }
      } catch {
        let error = FlutterError(
          code: "health-input",
          message: error.localizedDescription,
          details: nil
        )
        result(error)
      }

    case "deleteFoodData":
      if HKHealthStore.isHealthDataAvailable() == false {
        result(false)
      }
      do {
        let input = try DeleteFoodDataInput(call: call)
        healthKitQueue.async { [self] in
          deleteFoodData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed):
                result(didSucceed)
              case .failure(let error):
                let error = FlutterError(
                  code: "health",
                  message: error.localizedDescription,
                  details: nil
                )
                result(error)
              }
            }
          }
        }
      } catch {
        let error = FlutterError(
          code: "health-input",
          message: error.localizedDescription,
          details: nil
        )
        result(error)
      }

    case "writeFoodData":
      if HKHealthStore.isHealthDataAvailable() == false {
        result(false)
      }
      do {
        let input = try WriteFoodDataInput(call: call)
        healthKitQueue.async { [self] in
          writeFoodData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed):
                result(didSucceed)
              case .failure(let error):
                let error = FlutterError(
                  code: "health",
                  message: error.localizedDescription,
                  details: nil
                )
                result(error)
              }
            }
          }
        }
      } catch {
        let error = FlutterError(
          code: "health-input",
          message: error.localizedDescription,
          details: nil
        )
        result(error)
      }

    case "writeData":
      if HKHealthStore.isHealthDataAvailable() == false {
        result(false)
      }
      do {
        let input = try WriteDataInput(call: call)
        healthKitQueue.async { [self] in
          writeData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed):
                result(didSucceed)
              case .failure(let error):
                let error = FlutterError(
                  code: "health",
                  message: error.localizedDescription,
                  details: nil
                )
                result(error)
              }
            }
          }
        }
      } catch {
        let error = FlutterError(
          code: "health-input",
          message: error.localizedDescription,
          details: nil
        )
        result(error)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
