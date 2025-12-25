//
//  FlipperBackendImpl.mm
//  Objective-C++ implementation of qFlipper backend bridge
//
//  This file provides the C++ to Objective-C++ interface for calling qFlipper native code
//  from Swift/Flutter on iOS.
//

#import <Foundation/Foundation.h>
#include "FlipperBackend-Bridging-Header.h"

// TODO: Include actual qFlipper headers once iOS build system is set up
// #include "../../../qFlipper/backend/serialfinder.h"
// #include "../../../qFlipper/backend/flipperzero/flipperzero.h"

// Global Flipper device instance (stub for now)
static void* g_flipper_instance = nullptr;

#pragma mark - Device Discovery

const char** flipper_get_devices(int* count) {
    NSLog(@"[FlipperBackend] flipper_get_devices() called");
    
    // TODO: Call actual SerialFinder implementation
    // std::vector<std::string> devices = SerialFinder::enumerateDevices();
    
    *count = 0;
    return nullptr;
}

void flipper_free_devices(const char** devices, int count) {
    if (devices) {
        free(devices);
    }
}

#pragma mark - Device Connection

int flipper_connect_device(const char* device_id) {
    NSLog(@"[FlipperBackend] flipper_connect_device(%s) called", device_id);
    
    // TODO: Call actual FlipperZero implementation
    // g_flipper_instance = new FlipperZero(device_id);
    // return g_flipper_instance->connect() ? 0 : -1;
    
    return 0; // Success (stub)
}

int flipper_disconnect_device(void) {
    NSLog(@"[FlipperBackend] flipper_disconnect_device() called");
    
    // TODO: Call actual FlipperZero implementation
    // if (g_flipper_instance) {
    //     delete (FlipperZero*)g_flipper_instance;
    //     g_flipper_instance = nullptr;
    // }
    
    return 0;
}

#pragma mark - Device Info

const char* flipper_get_device_name(void) {
    NSLog(@"[FlipperBackend] flipper_get_device_name() called");
    
    // TODO: Call actual FlipperZero::getDeviceInfo()
    return "Flipper Zero";
}

const char* flipper_get_device_version(void) {
    NSLog(@"[FlipperBackend] flipper_get_device_version() called");
    
    // TODO: Call actual FlipperZero::getDeviceVersion()
    return "0.0.0";
}

const char* flipper_get_device_hardware(void) {
    NSLog(@"[FlipperBackend] flipper_get_device_hardware() called");
    
    // TODO: Call actual FlipperZero::getDeviceHardware()
    return "unknown";
}

#pragma mark - Firmware Operations

int flipper_install_firmware(const char* file_path) {
    NSLog(@"[FlipperBackend] flipper_install_firmware(%s) called", file_path);
    
    // TODO: Call actual FlipperZero::installFirmware(file_path)
    // if (!g_flipper_instance) return -1;
    // try {
    //     ((FlipperZero*)g_flipper_instance)->installFirmware(file_path);
    //     return 0;
    // } catch (const std::exception& e) {
    //     NSLog(@"[FlipperBackend] Firmware install failed: %s", e.what());
    //     return -1;
    // }
    
    return 0; // Success (stub)
}

int flipper_factory_reset(void) {
    NSLog(@"[FlipperBackend] flipper_factory_reset() called");
    
    // TODO: Call actual FlipperZero::factoryReset()
    // if (!g_flipper_instance) return -1;
    // ((FlipperZero*)g_flipper_instance)->factoryReset();
    
    return 0; // Success (stub)
}

#pragma mark - Cleanup

void flipper_backend_cleanup(void) {
    NSLog(@"[FlipperBackend] flipper_backend_cleanup() called");
    
    // TODO: Clean up resources
    // if (g_flipper_instance) {
    //     delete (FlipperZero*)g_flipper_instance;
    //     g_flipper_instance = nullptr;
    // }
}
