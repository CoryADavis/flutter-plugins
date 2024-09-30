import HealthKit
import OSLog

let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier ?? "com.flutter.healthplugin",
  category: "flutter_health"
)

let healthStore = HKHealthStore()

let healthKitQueue = DispatchQueue(
  label: "com.flutter.healthplugin",
  qos: .userInitiated,
  attributes: .concurrent
)
