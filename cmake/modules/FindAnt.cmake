if ( WIN32 )
    set( ANT_CMD_SFX .bat )
endif()

set( ANT_CMD "${CMAKE_SOURCE_DIR}/ant/bin/ant${ANT_CMD_SFX}" )
