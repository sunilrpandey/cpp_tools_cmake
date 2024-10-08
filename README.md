
# CMake Step by Step

## Hello CMake

Let us assume we have just one implementation (.cpp).  The two basic things that is required for any project is 
- CMake Version
- Project detail
```bash
cmake_minimum_required(VERSION 3.16)
project(CppCMakeLearning VERSION 1.0.0 LANGUAGES C CXX)
```
Once header is set add you need to specify if  you want executable or library out of your project
```bash
add_executable(Executable hello_cmake.cpp)
#or
add_library(Library STATIC func_lib.cpp)
```
So here is complete CMakeLists.txt which builds .cpp file with main to executable
```bash
cmake_minimum_required(VERSION 3.16)
project(CppCMakeLearning VERSION 1.0.0 LANGUAGES C CXX)

add_executable(Executable hello_cmake.cpp)
```
### Build and generate executable/library : all or one
Create Build directory, change directory to build and run cmake
```bash
    mkdir build
	cd build 

    cmake -S .. -B .    # Option 1
    cmake ..            # Option 2
    
    #Specify Generator if required
    cmake -S .. -B . -G "Unix Makefiles" # Option 1
    cmake -S .. -B . -G "Visual Studio 16 2019" # Option 1

    cmake .. -G "Unix Makefiles" # Option 2
    cmake .. -G "Visual Studio 16 2019" # Option 2
    
    
    cmake --build . # this will generate all the libraries/Executables in the CMakeLists.txt

    or 
    cmake --build . --target Executable # Executable name 
    cmake --build . --target Library    # library name 
```
If you have already built the cmake project, you can update with 
```bash
    cmake .
```
This will generate executable .exe or lib(.lib/.a).  In unix one can select target as below
```bash
    cd build
    make Executable # builds only Executable 
    make Library # builds only Library
```

### Get the list of generator
It might be required for build generation
```bash
    cmake --help
```
## When Executable depends on a library (or other implementation file) in same directory 
Suppose we have an executable which depends on a library and we have segregated library and executable code in different .h/.cpp
add implementation to my_lib.h/.cpp

```bash
    #create library
    add_library(Library STATIC my_lib.cpp)

    #create executable
    add_executable(Executable main.cpp)

    #but executable depends on library therefore link the library/ies to executable
    target_link_libraries(Executable PUBLIC Library)
```

Sometimes you dont want a separate library file, you can do above in a single line if you dont want library

```bash
    add_executable(Executable 01_move_funcs_to_separate_files.cpp fun_lib.cpp)
```

## When Library code is in a separate folder (e.g. my_lib)
- Create my_lib folder and add add_subdirectory(my_lib) in CMakeLists.txt of current directory
- Go my_lib filder and create another CMakeLists.text file with below content
```bash
    add_library(Library STATIC "fun_lib.cpp")
    target_include_directories(Library PUBLIC "./") # is used for including headers
```
Note: Every sub-diretory needs to have CMakeLists.txt. If a sub directory has just folders no source files.. add list of add_subdirectory(dir_name) to CMakeLists.txt.
Executable will go to directory having file with main func

## When Headers/source files are kept in separate folder (e.g. src/ include/)
If headers/source are in separte folders say include/src folder, CMakeLists.txt from 'include' directory will have 
```bash
    target_include_directories(${LIBRARY_NAME} PUBLIC "./")
```
and  CMakeLists.txt from 'source'' will have 
```bash
    add_library(${LIBRARY_NAME} STATIC "my_lib.cc")

    #if you have executable impl file in same src folder
    add_executable({EXE_NAME} app.cpp)
    target_link_libraries({EXE_NAME} PUBLIC {LIBRARY_NAME})
```

## Add Variables to CMakeLists.txt
You can add project specific variables 
```bash
    set(EXECUTABLE_NAME Executable)
    set(LIBRARY_NAME Library)
```
You are supposed to initialize various pre-defined cpp variables

