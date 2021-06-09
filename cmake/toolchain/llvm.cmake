include(${CMAKE_CURRENT_LIST_DIR}/prosense.cmake)

if(CMAKE_VERSION VERSION_LESS 3.6)
    include(CMakeForceCompiler)
    CMAKE_FORCE_C_COMPILER(clang GNU)
    CMAKE_FORCE_CXX_COMPILER(clang++ GNU)
endif()

import_toolchain_config()

set_internal_variable(LLVM_TOOLCHAIN_DIR "LLVM toolchain directory")
set_internal_variable(LINARO_TOOLCHAIN_DIR "Linaro toolchain directory")
set_internal_variable(TARGET_ROOTFS_DIR "Target root filesystem")

set(CMAKE_C_COMPILER "${LLVM_TOOLCHAIN_DIR}/bin/clang")
set(CMAKE_CXX_COMPILER "${LLVM_TOOLCHAIN_DIR}/bin/clang++")

set(SYSROOT_FLAG
    "--sysroot=${LINARO_TOOLCHAIN_DIR}/arm-linux-gnueabi/libc/")
set(LIBCXX_INCLUDE_FLAG "-I ${LLVM_TOOLCHAIN_DIR}/include/c++/v1")
set(LLVM_INCLUDE_FLAGS "-I ${LLVM_TOOLCHAIN_DIR}/include")
set(LLVM_FLAGS "${LIBCXX_INCLUDE_FLAG} ${LLVM_INCLUDE_FLAGS}")
set(FUSE_LD_LLD_FLAG "-fuse-ld=${LLVM_TOOLCHAIN_DIR}/bin/ld.lld")
set(GDB_FLAGS "-ggdb -gdwarf-2")

set(LINKER_FLAGS
    "${FUSE_LD_LLD_FLAG}"
    "-B ${LINARO_TOOLCHAIN_DIR}/lib/gcc/arm-linux-gnueabi/4.7.1"
    "-L ${LINARO_TOOLCHAIN_DIR}/lib/gcc/arm-linux-gnueabi/4.7.1"
    "-L ${LINARO_TOOLCHAIN_DIR}/arm-linux-gnueabi/lib"
    "-L ${LLVM_TOOLCHAIN_DIR}/lib"
    "-stdlib=libc++ -lpthread -lrt -ldl -lunwind"
    "-L${TARGET_ROOTFS_DIR}/usr/lib"
    "-Wl,-rpath -Wl,${TARGET_ROOTFS_DIR}/usr/lib"
    "-L${TARGET_ROOTFS_DIR}/lib"
    "-Wl,-rpath -Wl,${TARGET_ROOTFS_DIR}/lib"
    CACHE STRING "Target linker flags")
string(REPLACE ";" " " LINKER_FLAGS "${LINKER_FLAGS}")

set(CMAKE_C_FLAGS "${SYSROOT_FLAG} ${IMX6_FLAGS} ${LLVM_FLAGS}"
    CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "${SYSROOT_FLAG} ${IMX6_FLAGS} ${LLVM_FLAGS}"
    CACHE STRING "C++ flags")
set(CMAKE_C_FLAGS_DEBUG "${GDB_FLAGS}"
    CACHE STRING "C flags for debug version")
set(CMAKE_CXX_FLAGS_DEBUG "${GDB_FLAGS}"
    CACHE STRING "C++ flags for debug version")

set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS}"
    CACHE STRING "Executable linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "${LINKER_FLAGS}"
    CACHE STRING "Shared linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "${LINKER_FLAGS}"
    CACHE STRING "Module linker flags")

set(CMAKE_STRIP "${LINARO_TOOLCHAIN_DIR}/bin/arm-linux-gnueabi-strip"
    CACHE FILEPATH "Strip utility")

set(LLVM TRUE)

export_toolchain_config(
    LLVM_TOOLCHAIN_DIR
    LINARO_TOOLCHAIN_DIR
    TARGET_ROOTFS_DIR
    LINKER_FLAGS
)

macro(install_libomp dest)
    install(
        FILES "${LLVM_TOOLCHAIN_DIR}/lib/libomp.so"
        DESTINATION "${dest}"
    )
endmacro()
