# File:         FindWpkgBuild.cmake
# Object:       Provide functions to build projects.
#
# Copyright:    Copyright (c) 2011-2014 Made to Order Software Corp.
#               All Rights Reserved.
#
# http://windowspackager.org
# contact@m2osw.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# If you have included Wpkg's Third Party package, then this module will
# point to that instead of trying to locate it on the system.
#
include( CMakeParseArguments )

set( ECHO_CMD "" CACHE STRING "Debug echo command" )
mark_as_advanced( ECHO_CMD )

set_property( GLOBAL PROPERTY USE_FOLDERS ON )

if( NOT MSVC )
	find_program( MAKE_SOURCE_SCRIPT WpkgBuildMakeSourcePackage.sh PATHS ${CMAKE_MODULE_PATH} )
	find_program( MAKE_DPUT_SCRIPT   WpkgBuildDputPackage.sh       PATHS ${CMAKE_MODULE_PATH} )
	find_program( INC_DEPS_SCRIPT    WpkgBuildIncDeps.pl           PATHS ${CMAKE_MODULE_PATH} )
	find_program( PBUILDER_SCRIPT    WpkgPBuilder.sh			   PATHS ${CMAKE_MODULE_PATH} )
endif()

function( unigw_ParseVersion PREFIX VERSION )
    unset( VERSION_LIST )
    string( FIND "${VERSION}" "." PERIOD )
    if( ${PERIOD} EQUAL -1 )
        message( FATAL_ERROR "${PREFIX} version be of the form x.y.z!" )
    endif()
    while( ${PERIOD} GREATER -1 )
        string( SUBSTRING "${VERSION}" 0 ${PERIOD} REV )
        list( APPEND VERSION_LIST ${REV} )
        math( EXPR AFTER_PERIOD "${PERIOD}+1" )
        string( SUBSTRING "${VERSION}" ${AFTER_PERIOD} -1 VERSION_ )
        set( VERSION ${VERSION_} )
        string( FIND "${VERSION}" "." PERIOD )
        if( ${PERIOD} EQUAL -1 )
            list( APPEND VERSION_LIST "${VERSION}" )
        endif()
    endwhile()
    #
	list( LENGTH VERSION_LIST LEN )
	if( NOT ${LEN} EQUAL 3 )
        message( FATAL_ERROR "${PREFIX} version be of the form x.y.z!" )
    endif()
    list( GET VERSION_LIST 0 VERSION_MAJOR )
    list( GET VERSION_LIST 1 VERSION_MINOR )
    list( GET VERSION_LIST 2 VERSION_PATCH )
    set( ${PREFIX}_VERSION_MAJOR ${VERSION_MAJOR} PARENT_SCOPE )
    set( ${PREFIX}_VERSION_MINOR ${VERSION_MINOR} PARENT_SCOPE )
    set( ${PREFIX}_VERSION_PATCH ${VERSION_PATCH} PARENT_SCOPE )
endfunction()

