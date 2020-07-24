#
# Definitions for automatically building the atom_types files, given
# a master file "atom_types.script" that defines all of the type
# relationships.
# Macro example call:
# OPENCOG_ADD_ATOM_TYPES(
#        SCRIPT_FILE
#        HEADER_FILE
#        DEFINITIONS_FILE
#        INHERITANCE_FILE
#        SCM_FILE
#        PYTHON_FILE)
#
IF (NOT SCRIPT_FILE)
    MESSAGE(FATAL_ERROR "OPENCOG_ADD_ATOM_TYPES missing SCRIPT_FILE")
ENDIF (NOT SCRIPT_FILE)

IF (NOT HEADER_FILE)
    MESSAGE(FATAL_ERROR "OPENCOG_ADD_ATOM_TYPES missing HEADER_FILE")
ENDIF (NOT HEADER_FILE)

IF (NOT DEFINITIONS_FILE)
    MESSAGE(FATAL_ERROR "OPENCOG_ADD_ATOM_TYPES missing DEFINITIONS_FILE")
ENDIF (NOT DEFINITIONS_FILE)

IF (NOT INHERITANCE_FILE)
    MESSAGE(FATAL_ERROR "OPENCOG_ADD_ATOM_TYPES missing INHERITANCE_FILE")
ENDIF (NOT INHERITANCE_FILE)

IF (NOT SCM_FILE)
    MESSAGE(FATAL_ERROR "OPENCOG_ADD_ATOM_TYPES missing SCM_FILE")
ENDIF (NOT SCM_FILE)

IF (NOT PYTHON_FILE)
    MESSAGE(FATAL_ERROR "OPENCOG_ADD_ATOM_TYPES missing PYTHON_FILE")
ENDIF (NOT PYTHON_FILE)

SET(TMPHDR_FILE ${CMAKE_BINARY_DIR}/tmp_types.h)
SET(CNAMES_FILE ${CMAKE_BINARY_DIR}/atom_names.h)

SET(CLASSSERVER_REFERENCE "opencog::nameserver().")
SET(CLASSSERVER_INSTANCE "opencog::nameserver()")

SET(PYTHON_SUPPORTED_VALUE_LIST)

FILE(WRITE "${TMPHDR_FILE}" "/* File automatically generated by the macro OPENCOG_ADD_ATOM_TYPES. Do not edit */\n")
FILE(APPEND "${TMPHDR_FILE}"  "#include <opencog/atoms/atom_types/types.h>\nnamespace opencog\n{\n")
FILE(WRITE "${DEFINITIONS_FILE}"  "/* File automatically generated by the macro OPENCOG_ADD_ATOM_TYPES. Do not edit */\n#include <opencog/atoms/atom_types/NameServer.h>\n#include <opencog/atoms/atom_types/atom_types.h>\n#include <opencog/atoms/atom_types/types.h>\n#include \"${HEADER_FILE}\"\n")
FILE(WRITE "${INHERITANCE_FILE}"  "/* File automatically generated by the macro OPENCOG_ADD_ATOM_TYPES. Do not edit */\n\n")

# We need to touch the class-server before doing anything.
# This is in order to guarantee that the main atomspace types
# get created before other derived types.
#
# There's still a potentially nasty bug here: if some third types.script
# file depends on types defined in a second file, but the third initializer
# runs before the second, then any atoms in that third file that inherit
# from the second will get a type of zero.  This will crash code later on.
# The only fix for this is to make sure that the third script forces the
# initailzers for the second one to run first. Hopefully, the programmer
# will figure this out, before the bug shows up. :-)
FILE(APPEND "${INHERITANCE_FILE}" "/* Touch the server before adding types. */\n")
FILE(APPEND "${INHERITANCE_FILE}" "${CLASSSERVER_INSTANCE};\n")

