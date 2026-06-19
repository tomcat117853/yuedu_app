cmake_minimum_required(VERSION 3.10)
project(yuedu_app LANGUAGES CXX OBJC SWIFT)

set(BINARY_NAME "yuedu_app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "@loader_path/../Frameworks")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_OBJC_STANDARD 17)
set(CMAKE_OBJC_STANDARD_REQUIRED ON)
set(CMAKE_Swift_STANDARD 5)
set(CMAKE_Swift_STANDARD_REQUIRED ON)

add_executable(${BINARY_NAME} MACOSX_BUNDLE
  "MainFlutterWindow.swift"
  "AppDelegate.swift"
  "Bridge.swift"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

apply_standard_settings(${BINARY_NAME})

target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"1.0.0\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=1")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=0")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=0")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=0")

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

add_custom_target(install_bundle
  DEPENDS ${BINARY_NAME}
  COMMAND ${CMAKE_COMMAND} -E copy_directory
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_INSTALL_PREFIX}"
)