function( unigw_ConfigureMakeProject )
	set( options        USE_CONFIGURE_SCRIPT NOINC_DEBVERS )
	set( oneValueArgs   PROJECT_NAME VERSION DISTFILE_PATH BUILD_TYPE )
	set( multiValueArgs CONFIG_ARGS DEPENDS )
	cmake_parse_arguments( ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	#
	if( NOT ARG_PROJECT_NAME )
		message( FATAL_ERROR "unigw_ConfigureMakeProject(): You must specify PROJECT_NAME!" )
	endif()

	if( NOT ARG_BUILD_TYPE )
		message( FATAL_ERROR "unigw_ConfigureMakeProject(): BUILD_TYPE required!" )
	endif()

	set( FULL_PROJECT_NAME "${ARG_PROJECT_NAME}-${ARG_BUILD_TYPE}" )

	if( ARG_VERSION )
		set( SRC_DIR   ${CMAKE_BINARY_DIR}/${ARG_PROJECT_NAME}-${ARG_VERSION}                                    )
		set( BUILD_DIR ${CMAKE_BINARY_DIR}/${FULL_PROJECT_NAME}-${ARG_VERSION}/${FULL_PROJECT_NAME}-${ARG_VERSION} )
	else()
		set( SRC_DIR   ${CMAKE_SOURCE_DIR}/${ARG_PROJECT_NAME} )
		set( BUILD_DIR ${CMAKE_BINARY_DIR}/${FULL_PROJECT_NAME} )
	endif()
    set( WPKG_ROOT "${CMAKE_BINARY_DIR}/dist" CACHE PATH "Destination installation folder." )
	if( ARG_DISTFILE_PATH )
		set( RM_DIR ${SRC_DIR}   )
		else()
		set( RM_DIR ${BUILD_DIR} )
	endif()

	if( NOT EXISTS ${SRC_DIR} AND NOT ARG_DISTFILE_PATH )
		message( FATAL_ERROR "unigw_ConfigureMakeProject(): No source directory '${SRC_DIR}'!" )
	endif()

	if( NOT EXISTS ${SRC_DIR} AND ARG_DISTFILE_PATH )
		message( STATUS "Unpacking ${FULL_PROJECT_NAME} source distribution file into local build area." )
		file( MAKE_DIRECTORY ${SRC_DIR} )
		execute_process(
			COMMAND ${ECHO_CMD} ${CMAKE_COMMAND} -E tar xzf ${ARG_DISTFILE_PATH}
			WORKING_DIRECTORY ${SRC_DIR}
		)
		execute_process(
			COMMAND ${ECHO_CMD} chmod a+x ${BUILD_DIR}/configure
			WORKING_DIRECTORY ${BUILD_DIR}
		)
	endif()

	if( NOT EXISTS ${BUILD_DIR} )
		file( MAKE_DIRECTORY ${BUILD_DIR} )
	endif()

	add_custom_target( ${FULL_PROJECT_NAME}-depends DEPENDS ${ARG_DEPENDS} )
	set_property( TARGET ${FULL_PROJECT_NAME}-depends PROPERTY FOLDER ${FULL_PROJECT_NAME} )

	if( ARG_USE_CONFIGURE_SCRIPT )
		set( CONFIGURE_TARGETS ${BUILD_DIR}/config.log  )
		add_custom_command(
			OUTPUT ${CONFIGURE_TARGETS}
            COMMAND ${ECHO_CMD} ${BUILD_DIR}/configure --prefix=${WPKG_ROOT} ${ARG_CONFIG_ARGS}
				1> ${BUILD_DIR}/${FULL_PROJECT_NAME}_configure.log
				2> ${BUILD_DIR}/${FULL_PROJECT_NAME}_configure.err
			DEPENDS ${FULL_PROJECT_NAME}-depends
			WORKING_DIRECTORY ${BUILD_DIR}
			COMMENT "Running ${FULL_PROJECT_NAME} configure script..."
			)
	else()
		unset( TOOLCHAIN )
		if( CMAKE_TOOLCHAIN_FILE )
			set( TOOLCHAIN "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}" )
		endif()
		set( COMMAND_LIST
			${CMAKE_COMMAND}
                -DCMAKE_INSTALL_PREFIX:PATH=${WPKG_ROOT}
                -DCMAKE_MODULE_PATH:PATH=${CMAKE_SOURCE_DIR}/cmake;${WPKG_ROOT}/share/cmake-2.8/Modules
				-DCMAKE_BUILD_TYPE=${ARG_BUILD_TYPE}
                -DWPKG_ROOT:PATH="${WPKG_ROOT}"
				-G "${CMAKE_GENERATOR}"
				${TOOLCHAIN}
				${ARG_CONFIG_ARGS}
				${SRC_DIR}
	    )
		set( CMD_FILE ${BUILD_DIR}/${FULL_PROJECT_NAME}_configure.cmd )
		file( REMOVE ${CMD_FILE} )
		foreach( line ${COMMAND_LIST} )
			file( APPEND ${CMD_FILE} ${line} "\n" )
		endforeach()
		#
		set( CONFIGURE_TARGETS ${BUILD_DIR}/CMakeCache.txt  )
		add_custom_command(
			OUTPUT ${CONFIGURE_TARGETS}
			COMMAND ${ECHO_CMD} ${COMMAND_LIST}
				1> ${BUILD_DIR}/${FULL_PROJECT_NAME}_configure.log
				2> ${BUILD_DIR}/${FULL_PROJECT_NAME}_configure.err
			DEPENDS ${FULL_PROJECT_NAME}-depends
			WORKING_DIRECTORY ${BUILD_DIR}
			COMMENT "Running ${FULL_PROJECT_NAME} CMake configuration..."
			)
	endif()

	if( MSVC )
		if( NOT (${CMAKE_MAKE_PROGRAM} STREQUAL "nmake") AND NOT (${CMAKE_MAKE_PROGRAM} STREQUAL "jom") )
			message( FATAL_ERROR "unigw_ConfigureMakeProject(): Please use nmake/jom at this level. This won't work right trying to use devenv." )
		endif()
	endif()

	set( BUILD_CMD   ${CMAKE_BUILD_TOOL} )

	add_custom_target(
		${FULL_PROJECT_NAME}-make
		COMMAND ${ECHO_CMD} ${BUILD_CMD}
			# 1> ${BUILD_DIR}/${FULL_PROJECT_NAME}_make.log
			# 2> ${BUILD_DIR}/${FULL_PROJECT_NAME}_make.err
		DEPENDS ${CONFIGURE_TARGETS}
		WORKING_DIRECTORY ${BUILD_DIR}
		COMMENT "Building ${FULL_PROJECT_NAME}"
		)
	set_property( TARGET ${FULL_PROJECT_NAME}-make PROPERTY FOLDER ${FULL_PROJECT_NAME} )

	add_custom_target(
		${FULL_PROJECT_NAME}-package
		COMMAND ${ECHO_CMD} ${BUILD_CMD} build_packages
			# 1>> ${BUILD_DIR}/${FULL_PROJECT_NAME}_make.log
			# 2>> ${BUILD_DIR}/${FULL_PROJECT_NAME}_make.err
		DEPENDS ${FULL_PROJECT_NAME}-make
		WORKING_DIRECTORY ${BUILD_DIR}
		COMMENT "Packaging ${FULL_PROJECT_NAME}"
		)
	set_property( TARGET ${FULL_PROJECT_NAME}-package PROPERTY FOLDER ${FULL_PROJECT_NAME} )

	if( UNIX )
		# RDB: Thu Jun 26 13:45:46 PDT 2014
		# Adding "debuild" target.
		#
		set( DEBUILD_PLATFORM "trusty"                         CACHE STRING "Name of the Debian/Ubuntu platform to build against." )
		set( DEBUILD_EMAIL    "Build Server <build@m2osw.com>" CACHE STRING "Email address of the package signer."                 )
		set( EMAIL_ADDY ${DEBUILD_EMAIL} )
		separate_arguments( EMAIL_ADDY )
		#
		unset( PBUILDER_DEPS )
		unset( DPUT_DEPS     )
		if( ARG_DEPENDS )
			foreach( DEP ${ARG_DEPENDS} )
				list( APPEND PBUILDER_DEPS ${DEP}-pbuilder )
				list( APPEND DPUT_DEPS     ${DEP}-dput     )
			endforeach()
			add_custom_target(
				${FULL_PROJECT_NAME}-incdeps
				COMMAND ${INC_DEPS_SCRIPT} ${CMAKE_SOURCE_DIR} ${FULL_PROJECT_NAME} ${ARG_DEPENDS}
				WORKING_DIRECTORY ${SRC_DIR}
				COMMENT "Incrementing dependencies for debian package ${FULL_PROJECT_NAME}"
				)
		else()
			add_custom_target( ${FULL_PROJECT_NAME}-incdeps )
		endif()
		unset( NOINC_DEBVERS )
		if( ARG_NOINC_DEBVERS )
			set( NOINC_DEBVERS "--noinc" )
		endif()
		add_custom_target(
			${FULL_PROJECT_NAME}-debuild
			COMMAND env DEBEMAIL="${EMAIL_ADDY}" ${MAKE_SOURCE_SCRIPT} ${NOINC_DEBVERS} ${DEBUILD_PLATFORM}
				1> ${BUILD_DIR}/${FULL_PROJECT_NAME}_debuild.log
			WORKING_DIRECTORY ${SRC_DIR}
			DEPENDS ${FULL_PROJECT_NAME}-incdeps
			COMMENT "Building debian source package for ${FULL_PROJECT_NAME}"
			)
		add_custom_target(
			${FULL_PROJECT_NAME}-dput
			COMMAND ${MAKE_DPUT_SCRIPT}
				1> ${BUILD_DIR}/${FULL_PROJECT_NAME}_dput.log
			DEPENDS ${DPUT_DEPS}
			WORKING_DIRECTORY ${SRC_DIR}
			COMMENT "Dputting debian package ${FULL_PROJECT_NAME} to launchpad."
			)
		add_custom_target(
			${FULL_PROJECT_NAME}-pbuilder
			COMMAND ${PBUILDER_SCRIPT} ${DEBUILD_PLATFORM} 
				1> ${BUILD_DIR}/${FULL_PROJECT_NAME}_pbuilder.log
			DEPENDS ${PBUILDER_DEPS}
			WORKING_DIRECTORY ${SRC_DIR}
			COMMENT "Building debian package ${FULL_PROJECT_NAME} with pbuilder-dist."
			)
	endif()

	add_custom_target(
		${FULL_PROJECT_NAME}-clean
		COMMAND rm -rf ${RM_DIR}
		)
	set_property( TARGET ${FULL_PROJECT_NAME}-clean PROPERTY FOLDER ${FULL_PROJECT_NAME} )

	add_custom_target(
		${FULL_PROJECT_NAME}
		DEPENDS ${FULL_PROJECT_NAME}-package
		)
	set_property( TARGET ${FULL_PROJECT_NAME} PROPERTY FOLDER ${FULL_PROJECT_NAME} )

	set_property( GLOBAL APPEND PROPERTY BUILD_TARGETS    ${FULL_PROJECT_NAME}          )
	set_property( GLOBAL APPEND PROPERTY CLEAN_TARGETS    ${FULL_PROJECT_NAME}-clean    )
	if( NOT MSVC )
		set_property( GLOBAL APPEND PROPERTY PACKAGE_TARGETS  ${FULL_PROJECT_NAME}-debuild  )
		set_property( GLOBAL APPEND PROPERTY DPUT_TARGETS     ${FULL_PROJECT_NAME}-dput     )
		set_property( GLOBAL APPEND PROPERTY PBUILDER_TARGETS ${FULL_PROJECT_NAME}-pbuilder )
	endif()
endfunction()

# vim: ts=4 sw=4 noexpandtab
