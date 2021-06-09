project(uboot-env)
cmake_minimum_required(VERSION 3.0)

#list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

add_compile_options(-std=c++11)


set(SOURCES
    main.cpp
    crc32.cpp
    uboot_args.cpp
    )

set(HEADERS
    crc32.h
    uboot_args.h
    )

add_executable(ubenv
    ${SOURCES}
    ${HEADERS}
    )

#target_link_libraries(ubenv xxx)

install(TARGETS ubenv DESTINATION bin)
