# Copyright (C) 2016 OpenCog Foundation

# References:
# https://www.gnu.org/software/guile/manual/guile.html#Modules-and-the-File-System
# https://www.gnu.org/software/guile/manual/guile.html#Creating-Guile-Modules
# https://www.gnu.org/software/guile/manual/guile.html#Installing-Site-Packages

# Definitions:
#
# * MODULE_FILE: The name of the file that defines the module. It has
#   the same name as the directory it is in, or the name of the parent
#   directory of current directory if it is in a folder named 'scm'.
#   In addition this file shoule have a define-module expression
#   for it be importable, as per guile's specification. See reference
#   links above.

# By default Guile return the path to its installation location.
# Such path will not work for users who wants to compile and install
# the project with a custom CMAKE_INSTALL_PREFIX. Compiling with
# custom PREFIX is a common practice. To support custom PREFIX
# this condition is added to override GUILE_SITE_DIR value using
# `cmake -DGUILE_SITE_DIR=...`.
IF (NOT DEFINED GUILE_SITE_DIR)
    IF(HAVE_GUILE)
        EXECUTE_PROCESS(COMMAND guile -c "(display (%site-dir))"
            OUTPUT_VARIABLE GUILE_SITE_DIR
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    ENDIF()
ENDIF()
ADD_DEFINITIONS(-DGUILE_SITE_DIR="${GUILE_SITE_DIR}")

# ----------------------------------------------------------------------------
# This configures the install and binary paths for each file, passed to it,
# based on the value of the variables MODULE_NAME, MODULE_FILE_DIR_PATH and
# MODULE_DIR_PATH in the PARENT_SCOPE.
FUNCTION(PROCESS_MODULE_STRUCTURE FILE_NAME DIR_PATH)
    SET(GUILE_BIN_DIR "${CMAKE_BINARY_DIR}/opencog/scm")

    # Copy files into build directory mirroring the install path structure,
    # and also set the install path.
    IF ("${MODULE_NAME}.scm" STREQUAL "${FILE_NAME}")
        EXECUTE_PROCESS(
            COMMAND ${CMAKE_COMMAND} -E make_directory ${GUILE_BIN_DIR}/${MODULE_FILE_DIR_PATH}
        )
        ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy "${DIR_PATH}/${FILE_NAME}" "${GUILE_BIN_DIR}/${MODULE_FILE_DIR_PATH}/${FILE_NAME}"
        )
        SET(FILE_INSTALL_PATH "${GUILE_SITE_DIR}/${MODULE_FILE_DIR_PATH}"
            PARENT_SCOPE
        )
    ELSE()
        EXECUTE_PROCESS(
            COMMAND ${CMAKE_COMMAND} -E make_directory ${GUILE_BIN_DIR}/${MODULE_DIR_PATH}
        )
        ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy "${DIR_PATH}/${FILE_NAME}" "${GUILE_BIN_DIR}/${MODULE_DIR_PATH}/${FILE_NAME}"
        )
        SET(FILE_INSTALL_PATH "${GUILE_SITE_DIR}/${MODULE_DIR_PATH}"
            PARENT_SCOPE
        )
    ENDIF()
ENDFUNCTION(PROCESS_MODULE_STRUCTURE)

