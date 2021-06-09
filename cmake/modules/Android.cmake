set( ANDROID_MODULE_GRADLE_DIR ${CMAKE_CURRENT_LIST_DIR}/Android/gradle )

find_package( AndroidSDK REQUIRED )
if ( NOT AndroidSDK_FOUND )
    message( FATAL_ERROR "Failed to find AndroidSDK" )
endif()

include( CMakeParseArguments )

function( add_android )
    set( oneValueArgs AAR APK SRC_DIR RES_DIR MANIFEST )
    set( multiValueArgs LIBS NATIVE_LIBS )
    cmake_parse_arguments(
        ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    file( COPY
            ${ANDROID_MODULE_GRADLE_DIR}/gradle
            ${ANDROID_MODULE_GRADLE_DIR}/gradlew
            ${ANDROID_MODULE_GRADLE_DIR}/gradlew.bat
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR} )

    set( SDK_DIR ${AndroidSDK_DIR} )
    if( ARG_AAR )
        set( TARGET ${ARG_AAR} )
        set( ARTIFACT_TYPE library )
        set( ARTIFACT_SUFFIX aar )
        set( ARTIFACT_DIR "${CMAKE_CURRENT_BINARY_DIR}/build/outputs/aar" )
    elseif( ARG_APK )
        set( TARGET ${ARG_APK} )
        set( ARTIFACT_TYPE application )
        set( ARTIFACT_SUFFIX apk )
        set( ARTIFACT_DIR "${CMAKE_CURRENT_BINARY_DIR}/build/outputs/apk" )
    endif()
    set( ARTIFACT "${ARTIFACT_DIR}/${TARGET}.${ARTIFACT_SUFFIX}" )
    set( ARCHIVES_BASE_NAME ${TARGET} )

    if( ARG_MANIFEST )
        get_filename_component( ARG_MANIFEST "${ARG_MANIFEST}" ABSOLUTE )
        set( SOURCE_SETS_MAIN "${SOURCE_SETS_MAIN}
            manifest.srcFile '${ARG_MANIFEST}'" )
    endif()

    if( ARG_SRC_DIR )
        get_filename_component(
            ARG_SRC_DIR "${ARG_SRC_DIR}" ABSOLUTE )
        set( SOURCE_SETS_MAIN "${SOURCE_SETS_MAIN}
            java.srcDirs = [ '${ARG_SRC_DIR}' ]" )
        file( GLOB_RECURSE SOURCE_FILES ${ARG_SRC_DIR}/*.java )
    endif()

    if( ARG_RES_DIR )
        get_filename_component( ARG_RES_DIR "${ARG_RES_DIR}" ABSOLUTE )
        set( SOURCE_SETS_MAIN "${SOURCE_SETS_MAIN}
            res.srcDirs = [ '${ARG_RES_DIR}' ]" )
        file( GLOB_RECURSE RESOURCE_FILES ${ARG_RES_DIR}/*.* )
    endif()

    if( ARG_LIBS )
        set( ANDROID_LIBS "" )
        foreach( lib IN LISTS ARG_LIBS )
            get_target_property( location ${lib} LOCATION )
            get_filename_component( dir "${location}" DIRECTORY )
            get_filename_component( name "${location}" NAME_WE )
            get_filename_component( ext "${location}" EXT )
            string( REGEX MATCH "[^\\.].*" ext ${ext} ) # Remove period
            set( DEPENDENCIES "${DEPENDENCIES}
                compile(name:'${lib}', ext:'aar')" )
            set( REPOSITORIES "${REPOSITORIES}
                dirs '${dir}'")
            list( APPEND DEP_LIBS ${lib} )
        endforeach()
    endif()

    if( ARG_NATIVE_LIBS )
        set( JNI_LIBS_DIR
            ${CMAKE_CURRENT_BINARY_DIR}/build/outputs/libs )
        set( JNI_LIBS_ABI_DIR ${JNI_LIBS_DIR}/${ANDROID_ABI} )
        file( MAKE_DIRECTORY ${JNI_LIBS_ABI_DIR} )
        set( SOURCE_SETS_MAIN "${SOURCE_SETS_MAIN}
            jniLibs.srcDirs = [ '${JNI_LIBS_DIR}' ]" )

        foreach( lib IN LISTS ARG_NATIVE_LIBS )
            set( __dest_lib
                ${JNI_LIBS_ABI_DIR}/$<TARGET_FILE_NAME:${lib}> )
            set( NATIVE_LIBS_COPY_COMMANDS ${NATIVE_LIBS_COPY_COMMANDS}
                COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${lib}>
                    ${JNI_LIBS_ABI_DIR}
                    $<$<CONFIG:Release>:&&>
                    $<$<CONFIG:Release>:${CMAKE_STRIP}>
                    $<$<CONFIG:Release>:-S>
                    $<$<CONFIG:Release>:${__dest_lib}>
            )
        endforeach()
    endif()

    configure_file( ${ANDROID_MODULE_GRADLE_DIR}/build.gradle
        ${CMAKE_CURRENT_BINARY_DIR}/build.gradle @ONLY )
    configure_file( ${ANDROID_MODULE_GRADLE_DIR}/local.properties
        ${CMAKE_CURRENT_BINARY_DIR}/local.properties @ONLY )

    add_custom_command(
        OUTPUT "${ARTIFACT}"
        ${NATIVE_LIBS_COPY_COMMANDS}
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gradlew assemble$<CONFIG>
        DEPENDS
            ${SOURCE_FILES}
            ${RESOURCE_FILES}
            ${ARG_MANIFEST}
            ${DEP_LIBS}
            ${ARG_NATIVE_LIBS}
        COMMENT "Generating ${TARGET}.${ARTIFACT_SUFFIX}"
    )

    add_custom_target( ${TARGET} ALL
        DEPENDS "${ARTIFACT}"
    )

    set_property( TARGET ${TARGET} PROPERTY LOCATION "${ARTIFACT}" )

    if( ARG_APK )
        if( CMAKE_BUILD_TYPE MATCHES Debug )
            add_custom_target(
                ${TARGET}-install
                COMMAND
                    ${CMAKE_CURRENT_BINARY_DIR}/gradlew
                        installDebug -x assembleDebug
                DEPENDS ${TARGET}
            )
        endif()
    endif()
endfunction()