FILE(WRITE "${CNAMES_FILE}" "/* File automatically generated by the macro OPENCOG_ADD_ATOM_TYPES. Do not edit */\n")
FILE(APPEND "${CNAMES_FILE}" "#include <opencog/atoms/atom_types/atom_types.h>\n")
FILE(APPEND "${CNAMES_FILE}" "#include <opencog/atoms/base/Handle.h>\n")
FILE(APPEND "${CNAMES_FILE}" "#include <opencog/atoms/base/Node.h>\n")
FILE(APPEND "${CNAMES_FILE}" "#include <opencog/atoms/base/Link.h>\n\n")
FILE(APPEND "${CNAMES_FILE}" "namespace opencog {\n\n")
FILE(APPEND "${CNAMES_FILE}" "#define NODE_CTOR(FUN,TYP) inline Handle FUN(std::string name) { return createNode(TYP, std::move(name)); }\n\n")
FILE(APPEND "${CNAMES_FILE}" "#define LINK_CTOR(FUN,TYP) template<typename ...Atoms> inline Handle FUN(Atoms const&... atoms) { return createLink(TYP, atoms...); }\n\n")

FILE(WRITE "${SCM_FILE}" "\n")
FILE(APPEND "${SCM_FILE}" "; DO NOT EDIT THIS FILE! This file was automatically\n")
FILE(APPEND "${SCM_FILE}" "; generated from atom definitions in types.script\n")
FILE(APPEND "${SCM_FILE}" "; by the macro OPENCOG_ADD_ATOM_TYPES\n")
FILE(APPEND "${SCM_FILE}" ";\n")
FILE(APPEND "${SCM_FILE}" "; This file contains basic scheme wrappers for atom creation.\n")
FILE(APPEND "${SCM_FILE}" ";\n")
FILE(APPEND "${SCM_FILE}" "(define-module (opencog))\n")

FILE(WRITE "${PYTHON_FILE}" "\n")
FILE(APPEND "${PYTHON_FILE}" "# DO NOT EDIT THIS FILE! This file was automatically generated from atom\n")
FILE(APPEND "${PYTHON_FILE}" "# definitions in types.script by the macro OPENCOG_ADD_ATOM_TYPES\n")
FILE(APPEND "${PYTHON_FILE}" "#\n")
FILE(APPEND "${PYTHON_FILE}" "# This file contains basic python wrappers for atom creation.\n")
FILE(APPEND "${PYTHON_FILE}" "#\n")
FILE(APPEND "${PYTHON_FILE}" "\n")

