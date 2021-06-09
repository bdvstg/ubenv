include(CMakeParseArguments)
find_package(Git)

function(avm_utils_get_tag output_variable)
    cmake_parse_arguments(ARG "" "MATCH" "" ${ARGN})
    execute_process(
        COMMAND ${GIT_EXECUTABLE}
            describe --tags --match "${ARG_MATCH}" --dirty
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE git_result
        OUTPUT_VARIABLE git_output
    )
    if(NOT git_result STREQUAL "0")
        message(WARNING "Failed to retrieve tag")
    endif()
    string(STRIP "${git_output}" tag)
    set(${output_variable} ${tag} PARENT_SCOPE)
endfunction()
