include(ExternalProject)


# Define variables
set(GENDC_SEPERATOR_NAME "gendc_separator")
set(GENDC_SEPERATOR_ACTION "download") # You can set this to a specific action or leave it empty

# Call the Python script and capture its output
execute_process(
    COMMAND ${Python_EXECUTABLE} ${CONFIG_PARSER_PATH} --name ${GENDC_SEPERATOR_NAME} --action ${GENDC_SEPERATOR_ACTION} --config-path ${CONFIG_PATH}
    OUTPUT_VARIABLE OUTPUT_VALUE
    RESULTS_VARIABLE  RESULT_CODE
    ERROR_VARIABLE error
)


if(RESULT_CODE)
    message(FATAL_ERROR "Error while parsing config: ${OUTPUT_VALUE}")
endif()

#Split the output into a list
string(REPLACE "\n" ";" OUTPUT_LIST ${OUTPUT_VALUE})

# Set the variables
list(GET OUTPUT_LIST 0 GENDC_SEPERATOR_NAME)
list(GET OUTPUT_LIST 3 GENDC_SEPERATOR_ACTION)
list(GET OUTPUT_LIST 7 GENDC_SEPERATOR_VERSION)


# Print to verify
message("GENDC_SEPERATOR_NAME  ${GENDC_SEPERATOR_NAME}")
message("GENDC_SEPERATOR_ACTION : ${GENDC_SEPERATOR_ACTION}")
message("GENDC_SEPERATOR_VERSION: ${GENDC_SEPERATOR_VERSION}")



set(GENDC_SEPERATOR_OS_FILE gendc_seperator-${GENDC_SEPERATOR_VERSION})
set(GENDC_SEPERATOR_DIR ${CMAKE_BINARY_DIR}/external/gendc_seperator/src/${GENDC_SEPERATOR_OS_FILE})

if(GENDC_SEPERATOR_ACTION STREQUAL "build")

    list(GET OUTPUT_LIST 1 GENDC_SEPERATOR_SOURCE)
    list(GET OUTPUT_LIST 2 GENDC_SEPERATOR_INSTALL)
    list(GET OUTPUT_LIST 6 GENDC_SEPERATOR_GIT_REPO)

    message("GENDC_SEPERATOR_SOURCE : ${GENDC_SEPERATOR_SOURCE}")
    message("GENDC_SEPERATOR_INSTALL: ${GENDC_SEPERATOR_INSTALL}")
    message("GENDC_SEPERATOR_PKG_URL: ${GENDC_SEPERATOR_PKG_URL}")

    message(FATAL_ERROR "Option Unimplemented")
elseif(GENDC_SEPERATOR_ACTION STREQUAL "download")
    # Add gendc_seperator external project
    list(GET OUTPUT_LIST 4 GENDC_SEPERATOR_PKG_URL)
    list(GET OUTPUT_LIST 5 GENDC_SEPERATOR_PKG_SHA)
    
    message("GENDC_SEPERATOR_PKG_SHA : ${GENDC_SEPERATOR_PKG_SHA}")
    message("GENDC_SEPERATOR_GIT_REPO: ${GENDC_SEPERATOR_GIT_REPO}")
    
    ExternalProject_Add(
        gendc_seperator_external
        PREFIX ${CMAKE_BINARY_DIR}/external/gendc_seperator
        URL ${GENDC_SEPERATOR_PKG_URL}
        URL_HASH SHA256=${GENDC_SEPERATOR_PKG_SHA}  # Use SHA-256 hash
        DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/external/gendc_seperator/downloads  # Specify a downloads directory
        SOURCE_DIR ${GENDC_SEPERATOR_DIR}
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        CONFIGURE_COMMAND ""  # No configure step needed
        BUILD_COMMAND ""  # No build step needed
        INSTALL_COMMAND  ""
        # COMMAND powershell -Command "Expand-Archive -Path '<DOWNLOAD_DIR>/${GENDC_SEPERATOR_OS_FILE}.zip' -DestinationPath '${CMAKE_SOURCE_DIR}/external/gendc_seperator' -Force"
        BUILD_IN_SOURCE FALSE
        BUILD_ALWAYS FALSE  # Adjust this according to your needs
    )    
elseif(GENDC_SEPERATOR_ACTION STREQUAL "use_existing")
    message(FATAL_ERROR "Option Unimplemented")
else()
    message(FATAL_ERROR "Incorrect action option. Valid values are build, download and use_existing")
endif()

# Add gendc_seperator external project


# Specify the gendc_seperator library and include directories
add_library(gendc_seperator INTERFACE)
add_dependencies(gendc_seperator gendc_seperator_external )
target_include_directories(gendc_seperator INTERFACE ${GENDC_SEPERATOR_DIR})

# Install gendc_seperator library, binaries, includes, and shared files
# install(DIRECTORY ${CMAKE_SOURCE_DIR}/external/gendc_seperator/${GENDC_SEPERATOR_OS_FILE}/ DESTINATION install)
install(DIRECTORY ${GENDC_SEPERATOR_DIR}/ DESTINATION include)