FILE(STRINGS "${SCRIPT_FILE}" TYPE_SCRIPT_CONTENTS)
FOREACH (LINE ${TYPE_SCRIPT_CONTENTS})
    # this regular expression is more complex than required due to cmake's
    # regex engine bugs
    STRING(REGEX MATCH "^[ 	]*([A-Z_]+)?([ 	]*<-[ 	]*([A-Z_, 	]+))?[ 	]*(\"[A-Za-z]*\")?[ 	]*(//.*)?[ 	]*$" MATCHED "${LINE}")
    IF (MATCHED AND CMAKE_MATCH_1)
        SET(TYPE ${CMAKE_MATCH_1})
        SET(PARENT_TYPES ${CMAKE_MATCH_3})
        SET(TYPE_NAME "")
        IF (CMAKE_MATCH_4)
            MESSAGE(STATUS "Custom atom type name specified: ${CMAKE_MATCH_4}")
            STRING(REGEX MATCHALL "." CHARS ${CMAKE_MATCH_4})
            LIST(LENGTH CHARS LIST_LENGTH)
            MATH(EXPR LAST_INDEX "${LIST_LENGTH} - 1")
            FOREACH(I RANGE ${LAST_INDEX})
                LIST(GET CHARS ${I} C)
                IF (NOT ${C} STREQUAL "\"")
                    SET(TYPE_NAME "${TYPE_NAME}${C}")
                ENDIF (NOT ${C} STREQUAL "\"")
            ENDFOREACH(I RANGE ${LIST_LENGTH})
        ENDIF (CMAKE_MATCH_4)

        IF (NOT "${TYPE}" STREQUAL "NOTYPE")
            FILE(APPEND "${TMPHDR_FILE}" "extern opencog::Type ${TYPE};\n")
            FILE(APPEND "${DEFINITIONS_FILE}"  "opencog::Type opencog::${TYPE};\n")
        ELSE (NOT "${TYPE}" STREQUAL "NOTYPE")
            FILE(APPEND "${TMPHDR_FILE}"  "#ifndef _OPENCOG_NOTYPE_\n#define _OPENCOG_NOTYPE_\n")
            FILE(APPEND "${TMPHDR_FILE}"  "// Set notype's code with the last possible Type code\n")
            FILE(APPEND "${TMPHDR_FILE}"  "static const opencog::Type ${TYPE}=((Type) -1);\n")
            FILE(APPEND "${TMPHDR_FILE}"  "#endif // _OPENCOG_NOTYPE_\n")
        ENDIF (NOT "${TYPE}" STREQUAL "NOTYPE")

        IF (TYPE_NAME STREQUAL "")
            # Set type name using camel casing
            STRING(REGEX MATCHALL "." CHARS ${TYPE})
            LIST(LENGTH CHARS LIST_LENGTH)
            MATH(EXPR LAST_INDEX "${LIST_LENGTH} - 1")
            FOREACH(I RANGE ${LAST_INDEX})
                LIST(GET CHARS ${I} C)
                IF (NOT ${C} STREQUAL "_")
                    MATH(EXPR IP "${I} - 1")
                    LIST(GET CHARS ${IP} CP)
                    IF (${I} EQUAL 0)
                        SET(TYPE_NAME "${TYPE_NAME}${C}")
                    ELSE (${I} EQUAL 0)
                        IF (${CP} STREQUAL "_")
                            SET(TYPE_NAME "${TYPE_NAME}${C}")
                        ELSE (${CP} STREQUAL "_")
                            STRING(TOLOWER "${C}" CL)
                            SET(TYPE_NAME "${TYPE_NAME}${CL}")
                        ENDIF (${CP} STREQUAL "_")
                    ENDIF (${I} EQUAL 0)
                ENDIF (NOT ${C} STREQUAL "_")
            ENDFOREACH(I RANGE ${LIST_LENGTH})
        ENDIF (TYPE_NAME STREQUAL "")

        STRING(REGEX REPLACE "([a-zA-Z]*)(Link|Node)$" "\\1" SHORT_NAME ${TYPE_NAME})
        MESSAGE(STATUS "Atom type name: ${TYPE_NAME} ${SHORT_NAME}")

        # Try to guess if the thing is a node or link based on its name
        STRING(REGEX MATCH "VALUE$" ISVALUE ${TYPE})
        STRING(REGEX MATCH "STREAM$" ISSTREAM ${TYPE})
        STRING(REGEX MATCH "NODE$" ISNODE ${TYPE})
        STRING(REGEX MATCH "LINK$" ISLINK ${TYPE})

        # If not explicitly named, assume its a link. This is kind of
        # hacky, but is needed for e.g. "VariableList" ...
        IF (NOT ISNODE STREQUAL "NODE"
            AND NOT ISVALUE STREQUAL "VALUE"
            AND NOT ISSTREAM STREQUAL "STREAM")
            SET(ISLINK "LINK")
        ENDIF (NOT ISNODE STREQUAL "NODE"
            AND NOT ISVALUE STREQUAL "VALUE"
            AND NOT ISSTREAM STREQUAL "STREAM")

        IF (${TYPE} STREQUAL "VALUATION")
            SET(ISLINK "")
        ENDIF (${TYPE} STREQUAL "VALUATION")

        # Print out the C++ definitions
        IF (ISNODE STREQUAL "NODE" AND
            NOT SHORT_NAME STREQUAL "" AND
            NOT SHORT_NAME STREQUAL "Type")
            FILE(APPEND "${CNAMES_FILE}" "NODE_CTOR(${SHORT_NAME}, ${TYPE})\n")
        ENDIF ()
        IF (ISLINK STREQUAL "LINK" AND
            NOT SHORT_NAME STREQUAL "" AND
            NOT SHORT_NAME STREQUAL "Atom" AND
            NOT SHORT_NAME STREQUAL "Notype" AND
            NOT SHORT_NAME STREQUAL "Type" AND
            NOT SHORT_NAME STREQUAL "TypeSet" AND
            NOT SHORT_NAME STREQUAL "Arity")
            FILE(APPEND "${CNAMES_FILE}" "LINK_CTOR(${SHORT_NAME}, ${TYPE})\n")
        ENDIF ()
        # Special case...
        IF (ISNODE STREQUAL "NODE" AND
            SHORT_NAME STREQUAL "Type")
            FILE(APPEND "${CNAMES_FILE}" "NODE_CTOR(TypeNode, ${TYPE})\n")
        ENDIF ()
        IF (ISLINK STREQUAL "LINK" AND
            SHORT_NAME STREQUAL "Type")
            FILE(APPEND "${CNAMES_FILE}" "LINK_CTOR(TypeLink, ${TYPE})\n")
        ENDIF ()
        IF (ISLINK STREQUAL "LINK" AND
            SHORT_NAME STREQUAL "TypeSet")
            FILE(APPEND "${CNAMES_FILE}" "LINK_CTOR(TypeIntersection, ${TYPE})\n")
        ENDIF ()
        IF (ISLINK STREQUAL "LINK" AND
            SHORT_NAME STREQUAL "Arity")
            FILE(APPEND "${CNAMES_FILE}" "LINK_CTOR(ArityLink, ${TYPE})\n")
        ENDIF ()

        # Print out the scheme definitions
        FILE(APPEND "${SCM_FILE}" "(define-public ${TYPE_NAME}Type (cog-type->int '${TYPE_NAME}))\n")
        IF (ISVALUE STREQUAL "VALUE" OR ISSTREAM STREQUAL "STREAM")
            FILE(APPEND "${SCM_FILE}" "(define-public (${TYPE_NAME} . x)\n")
            FILE(APPEND "${SCM_FILE}" "\t(apply cog-new-value (cons ${TYPE_NAME}Type x)))\n")
        ENDIF (ISVALUE STREQUAL "VALUE" OR ISSTREAM STREQUAL "STREAM")
        IF (ISNODE STREQUAL "NODE")
            FILE(APPEND "${SCM_FILE}" "(define-public (${TYPE_NAME} . x)\n")
            FILE(APPEND "${SCM_FILE}" "\t(apply cog-new-node (cons ${TYPE_NAME}Type x)))\n")
            IF (NOT SHORT_NAME STREQUAL "")
                FILE(APPEND "${SCM_FILE}" "(define-public (${SHORT_NAME} . x)\n")
                FILE(APPEND "${SCM_FILE}" "\t(apply cog-new-node (cons ${TYPE_NAME}Type x)))\n")
            ENDIF (NOT SHORT_NAME STREQUAL "")
        ENDIF (ISNODE STREQUAL "NODE")
        IF (ISLINK STREQUAL "LINK")
            FILE(APPEND "${SCM_FILE}" "(define-public (${TYPE_NAME} . x)\n")
            FILE(APPEND "${SCM_FILE}" "\t(apply cog-new-link (cons ${TYPE_NAME}Type x)))\n")
            IF (NOT SHORT_NAME STREQUAL "")
                FILE(APPEND "${SCM_FILE}" "(define-public (${SHORT_NAME} . x)\n")
                FILE(APPEND "${SCM_FILE}" "\t(apply cog-new-link (cons ${TYPE_NAME}Type x)))\n")
            ENDIF (NOT SHORT_NAME STREQUAL "")
        ENDIF (ISLINK STREQUAL "LINK")

        # Print out the python definitions. Note: We special-case Atom
        # since we don't want to create a function with the same
        # identifier as the Python Atom object.
        IF (NOT TYPE_NAME STREQUAL "Atom")
            IF (ISVALUE STREQUAL "VALUE" OR ISSTREAM STREQUAL "STREAM")
                LIST(FIND PYTHON_SUPPORTED_VALUE_LIST ${TYPE_NAME} _INDEX)
                IF (${_INDEX} GREATER -1)
                    # Single arg will work as all of value constructors has
                    # single argument: either value or vector.
                    FILE(APPEND "${PYTHON_FILE}" "def ${TYPE_NAME}(arg):\n")
                    FILE(APPEND "${PYTHON_FILE}" "    return createValue(types.${TYPE_NAME}, arg)\n")
                ENDIF (${_INDEX} GREATER -1)
            ENDIF (ISVALUE STREQUAL "VALUE" OR ISSTREAM STREQUAL "STREAM")
            IF (ISNODE STREQUAL "NODE")
                FILE(APPEND "${PYTHON_FILE}" "def ${TYPE_NAME}(node_name, tv=None):\n")
                FILE(APPEND "${PYTHON_FILE}" "    return add_node(types.${TYPE_NAME}, node_name, tv)\n")
            ENDIF (ISNODE STREQUAL "NODE")
            IF (ISLINK STREQUAL "LINK")
                FILE(APPEND "${PYTHON_FILE}" "def ${TYPE_NAME}(*args, tv=None):\n")
                FILE(APPEND "${PYTHON_FILE}" "    return add_link(types.${TYPE_NAME}, args, tv=tv)\n")
            ENDIF (ISLINK STREQUAL "LINK")
        ENDIF (NOT TYPE_NAME STREQUAL "Atom")

        # If not named as a node or a link, assume its a link
        # This is kind of hacky, but I don't know what else to do ...
        IF (NOT ISNODE STREQUAL "NODE" AND
            NOT ISLINK STREQUAL "LINK" AND
            NOT ISVALUE STREQUAL "VALUE" AND
            NOT ISSTREAM STREQUAL "STREAM")
            FILE(APPEND "${PYTHON_FILE}" "def ${TYPE_NAME}(*args):\n")
            FILE(APPEND "${PYTHON_FILE}" "    return add_link(types.${TYPE_NAME}, args)\n")
        ENDIF (NOT ISNODE STREQUAL "NODE" AND
            NOT ISLINK STREQUAL "LINK" AND
            NOT ISVALUE STREQUAL "VALUE" AND
            NOT ISSTREAM STREQUAL "STREAM")

        IF (PARENT_TYPES)
            STRING(REGEX REPLACE "[ 	]*,[ 	]*" ";" PARENT_TYPES "${PARENT_TYPES}")
            FOREACH (PARENT_TYPE ${PARENT_TYPES})
                # skip inheritance of the special "notype" class; we could move
                # this test up but it was left here for simplicity's sake
                IF (NOT "${TYPE}" STREQUAL "NOTYPE")
                    FILE(APPEND "${INHERITANCE_FILE}" "opencog::${TYPE} = ${CLASSSERVER_REFERENCE}declType(opencog::${PARENT_TYPE}, \"${TYPE_NAME}\");\n")
                ENDIF (NOT "${TYPE}" STREQUAL "NOTYPE")
            ENDFOREACH (PARENT_TYPE)
        ELSE (PARENT_TYPES)
            IF (NOT "${TYPE}" STREQUAL "NOTYPE")
                FILE(APPEND "${INHERITANCE_FILE}" "opencog::${TYPE} = ${CLASSSERVER_REFERENCE}declType(opencog::${TYPE}, \"${TYPE_NAME}\");\n")
            ENDIF (NOT "${TYPE}" STREQUAL "NOTYPE")
        ENDIF (PARENT_TYPES)
    ELSE (MATCHED AND CMAKE_MATCH_1)
        IF (NOT MATCHED)
            FILE(REMOVE "${TMPHDR_FILE}")
            FILE(REMOVE "${DEFINITIONS_FILE}")
            FILE(REMOVE "${INHERITANCE_FILE}")
            MESSAGE(FATAL_ERROR "Invalid line in ${SCRIPT_FILE} file: [${LINE}]")
        ENDIF (NOT MATCHED)
    ENDIF (MATCHED AND CMAKE_MATCH_1)
ENDFOREACH (LINE)
FILE(APPEND "${TMPHDR_FILE}" "} // namespace opencog\n")

FILE(APPEND "${CNAMES_FILE}" "#undef NODE_CTOR\n")
FILE(APPEND "${CNAMES_FILE}" "#undef LINK_CTOR\n")
FILE(APPEND "${CNAMES_FILE}" "} // namespace opencog\n")

# Must be last, so that all writing has completed *before* the
# file appears in the filesystem. Without this, parallel-make
# will sometimes use an incompletely-written file.
FILE(RENAME "${TMPHDR_FILE}" "${HEADER_FILE}")
