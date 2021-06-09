find_package(PkgConfig)
pkg_search_module(PC_GSTREAMER gstreamer-0.10 gstreamer-1.0)

set(GSTREAMER_VERSION ${PC_GSTREAMER_VERSION})

if(GSTREAMER_VERSION VERSION_LESS 1.0)
    set(_GST_VER_SFX 0.10)
else()
    set(_GST_VER_SFX 1.0)
endif()

find_path(GST_H_DIR gst/gst.h PATHS
    ${PC_GSTREAMER_INCLUDEDIR}
    ${PC_GSTREAMER_INCLUDE_DIRS}
)

find_path(GSTCONFIG_H_DIR gst/gstconfig.h PATHS
    ${PC_GSTREAMER_INCLUDEDIR}
    ${PC_GSTREAMER_INCLUDE_DIRS}
)

set(GSTREAMER_INCLUDE_DIR
    ${GST_H_DIR}
    ${GSTCONFIG_H_DIR}
)

find_library(GSTREAMER_LIBRARIES NAMES gstreamer-${_GST_VER_SFX} PATHS
    ${PC_GSTREAMER_LIBDIR}
    ${PC_GSTREAMER_LIBRARY_DIRS}
)

foreach(comp ${GStreamer_FIND_COMPONENTS})
    string(TOUPPER ${comp} comp_ucase)
    set(comp_lib_var GSTREAMER_${comp_ucase}_LIBRARY)
    find_library(GSTREAMER_${comp_ucase}_LIBRARY
        NAMES
            gst${comp}-${_GST_VER_SFX}
        PATHS
            ${PC_GSTREAMER_LIBDIR}
            ${PC_GSTREAMER_LIBRARY_DIRS}
    )
    list(APPEND GSTREAMER_LIBRARIES ${${comp_lib_var}})
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GStreamer
    REQUIRED_VARS
        GSTREAMER_LIBRARIES GSTREAMER_INCLUDE_DIR
    VERSION_VAR
        GSTREAMER_VERSION)
mark_as_advanced(
        GSTREAMER_INCLUDE_DIR
        GSTREAMER_LIBRARIES
        GSTREAMER_VERSION)
