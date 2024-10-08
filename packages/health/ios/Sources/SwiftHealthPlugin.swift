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
      do {
        let input = try GetDataInput(call: call)
        getData(input: input) { completion in
          if Thread.isMainThread {
            switch completion {
            case .failure(let failure): result(failure)
            case .success(let success): result(success)
            }
          } else {
            DispatchQueue.main.async {
              switch completion {
              case .failure(let failure): result(failure)
              case .success(let success): result(success)
              }
            }
          }
        }
      } catch {
        result(error)
      }

    // MARK: - These must swap back to main for result calls

    case "deleteData":
      do {
        let input = try DeleteDataInput(call: call)
        healthKitQueue.async { [self] in
          deleteData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed): result(didSucceed)
              case .failure(let error): result(error)
              }
            }
          }
        }
      } catch {
        result(error)
      }

    case "deleteFoodData":
      do {
        let input = try DeleteFoodDataInput(call: call)
        healthKitQueue.async { [self] in
          deleteFoodData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed): result(didSucceed)
              case .failure(let error): result(error)
              }
            }
          }
        }
      } catch {
        result(error)
      }

    case "writeFoodData":
      do {
        let input = try WriteFoodDataInput(call: call)
        healthKitQueue.async { [self] in
          writeFoodData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed): result(didSucceed)
              case .failure(let error): result(error)
              }
            }
          }
        }
      } catch {
        result(error)
      }

    case "writeData":
      do {
        let input = try WriteDataInput(call: call)
        healthKitQueue.async { [self] in
          writeData(input: input) { outcome in
            DispatchQueue.main.async {
              switch outcome {
              case .success(let didSucceed): result(didSucceed)
              case .failure(let error): result(error)
              }
            }
          }
        }
      } catch {
        result(error)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
