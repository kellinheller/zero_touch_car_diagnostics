import Flutter

class FlipperBackendChannel {
    static func setup(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "com.zero_touch/flipper_backend",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getDevices":
                // TODO: Call native C++ via bridging header
                // let devices = flipper_get_devices()
                result([])
                
            case "connectDevice":
                guard let args = call.arguments as? [String: Any],
                      let deviceId = args["deviceId"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS",
                                       message: "deviceId is required",
                                       details: nil))
                    return
                }
                // TODO: Call native C++ via bridging header
                // let success = flipper_connect_device(deviceId)
                result(true)
                
            case "disconnectDevice":
                // TODO: Call native C++ via bridging header
                // flipper_disconnect_device()
                result(nil)
                
            case "getDeviceInfo":
                // TODO: Call native C++ via bridging header
                // let info = flipper_get_device_info()
                let stubInfo: [String: Any] = [
                    "name": "Flipper Zero",
                    "version": "0.0.0",
                    "hardware": "unknown"
                ]
                result(stubInfo)
                
            case "installFirmware":
                guard let args = call.arguments as? [String: Any],
                      let filePath = args["path"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS",
                                       message: "path is required",
                                       details: nil))
                    return
                }
                do {
                    // TODO: Call native C++ via bridging header
                    // try flipper_install_firmware(filePath)
                    result(nil)
                } catch {
                    result(FlutterError(code: "INSTALL_FAILED",
                                       message: error.localizedDescription,
                                       details: nil))
                }
                
            case "factoryReset":
                // TODO: Call native C++ via bridging header
                // flipper_factory_reset()
                result(nil)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