```bash
    set(CMAKE_CXX_STANDARD          17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS        OFF)
```
## Group Sources/Headers to build
Many a times we have multiple headers/source files in folder and final library or executable wants few or all of these.
```bash
    set(LIB_SRCS
            fun_lib1.cpp
            fun_lib2.cpp)

    set(LIB_HDRS
            fun_lib1.h```

            fun_lib2.h)


    add_library(${LIB_NAME} STATIC ${LIB_SRCS} ${LIB_HDRS})
    target_include_directories(${LIB_NAME} PUBLIC "./")
``` 
## Options in CMakeLists.txt

```bash
    option(COMPILE_EXECUTABLE "Whether to compile the executable" ON) 
```

How we use options:  Options can be used for conditional build
```bash
    option(COMPILE_EXECUTABLE "Whether to compile the executable" OFF)
    if (COMPILE_EXECUTABLE)
        add_subdirectory(app)
    else()
    endif()
```
You can change option by editing CMakeLists.txt or while configuring from build folder
```bash
    cd build
    # cmake -DMY_OPTION=[ON|OFF] ..
```

## How to do automatic clean of build directory (Unix only)
- create MakeFile close to CMakeLists.txt and add below bash command with target
```bash
    prepare:
        rm -rf build
        mkdir build
        cd build
```
and run from command line
```bash
    make prepare
```
## How to build in Release/Debug mode? 
```bash
    cd build
    # -D Works for variable name as well(besides options)
    cmake -DCMAKE_BUILD_TYPE=Release ..
```
Note: To debug, one can change variables/options temporarily in 'CMakeCache.txt'
you can also get these variable/options value by searching "cmake cache" in command pallete(ctrl shift p)

## How to generate automatic headers
create config.h.in (.in means file to be copied somewhere) in 'configured' folder and copy below code in 'CMakeLists.txt'. 
```bash 
    configure_file(
        "config.h.in"
        "${CMAKE_BINARY_DIR}/configured_files/include/config.h" ESCAPE_QUOTES
    )
```
On configuration, config.h.in which has content to be copied and have some text to be replaced will be resulting config.h at 
"build\configured_files\include\config.h"
Please not text between @@ to be replaced based on project detail in CMakeLists.txt
```bash
static constexpr std::int32_t project_version_major{@PROJECT_VERSION_MAJOR@};

#string between @@ to be replaced from config file
```
# How library linking works | PUBLIC/PRIVATE/INTERFACE
Suppose we have threee libraries in CMakeLists.txt
```bash
    add_library(A ...)
    add_library(B ...)
    add_library(C ...)
```
```cmake
add_library(A ...)
add_library(B ...)
add_library(C ...)
```

### PUBLIC

```cmake
target_link_libraries(A PUBLIC B)
target_link_libraries(C PUBLIC A)
```

When A links in B as *PUBLIC*, it says that A uses B in its implementation, and B is also used in A's public API. Hence, C can use B since it is part of the public API of A.

### PRIVATE

```cmake
target_link_libraries(A PRIVATE B)
target_link_libraries(C PRIVATE A)
```

When A links in B as *PRIVATE*, it is saying that A uses B in its
implementation, but B is not used in any part of A's public API. Any code
that makes calls into A would not need to refer directly to anything from
B.

### INTERFACE

```cmake
add_library(D INTERFACE)
target_include_directories(D INTERFACE {CMAKE_CURRENT_SOURCE_DIR}/include)
```

In general, used for header-only libraries.

# What are differnt Library types

A binary file that contains information about code.
A library cannot be executed on its own.
An application utilizes a library.

## Shared Libraries

- Linux: \*.so
- MacOS: \*.dylib
- Windows: \*.dll

Shared libraries reduce the amount of code that is duplicated in each program that makes use of the library, keeping the binaries small.

Shared libraries will however have a small additional cost for the execution.
In general the shared library is in the same directory as the executable.

### Static Libraries

- Linux/MacOS: *.a
- Windows: *.lib

Static libraries increase the overall size of the binary, but it means that you don't need to carry along a copy of the library that is being used.

As the code is connected at compile time there are not any additional run-time loading costs.

# Important CMake Variables for Paths

- CMAKE_SOURCE_DIR
  - Topmost folder (source directory) that contains a CMakeList.txt file.
- PROJECT_SOURCE_DIR
  - Contains the full path to the root of your project source directory.
- CMAKE_CURRENT_SOURCE_DIR
  - The directory where the currently processed CMakeLists.txt is located in.
- CMAKE_CURRENT_LIST_DIR
  - The directory of the listfile currently being processed. (for example a \*.cmake Module)
- CMAKE_MODULE_PATH
  - Tell CMake to search first in directories listed in CMAKE_MODULE_PATH when you use FIND_PACKAGE() or INCLUDE().
- CMAKE_BINARY_DIR
  - The filepath to the build directory

# Things you can set on targets

- target_link_libraries: Other targets; can also pass library names directly
- target_include_directories: Include directories
- target_compile_features: The compiler features you need activated, like cxx_std_11
- target_compile_definitions: Definitions
- target_compile_options: More general compile flags
- target_link_directories: Don’t use, give full paths instead (CMake 3.13+)
- target_link_options: General link flags (CMake 3.13+)
- target_sources: Add source files

# How to show dependencies 
```bash
    cmake .. --graphviz=graph.dot
    dot -Tpng graph.dot -o dependencyGraphImg.png
