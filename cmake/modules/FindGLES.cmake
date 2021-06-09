include(FindPackageHandleStandardArgs)

if(WIN32)
    find_path(GLES_INCLUDE_DIR "GLES2/gl2.h")

    add_library(GLESv2 STATIC IMPORTED)
    find_library(GLES_LIBRARY_DEBUG libGLESv2d)
    find_library(GLES_LIBRARY_RELEASE libGLESv2)
    set_target_properties(GLESv2 PROPERTIES
        IMPORTED_LOCATION_DEBUG "${GLES_LIBRARY_DEBUG}"
        IMPORTED_LOCATION_RELEASE "${GLES_LIBRARY_RELEASE}"
        INTERFACE_COMPILE_DEFINITIONS "GL_GLEXT_PROTOTYPES"
    )
    set(GLES_LIBRARY GLESv2)

    find_package_handle_standard_args(GLES
        REQUIRED_VARS
            GLES_INCLUDE_DIR
            GLES_LIBRARY_DEBUG
            GLES_LIBRARY_RELEASE)
elseif(UNIX)
    find_path(GLES_INCLUDE_DIR "GLES2/gl2.h")
    find_library(GLES_LIBRARY GLESv2)
    find_package_handle_standard_args(GLES
        REQUIRED_VARS
            GLES_LIBRARY
            GLES_INCLUDE_DIR)
endif()