# ----------------------------------------------------------------------------
# When building, all files specifed are are copied to
# '${CMAKE_BINARY_DIR}/opencog/scm' following the file tree structure created
# when installing to /usr/local/share/opencog/scm. It has three keyword arguments
#
# FILES: List of files to be installed/copied
#
# MODULE_DESTINATION: The absolute path where the files associated
#   with the module are installed, with the exception of the
#   MODULE_FILE(see definition at top of this file). The path for
#   MODULE_FILE, is inferred from this argument, even if it is the only file to
#   be installed.
#
# DEPENDS: The name of a target that generates a scheme file that is to be
# installed. This is an optional argument only required for generated files.
FUNCTION(ADD_GUILE_MODULE)
  # Define the target that will be used to copy scheme files in the current
  # source directory to the build directory. This is done so as to be able to
  # run scheme unit-tests without having to run 'make install'.
  STRING(REPLACE "/" "_" _TARGET_NAME_SUFFIX ${CMAKE_CURRENT_SOURCE_DIR})
  SET(TARGET_NAME "COPY_TO_LOAD_PATH_IN_BUILD_DIR_FROM_${_TARGET_NAME_SUFFIX}")
  IF (NOT (TARGET ${TARGET_NAME}))
    ADD_CUSTOM_TARGET(${TARGET_NAME} ALL)
  ENDIF()

  IF(HAVE_GUILE)
    SET(PREFIX_DIR_PATH "${GUILE_SITE_DIR}")
    SET(options "")  # This is used only as a place-holder
    SET(oneValueArgs MODULE_DESTINATION)
    SET(multiValueArgs FILES DEPENDS)
    CMAKE_PARSE_ARGUMENTS(SCM "${options}" "${oneValueArgs}"
        "${multiValueArgs}" ${ARGN})
    # NOTE:  The keyword arguments 'FILES' and 'MODULE_DESTINATION' are
    # required.
    IF((DEFINED SCM_FILES) AND (DEFINED SCM_MODULE_DESTINATION))
        # FILE_PATH is used for variable name because files in
        # sub-directories may be passed.
        FOREACH(FILE_PATH ${SCM_FILES})
            GET_PROPERTY(FILE_GENERATED SOURCE ${FILE_PATH} PROPERTY GENERATED SET)
            GET_FILENAME_COMPONENT(DIR_PATH ${FILE_PATH} DIRECTORY)
            GET_FILENAME_COMPONENT(FILE_NAME ${FILE_PATH} NAME)

            # Check if the file exists or is generated, and set FULL_DIR_PATH
            # or target dependencies.
            IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${DIR_PATH}/${FILE_NAME})
                SET(FULL_DIR_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${DIR_PATH}/)
            ELSEIF(EXISTS /${DIR_PATH}/${FILE_NAME})
                SET(FULL_DIR_PATH /${DIR_PATH}/)
            ELSEIF(FILE_GENERATED AND (NOT SCM_DEPENDS))
                MESSAGE(FATAL_ERROR "The target that generates ${FILE_PATH} "
                    "has not been added as a dependency using the keyword "
                    "argument 'DEPENDS'")
            ELSEIF(FILE_GENERATED AND SCM_DEPENDS)
                ADD_DEPENDENCIES(${TARGET_NAME} ${SCM_DEPENDS})
                SET(FULL_DIR_PATH /${DIR_PATH}/)
            ELSE()
                MESSAGE(FATAL_ERROR "${FILE_PATH} file does not exist in "
                    "${CMAKE_CURRENT_SOURCE_DIR} nor does it have "
                    "'GENERATED' property")
            ENDIF()

            # Specify module paths.
            STRING(REGEX MATCH
                "^(${PREFIX_DIR_PATH})([_a-z0-9/-]+)*/([_a-z0-9-]+)" ""
                ${SCM_MODULE_DESTINATION})

            # MODULE_NAME: it is equal to the MODULE_DESTINATION directory name
            # MODULE_FILE_DIR_PATH: the directory path where the MODULE_FILE is
            #   installed.
            # MODULE_DIR_PATH: the directory path where the files associated
            #   with the module are installed at and copied to, with the exception
            #   of the MODULE_FILE.
            SET(MODULE_NAME ${CMAKE_MATCH_3})
            SET(MODULE_FILE_DIR_PATH ${CMAKE_MATCH_2})
            SET(MODULE_DIR_PATH ${CMAKE_MATCH_2}/${CMAKE_MATCH_3})
            PROCESS_MODULE_STRUCTURE(${FILE_NAME} ${FULL_DIR_PATH})

            # NOTE: The install configuration isn't part of
            # PROCESS_MODULE_STRUCTURE function so as to avoid "Command
            # INSTALL() is not scriptable" error, when using it in copying
            # scheme files during code-generation by the OPENCOG_ADD_ATOM_TYPES
            # macro.
            INSTALL (FILES
                ${FILE_PATH}
                DESTINATION ${FILE_INSTALL_PATH}
            )
        ENDFOREACH()
    ELSE()
        IF(NOT DEFINED SCM_FILES)
            MESSAGE(FATAL_ERROR "The keyword argument 'FILES' is not set")
        ENDIF()

        IF(NOT DEFINED SCM_MODULE_DESTINATION)
            MESSAGE(FATAL_ERROR "The keyword argument 'MODULE_DESTINATION' "
                "is not set")
        ENDIF()
    ENDIF()
  ENDIF()
ENDFUNCTION(ADD_GUILE_MODULE)

FUNCTION(ADD_GUILE_TEST TEST_NAME FILE_NAME)
    # srfi-64 is installed in guile 2.2 and above, thus check for it.
    IF(HAVE_GUILE AND (GUILE_VERSION VERSION_GREATER 2.2))
        SET(FILE_PATH  "${CMAKE_CURRENT_SOURCE_DIR}/${FILE_NAME}")
        # Check if the file exists in the current source directory.
        IF(NOT EXISTS ${FILE_PATH})
            MESSAGE(FATAL_ERROR "${FILE_NAME} file does not exist in "
                ${CMAKE_CURRENT_SOURCE_DIR})
        ENDIF()

        ADD_TEST(NAME ${TEST_NAME}
            COMMAND guile -L ${PROJECT_BINARY_DIR}/opencog/scm
                      --use-srfi=64 ${FILE_PATH}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

    ENDIF()
ENDFUNCTION(ADD_GUILE_TEST)