```
this will save image 

# Use External library using FetchContent
In order to use external library using FetchContent, external library should be cmakable library.
Let me use gtest library our mathproj
- Update CMakeLists.txt 
```bash
    include(FetchContent)

    FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/heads/main.zip
    )


    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
    set(BUILD_GTEST ON CACHE BOOL "" FORCE)

    FetchContent_MakeAvailable(googletest)

    # and somewhere towards end of file add below lines
    # here I am create test_mathproj file/executable to use gtest and mathlib


    enable_testing()

    add_executable(
    test_mathproj
    test_mathproj.cpp
    )
    target_link_libraries(
        test_mathproj
        GTest::gtest_main
        mathlib
    )

    include(GoogleTest)
    gtest_discover_tests(test_mathproj)
```
External libraries are cloned and build under build/_dep

Some of the steps for cmake build can be found on library documentatoin, as in case of gtest one can go refere
https://google.github.io/googletest/quickstart-cmake.html


# How to add doxygen support 

- Update your source files with doxygen comments
```bash
    /**
    * @brief Print Message for librar
    *
    */
```

- Install Doxygen
- Create Doxygen file using below commond
```bash
    doxygen -g 
```
This will create default Doxygen file .. update fields as required specially project related information and input paths and what files to scan.
(Please refer sample_Doxyfile)

You can move this Doxygen file to docs/ for better placement and run 
```bash 
    doxygen 
```
It will create a html folder in docs/. look for index.html, right click and open in default browser to see documentation

## How to automate in CMake
Create a Cmake module Docs.cmake in ./cmake with below content
```cmake
find_package(Doxygen)

if (DOXYGEN_FOUND)
    message("..............Doxygen found...............")
    add_custom_target(docs
        COMMAND ${DOXYGEN_EXECUTABLE}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/docs
        COMMENT "Generating HTML documentation with Doxygen"
    )
endif()
```
and you can use this module in CMakeLists.txt
```cmake
    set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/")
    include(Docs)
```
Now once you build app successfully. One can go to vscode command palette and search for 'Build Target' and run 'docs' target

or run custom target created in Docs.cmake from command line to generate 'html' folder. open index.html in default browser to see your documentation
```cmake 
    cmake --build . --target docs
```
# What are Custom Targets in CMake
A custom target in CMake is a way to define tasks that don’t necessarily produce executables or libraries but can be used to perform additional operations, such as running scripts, generating files, cleaning up directories, or even triggering external processes. Unlike the usual add_executable or add_library, custom targets are more flexible and can depend on other targets, commands, or files.

You can create custom targets using the add_custom_target() function in CMake. This is especially useful when you want to add a target that performs actions outside the normal build process.

A custom target can depends on other as well
```cmake 
# Define a custom target called "cleanup"
add_custom_target(cleanup
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/temp
    COMMENT "Cleaning up temporary files..."
)

