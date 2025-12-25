import Flutter
import UIKit
import CoreBluetooth

public class ObdPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zero_touch.obd", binaryMessenger: registrar.messenger())
    let instance = ObdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Minimal stub: full CoreBluetooth implementation requires pairing and BLE-specific code.
    switch call.method {
    case "connect":
      result(FlutterError(code: "unimplemented", message: "iOS OBD connect not implemented. Implement CoreBluetooth scanning and connection for your adapter.", details: nil))
    case "disconnect":
      result(FlutterError(code: "unimplemented", message: "iOS OBD disconnect not implemented.", details: nil))
    case "sendCommand":
      result(FlutterError(code: "unimplemented", message: "iOS OBD sendCommand not implemented.", details: nil))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
