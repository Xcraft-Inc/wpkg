#
# CMakeLists.txt for zstd within the wpkg tool.
#

# WARNING: C/CXX flags are defined once for all the CMakeLists.txt projects
if ( MSVC )
    set( ZSTD_FOLDER libs/zstd )
    set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE" )
endif()

set ( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DZSTD_MULTITHREAD" )

# TODO: make zconf.h from zconf.h.cmakein
set(ZSTD_PUBLIC_HDRS
    lib/zdict.h
    lib/zstd.h
    lib/zstd_errors.h
)

project(wpkg_zstd_static)

add_library( ${PROJECT_NAME} STATIC
    lib/common/debug.c
    lib/common/entropy_common.c
    lib/common/error_private.c
    lib/common/fse_decompress.c
    lib/common/pool.c
    lib/common/threading.c
    lib/common/xxhash.c
    lib/common/zstd_common.c
    lib/compress/fse_compress.c
    lib/compress/huf_compress.c
    lib/compress/zstd_compress_literals.c
    lib/compress/zstd_compress_sequences.c
    lib/compress/zstd_compress_superblock.c
    lib/compress/zstd_compress.c
    lib/compress/zstd_double_fast.c
    lib/compress/zstd_fast.c
    lib/compress/zstd_lazy.c
    lib/compress/zstd_ldm.c
    lib/compress/zstd_opt.c
    lib/compress/zstdmt_compress.c
    lib/decompress/huf_decompress.c
    lib/decompress/zstd_ddict.c
    lib/decompress/zstd_decompress_block.c
    lib/decompress/zstd_decompress.c
    lib/dictBuilder/cover.c
    lib/dictBuilder/divsufsort.c
    lib/dictBuilder/fastcover.c
    lib/dictBuilder/zdict.c
)

if( MSVC )
    set_target_properties( ${PROJECT_NAME} PROPERTIES
        FOLDER ${ZSTD_FOLDER}
    )
endif()

StaticCompile()

install(
    TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin COMPONENT runtime
    LIBRARY DESTINATION lib COMPONENT development
    ARCHIVE DESTINATION lib COMPONENT development
)



project(wpkg_zstd)

add_library( ${PROJECT_NAME} SHARED
    lib/common/debug.c
    lib/common/entropy_common.c
    lib/common/error_private.c
    lib/common/fse_decompress.c
    lib/common/pool.c
    lib/common/threading.c
    lib/common/xxhash.c
    lib/common/zstd_common.c
    lib/compress/fse_compress.c
    lib/compress/huf_compress.c
    lib/compress/zstd_compress_literals.c
    lib/compress/zstd_compress_sequences.c
    lib/compress/zstd_compress_superblock.c
    lib/compress/zstd_compress.c
    lib/compress/zstd_double_fast.c
    lib/compress/zstd_fast.c
    lib/compress/zstd_lazy.c
    lib/compress/zstd_ldm.c
    lib/compress/zstd_opt.c
    lib/compress/zstdmt_compress.c
    lib/decompress/huf_decompress.c
    lib/decompress/zstd_ddict.c
    lib/decompress/zstd_decompress_block.c
    lib/decompress/zstd_decompress.c
    lib/dictBuilder/cover.c
    lib/dictBuilder/divsufsort.c
    lib/dictBuilder/fastcover.c
    lib/dictBuilder/zdict.c
)

if( MSVC )
    set_target_properties( ${PROJECT_NAME} PROPERTIES
        COMPILE_FLAGS
        FOLDER ${ZLIB_FOLDER}
    )
else()
    set_target_properties( ${PROJECT_NAME} PROPERTIES
        VERSION ${WPKG_VERSION_MAJOR}.${WPKG_VERSION_MINOR}
        SOVERSION ${WPKG_VERSION_MAJOR}
    )
endif()

install(
    TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin COMPONENT runtime
    LIBRARY DESTINATION lib COMPONENT runtime
    ARCHIVE DESTINATION lib COMPONENT development
)
install(
    FILES ${ZSTD_PUBLIC_HDRS}
    DESTINATION include/wpkg
    COMPONENT headers
)

set_property( GLOBAL APPEND PROPERTY ALL_LIBRARY_TARGETS wpkg_zstd wpkg_zstd_static )

add_custom_target( zstd_target DEPENDS wpkg_zstd_static wpkg_zstd )
set_property( TARGET zstd_target PROPERTY FOLDER ${ZSTD_FOLDER} )

# vim: ts=4 sw=4 et
