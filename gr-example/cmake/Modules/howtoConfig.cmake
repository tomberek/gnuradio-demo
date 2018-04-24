INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_HOWTO howto)

FIND_PATH(
    HOWTO_INCLUDE_DIRS
    NAMES howto/api.h
    HINTS $ENV{HOWTO_DIR}/include
        ${PC_HOWTO_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /var/empty/local/include
          /var/empty/include
)

FIND_LIBRARY(
    HOWTO_LIBRARIES
    NAMES gnuradio-howto
    HINTS $ENV{HOWTO_DIR}/lib
        ${PC_HOWTO_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /var/empty/local/lib
          /var/empty/local/lib64
          /var/empty/lib
          /var/empty/lib64
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(HOWTO DEFAULT_MSG HOWTO_LIBRARIES HOWTO_INCLUDE_DIRS)
MARK_AS_ADVANCED(HOWTO_LIBRARIES HOWTO_INCLUDE_DIRS)

