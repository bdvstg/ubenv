if ( WIN32 )
    set( ANDROID_NDK_ROOT "${CMAKE_SOURCE_DIR}/android-ndk/windows" )
elseif ( UNIX )
    set( ANDROID_NDK_ROOT "${CMAKE_SOURCE_DIR}/android-ndk/linux" )
endif()
