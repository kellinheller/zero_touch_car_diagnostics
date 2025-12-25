#include <jni.h>
#include <string>
#include <vector>
#include <android/log.h>

#define LOG_TAG "FlipperBridge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// TODO: Include serial device headers once CMake is properly set up
// #include "serialdevice/serialdevice.h"
// #include "serialdevice/session.h"

extern "C" {

/**
 * JNI function to get list of connected Flipper devices.
 * Called from: FlipperBackendChannel.kt -> getDevices()
 * 
 * @return jobjectArray of device IDs as strings
 */
JNIEXPORT jobjectArray JNICALL
Java_com_zero_touch_diagnostics_FlipperBackendChannel_getDevices(
    JNIEnv* env,
    jclass clazz)
{
    LOGI("getDevices() called");
    
    // TODO: Replace with actual call to SerialFinder
    // std::vector<std::string> devices = SerialFinder::enumerateDevices();
    
    // For now, return empty array
    jclass stringClass = env->FindClass("java/lang/String");
    jobjectArray result = env->NewObjectArray(0, stringClass, nullptr);
    
    LOGI("getDevices() returning %d devices", 0);
    return result;
}

/**
 * JNI function to connect to a Flipper device.
 * Called from: FlipperBackendChannel.kt -> connectDevice()
 * 
 * @param deviceId the device ID to connect to
 * @return true if connection successful, false otherwise
 */
JNIEXPORT jboolean JNICALL
Java_com_zero_touch_diagnostics_FlipperBackendChannel_connectDevice(
    JNIEnv* env,
    jclass clazz,
    jstring jDeviceId)
{
    const char* deviceId = env->GetStringUTFChars(jDeviceId, nullptr);
    LOGI("connectDevice() called with deviceId: %s", deviceId);
    
    // TODO: Call SerialDevice::connect(deviceId)
    // bool connected = g_device->connect(std::string(deviceId));
    
    env->ReleaseStringUTFChars(jDeviceId, deviceId);
    
    LOGI("connectDevice() returning true (stub)");
    return true;
}

/**
 * JNI function to disconnect from current device.
 * Called from: FlipperBackendChannel.kt -> disconnectDevice()
 */
JNIEXPORT void JNICALL
Java_com_zero_touch_diagnostics_FlipperBackendChannel_disconnectDevice(
    JNIEnv* env,
    jclass clazz)
{
    LOGI("disconnectDevice() called");
    
    // TODO: Call SerialDevice::disconnect()
    // g_device->disconnect();
    
    LOGI("disconnectDevice() completed");
}

/**
 * JNI function to get device information.
 * Called from: FlipperBackendChannel.kt -> getDeviceInfo()
 * 
 * @return Java Map containing device name, version, hardware info
 */
JNIEXPORT jobject JNICALL
Java_com_zero_touch_diagnostics_FlipperBackendChannel_getDeviceInfo(
    JNIEnv* env,
    jclass clazz)
{
    LOGI("getDeviceInfo() called");
    
    // TODO: Call SerialDevice::getDeviceInfo()
    // auto info = g_device->getDeviceInfo();
    
    // Create a HashMap to return device info
    jclass hashMapClass = env->FindClass("java/util/HashMap");
    jmethodID hashMapInit = env->GetMethodID(hashMapClass, "<init>", "()V");
    jobject hashMap = env->NewObject(hashMapClass, hashMapInit);
    
    jmethodID put = env->GetMethodID(hashMapClass, "put",
        "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
    
    // Add stub data
    env->CallObjectMethod(hashMap, put,
        env->NewStringUTF("name"),
        env->NewStringUTF("Serial Device"));
    env->CallObjectMethod(hashMap, put,
        env->NewStringUTF("version"),
        env->NewStringUTF("0.0.0"));
    env->CallObjectMethod(hashMap, put,
        env->NewStringUTF("hardware"),
        env->NewStringUTF("unknown"));
    
    LOGI("getDeviceInfo() returning device map");
    return hashMap;
}

/**
 * JNI function to install firmware.
 * Called from: FlipperBackendChannel.kt -> installFirmware()
 * 
 * @param filePath path to firmware file
 * @throws RuntimeException if install fails
 */
JNIEXPORT void JNICALL
Java_com_zero_touch_diagnostics_FlipperBackendChannel_installFirmware(
    JNIEnv* env,
    jclass clazz,
    jstring jFilePath)
{
    const char* filePath = env->GetStringUTFChars(jFilePath, nullptr);
    LOGI("installFirmware() called with path: %s", filePath);
    
    // TODO: Call SerialDevice::installFirmware(filePath)
    // try {
    //     g_device->installFirmware(std::string(filePath));
    // } catch (const std::exception& e) {
    //     LOGE("installFirmware() failed: %s", e.what());
    //     env->ThrowNew(env->FindClass("java/lang/RuntimeException"), e.what());
    // }
    
    env->ReleaseStringUTFChars(jFilePath, filePath);
    LOGI("installFirmware() completed");
}

/**
 * JNI function to perform factory reset.
 * Called from: FlipperBackendChannel.kt -> factoryReset()
 */
JNIEXPORT void JNICALL
Java_com_zero_touch_diagnostics_FlipperBackendChannel_factoryReset(
    JNIEnv* env,
    jclass clazz)
{
    LOGI("factoryReset() called");
    
    // TODO: Call SerialDevice::factoryReset()
    // g_device->factoryReset();
    
    LOGI("factoryReset() completed");
}

} // extern "C"
