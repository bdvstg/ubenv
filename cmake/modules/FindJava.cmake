if ( WIN32 )
    set( JAVA_ROOT "${CMAKE_SOURCE_DIR}/java/windows" )
elseif ( UNIX )
    set( JAVA_ROOT "${CMAKE_SOURCE_DIR}/java/linux" )
endif()