# Add the 'cleanup' target as a dependency of 'all'
# This way, it can be executed independently or with 'make all'
add_dependencies(all cleanup)
```
## Custom Targets with File Dependencies
If you want a custom target that only runs when a file changes (a dependency), you can use the DEPENDS keyword.
```cmake 
add_custom_target(run_script
    COMMAND ${CMAKE_COMMAND} -E echo "Running custom script"
    DEPENDS ${CMAKE_SOURCE_DIR}/input.txt
    COMMENT "Executing the script..."
)
```
In this case, the run_script target will be executed when input.txt is modified.

## Differences Between Custom Commands and Custom Targets
- Custom Command (add_custom_command) is used when you need to attach a command to a target (e.g., generate a file during the build process). Custom commands generate files that will be used as dependencies by other targets.

- Custom Target (add_custom_target) is a broader concept used to define new, potentially independent tasks that can be invoked manually or through dependencies.

## Example of Custom Command with Target
```cmake
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/generated_file.txt
    COMMAND ${CMAKE_COMMAND} -E echo "Generating a file..." > ${CMAKE_BINARY_DIR}/generated_file.txt
    COMMENT "Custom command: Generating file..."
)

add_custom_target(generate_file_target
    DEPENDS ${CMAKE_BINARY_DIR}/generated_file.txt
)
```
In this example, the generate_file_target depends on generated_file.txt, which is generated by a custom command.

# Add compiler options : Set warning and warning as errors 

One can write a cmake function in Warning.cmake and add much obvious content like this
```cmake
function(target_set_warnings TARGET ENABLED ENABLED_AS_ERRORS)
    if (NOT ${ENABLED})
        message(STATUS "Hello : Warnings Disabled for: ${TARGET}")
        return()
    endif()

    message(STATUS "Hello : Warnings Enabled for: ${TARGET}")

    set(MSVC_WARNINGS
        /W4
        /permissive-)

    set(CLANG_WARNINGS
        -Wall
        -Wextra
        -Wpedantic)

    set(GCC_WARNINGS
        ${CLANG_WARNINGS})

    # add flags for treating warning as flag
    if(${ENABLED_AS_ERRORS})
        set(MSVC_WARNINGS ${MSVC_WARNINGS} /WX)
        set(CLANG_WARNINGS ${CLANG_WARNINGS} -Werror)
        set(GCC_WARNINGS ${GCC_WARNINGS} -Werror)
    endif()

    # Set warnings flags based on compiler
    if (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        set(WARNINGS ${MSVC_WARNINGS})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(WARNINGS ${CLANG_WARNINGS})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        set(WARNINGS ${GCC_WARNINGS})
    endif()

    target_compile_options(${TARGET} PRIVATE ${WARNINGS})
    
endfunction(target_set_warnings)

```
As it is evident We can set compile options for a target (exe or library)
```cmake
    target_compile_options(${TARGET} PRIVATE ${WARNINGS})
```

..and from target we can call cmake function written in cmake module 
```cmake 
    option(ENABLE_WARNINGS "Enable a Unit Testing" OFF)
    ...
    ....
    if (ENABLE_WARNINGS)
        target_set_warnings(
            ${EXE_NAME}
            ON
            ON
        )
    endif()
```
# Target Compiler opitions
```cmake 
# target_compile_features: The compiler features defines very features such as language, architecture etc you need activated,  like cxx_std_11
target_compile_features(mylib
                        PUBLIC
                        CXX_STD_11)
```

```cmake 
#target_compile_definitions: Definitions of pre-processor macros etc or giving it some values
target_compile_definitions(EXE_NAME 
                            PRIVATE 
                            ADD_DEBUG_PRINT=1
                            DEBUG_ENABLED
                        )
```

```cmake 
# target_compile_options: this is used for appending any most generic options/flag etc
target_compile_options(EXE_NAME PRIVATE -Wall)
```
# Sanitizer
it is used finding probelems at run time
- linter - before compiling
- compiler - during compiling 
- Sanitizer - run time 
Set flag if you want sanitizer to run
```cmake
    option(ENABLE_SANITIZE_ADDR "Enable address sanitizer" ON)
    option(ENABLE_SANITIZE_UNDEF "Enable undefined sanitizer" ON)

    # and call cmake function 
    if(ENABLE_SANITIZE_ADDR OR ENABLE_SANITIZE_UNDEF)
        include(Sanitizer)
        add_sanitizer_flags(ENABLE_SANITIZE_ADDR ENABLE_SANITIZE_UNDEF)
    endif()
```
Write cmake function in sanitizer.cmake 
```cmake
function(add_sanitizer_flags enable_sanitize_addr enable_sanitize_undef)
    if (NOT enable_sanitize_addr AND NOT enable_sanitize_undef)
        message(STATUS "Sanitizers deactivated.")
        return()
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        add_compile_options("-fno-omit-frame-pointer")
        add_link_options("-fno-omit-frame-pointer")

        if(enable_sanitize_addr)
            add_compile_options("-fsanitize=address")
            add_link_options("-fsanitize=address")
        endif()

        if(enable_sanitize_undef)
            add_compile_options("-fsanitize=undefined")
            add_link_options("-fsanitize=undefined")
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        if(enable_sanitize_addr)
            add_compile_options("/fsanitize=address")
        endif()

        if(enable_sanitize_undef)
            message(STATUS "Undefined sanitizer not impl. for MSVC!")
        endif()
    else()
        message(STATUS "Sanitizer not supported in this environment!")
    endif()
endfunction(add_sanitizer_flags)
```
You can create an issue in your file(say main file here) and run the exe to findout issue. array index issue in below example
```cpp
    //sanitizer demo : run the exe to view this issue
    int arr[10];
    arr[100]= 1234;
```
Below run time erro you will see here
```cpp
/07_add_compile_options/07_add_compile_options.cpp:12:12: runtime error: index 100 out of bounds for type 'int [10]'
/07_add_compile_options/07_add_compile_options.cpp:12:13: runtime error: store to address 0x7ffd04c35630 with insufficient space for an object of type 'int'
0x7ffd04c35630: note: pointer points here
 fd 7f 00 00  00 00 00 00 00 00 00 00  ab 71 c3 04 fd 7f 00 00  bb 71 c3 04 fd 7f 00 00  0b 72 c3 04
```

sanitizer options can be found from compiler documentation such as 
https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html

## Generator Expressions

Using generator expressions one can configure the project differently for different build types in multi-configuration generators.
For such generators the project is configured (with running cmake) once, but can be built for several build types after that.
Example of such generators is Visual Studio.

For multiconfiguration generators CMAKE_BUILD_TYPE is not known at configuration stage.
Because of that using if-else switching doesn't work:

```cmake
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options("/W4 /Wx")
elif(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_options("/W4")
endif()
```

But using conditional generator expressions works:

```cmake
add_compile_options(
    $<$<CONFIG:Debug>:/W4 /Wx>
    $<$<CONFIG:Release>:/W4>
)
```

The Visual Studio, XCode and Ninja Multi-Config generators let you have more than one configuration in the same build directory, and thus won't be using the CMAKE_BUILD_TYPE cache variable.
Instead the CMAKE_CONFIGURATION_TYPES cache variable is used and contains the list of configurations to use for this build directory.Generator Expressions
Using generator expressions one can configure the project differently for different build types in multi-configuration generators. For such generators the project is configured (with running cmake) once, but can be built for several build types after that. Example of such generators is Visual Studio.

For multiconfiguration generators CMAKE_BUILD_TYPE is not known at configuration stage. 
__Because of that using if-else switching doesn't work:__
```cmake 
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options("/W4 /Wx")
elif(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_options("/W4")
endif()
```
But using conditional generator expressions works:
```cmake
add_compile_options(
    $<$<CONFIG:Debug>:/W4 /Wx>
    $<$<CONFIG:Release>:/W4>

#this also works
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(EXE_NAME PUBLIC $<$<CONFIG:Debug>:/W4 /Wx>)
elif (CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(EXE_NAME PUBLIC $<$<CONFIG:Debug>:/W4>)
endif()
)
```

## Cross Compilation with Toolchain Files

## ARM 32 Cross

```shell
cmake -B build_arm32 -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/arm32-cross-toolchain.cmake
cmake --build build_arm32 -j8
```

## ARM 32 Native

```shell
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/arm32-native-toolchain.cmake
cmake --build build -j8
```

## x86 64 MingW

```shell
cmake -B build_mingw -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/x86-64-mingw-toolchain.cmake
cmake --build build_mingw -j8
```

## x86 64 Native

```shell
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/x86-64-native-toolchain.cmake
cmake --build build -j8
```
