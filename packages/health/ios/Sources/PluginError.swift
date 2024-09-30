import Foundation

struct PluginError: LocalizedError {
  let message: String
  var errorDescription: String? { message }
}
