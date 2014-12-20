#
# File:
#      CMakeLists.txt
#
# Description:
#      Definitions to create wpkg packages from the binary
#
# Documentation:
#      See the CMake documentation.
#
# License:
#      Copyright (c) 2013 Made to Order Software Corp.
#
#      https://sourceforge.net/projects/unigw/
#      contact@m2osw.com
#
#      Permission is hereby granted, free of charge, to any person obtaining a
#      copy of this software and associated documentation files (the
#      "Software"), to deal in the Software without restriction, including
#      without limitation the rights to use, copy, modify, merge, publish,
#      distribute, sublicense, and/or sell copies of the Software, and to
#      permit persons to whom the Software is furnished to do so, subject to
#      the following conditions:
#
#      The above copyright notice and this permission notice shall be included
#      in all copies or substantial portions of the Software.
#
#      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#      OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#      MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#      IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#      CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#      TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#      SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

## This project builds the pkg-explorer package based on component.

set( DEBVERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}-${VERSION_DEVEL}" )
set( WPKG_ROOT "${CMAKE_BINARY_DIR}/WPKG" )
set( COMPONENT_LIST runtime )
if( UNIX )
    set( INSTALL_PREFIX "/usr" )
else()
    set( INSTALL_PREFIX "" )
endif()
foreach( _comp ${COMPONENT_LIST} )
    configure_file( control.${_comp}.in "${WPKG_ROOT}/${_comp}/WPKG/control" @ONLY )
    add_custom_target( ${_comp}_install
            COMMAND ${CMAKE_COMMAND}
                        -DCMAKE_INSTALL_PREFIX="${WPKG_ROOT}/${_comp}${INSTALL_PREFIX}"
                        -DCMAKE_INSTALL_COMPONENT=${_comp}
                        -DCMAKE_INSTALL_DO_STRIP=1
                        -P ${CMAKE_BINARY_DIR}/cmake_install.cmake
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )
    add_custom_target( ${_comp}
            COMMAND ${WPKG}
                --output-dir "${WPKG_ROOT}/packages"
                --build      "${WPKG_ROOT}/${_comp}"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            DEPENDS ${_comp}_install
            )
endforeach()

add_custom_target( wpkg_package DEPENDS ${COMPONENT_LIST} )

# vim: ts=4 sw=4 et