#ifndef FlipperBackend_Bridging_Header_h
#define FlipperBackend_Bridging_Header_h

// Include qFlipper backend C++ headers
// These will be properly configured once CMake/Xcode build system is set up

// TODO: Uncomment and verify paths once qFlipper is compiled for iOS
// #include "../../../qFlipper/backend/serialfinder.h"
// #include "../../../qFlipper/backend/flipperzero/flipperzero.h"
// #include "../../../qFlipper/backend/flipperzero/protobufsession.h"
// #include "../../../qFlipper/backend/flipperzero/deviceinfo.h"

// Forward declare C++ functions to be implemented in Objective-C++
#ifdef __cplusplus
extern "C" {
#endif

// Device discovery
const char** flipper_get_devices(int* count);
void flipper_free_devices(const char** devices, int count);

// Device connection
int flipper_connect_device(const char* device_id);
int flipper_disconnect_device(void);

// Device info
const char* flipper_get_device_name(void);
const char* flipper_get_device_version(void);
const char* flipper_get_device_hardware(void);

// Firmware operations
int flipper_install_firmware(const char* file_path);
int flipper_factory_reset(void);

// Cleanup
void flipper_backend_cleanup(void);

#ifdef __cplusplus
}
#endif

#endif /* FlipperBackend_Bridging_Header_h */
