public struct FlutterMethodChannel {
  public let name: String
  public let binaryMessenger: FlutterBinaryMessenger
  public init(name: String, binaryMessenger: FlutterBinaryMessenger) {
    self.name = name
    self.binaryMessenger = binaryMessenger
  }
}
public struct FlutterBinaryMessenger {}
public protocol FlutterPlugin {}
public protocol FlutterPluginRegistrar {
  func messenger() -> FlutterBinaryMessenger
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel)
}
public struct FlutterMethodCall: Sendable {
  public var method: String
  public var arguments: [String: String]?
}
public typealias FlutterResult = (Any?) -> Void
public let FlutterMethodNotImplemented: FlutterResult = { _ in  }
