cmake_minimum_required(VERSION 3.16)
project(CppCMakeLearning VERSION 1.0.0 LANGUAGES C CXX)

set(LIB_NAME
        "func_lib")

set(EXE_NAME
        "06_add_doxygen_support")

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/")
include(Docs)

add_executable(${EXE_NAME} 06_add_doxygen_support.cpp)
target_link_libraries(${EXE_NAME} PUBLIC ${LIB_NAME})

add_subdirectory(libs)
