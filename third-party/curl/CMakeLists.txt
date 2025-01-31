# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version/lib of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)
project(luakit)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_HISTORICAL_STRERRO_R -DNVALGRIND -fvisibility=hidden -DHAVE_CONFIG_H -DUSE_OPENSSL -DUSE_SSLEAY -DHAVE_LIBZ -DHAVE_ZLIB_H -DOPENSSL_NO_STDIO -DOPENSSL_NO_UI_CONSOLE -DOPENSSL_NO_ENGINE")

file(GLOB all_SRCS
        "${PROJECT_SOURCE_DIR}/lib/*.cpp"
        "${PROJECT_SOURCE_DIR}/lib/*.c"
        "${PROJECT_SOURCE_DIR}/lib/vtls/*.c"
        "${PROJECT_SOURCE_DIR}/lib/vauth/*.c"
        )

add_library(
               # Sets the name of the library.
                curl

                # Sets the library as a shared library.
                STATIC

		${all_SRCS}
)

#------------------------- ssl ---------------------

add_library( ssl
             STATIC
             IMPORTED )

set_target_properties( # Specifies the target library.
                       ssl

                       # Specifies the parameter you want to define.
                       PROPERTIES IMPORTED_LOCATION

                      # Provides the path to the library you want to import.
                      $ENV{OUTPUT_DIR}/libssl.a 
                )

add_library( crypto
             STATIC
             IMPORTED )

set_target_properties( # Specifies the target library.
                       crypto

                       # Specifies the parameter you want to define.
                       PROPERTIES IMPORTED_LOCATION

                        #Provides the path to the library you want to import.
                        $ENV{OUTPUT_DIR}/libcrypto.a 
                      )
#---------------------------end ssl -----------------------

target_link_libraries( curl ssl crypto)


#link_directories(${PROJECT_SOURCE_DIR}/../openssl-1.1.1c/libs)


# Specifies a path to native header files.
include_directories(
	    ${PROJECT_SOURCE_DIR}/include
	    ${PROJECT_SOURCE_DIR}/lib
        $ENV{OUTPUT_DIR}/include/
	    /usr/local/Cellar/node/11.5.0/include/node
)
