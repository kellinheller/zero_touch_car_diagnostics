cmake_minimum_required(VERSION 3.18)
project(zero_touch_car_diagnostics)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Note: This project focuses on OBD-II diagnostics via ELM327 and USB serial adapters
# C++ backend for serial device communication is no longer needed
# All functionality is implemented in Flutter + native Android/iOS channels
