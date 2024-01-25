include(FetchContent)

set(CONFIG_PATH "${CMAKE_SOURCE_DIR}/config.yml")
set(CONFIG_PARSER_PATH "${CMAKE_SOURCE_DIR}/scripts/parse_config.py")

message("CONFIG_PATH : ${CONFIG_PATH}")
message("CONFIG_PARSER_PATH : ${CONFIG_PARSER_PATH}")

set(THIRPARTY_NOTICE_FILE "${CMAKE_BINARY_DIR}/license/thirdparty_notice.txt")
file(WRITE ${THIRPARTY_NOTICE_FILE} "\n--------\n")
message(STATUS "THIRPARTY_NOTICE_FILE ${THIRPARTY_NOTICE_FILE}")

# Find a Python interpreter
find_package(Python REQUIRED)

# Print the path of the found Python interpreter
message(STATUS "Using Python: ${Python_EXECUTABLE}")

add_subdirectory(ion-kit)
add_subdirectory(opencv)
add_subdirectory(aravis)
add_subdirectory(pygobject)

