cmake_minimum_required(VERSION 3.18)
project(zero_touch_car_diagnostics)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add the serial device backend subdirectory
# Note: Backend uses serial communication, which may need additional setup for Android NDK
# For now, this is a skeleton that can be expanded as backend dependencies are resolved
add_subdirectory(../../backend serial_device_backend)

# Create native bridge library to interface with serial device backend
add_library(flipper_bridge SHARED
    flipper_bridge.cpp
)

# Link against serial device backend (will need protobuf, serialization libs, etc.)
target_link_libraries(flipper_bridge PRIVATE
    flipper_backend
    log  # Android logging
)

# Include directories for native code
target_include_directories(flipper_bridge PRIVATE
    ${CMAKE_SOURCE_DIR}/../../backend
    ${ANDROID_NDK}/sources/cxx-stl/shared
)
