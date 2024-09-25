function(add_sanitizer_flags enable_sanitize_addr enable_sanitize_undef)
    message(STATUS "sanitizer called")
    if (NOT enable_sanitize_addr AND NOT enable_sanitize_undef)
        message(STATUS "Sanitizers deactivated.")
        return()
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        add_compile_options("-fno-omit-frame-pointer")
        add_link_options("-fno-omit-frame-pointer")

        if(enable_sanitize_addr)
            message(STATUS "enable_sanitize_addr added")

            add_compile_options("-fsanitize=address")
            add_link_options("-fsanitize=address")
        endif()

        if(enable_sanitize_undef)
            message(STATUS "enable_sanitize_undef added")

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
