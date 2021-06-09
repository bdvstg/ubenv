if ( NOT "$ENV{ANDROID_HOME}" STREQUAL "" )
    # Normalize path
    get_filename_component( AndroidSDK_DIR "$ENV{ANDROID_HOME}" ABSOLUTE )
    set( AndroidSDK_FOUND TRUE )
else()
    message( WARNING "ANDROID_HOME environment variable is not defined." )
    set( AndroidSDK_FOUND FALSE )
endif()
