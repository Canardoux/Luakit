# Google Android makefile for curl and libcurl
#
# This file can be used when building curl using the full Android source
# release or the NDK. Most users do not want or need to do this; please
# instead read the Android section in docs/INSTALL for alternate
# methods.
#
# Place the curl source (including this makefile) into external/curl/ in the
# Android source tree.  Then build them with 'make curl' or just 'make libcurl'
# from the Android root. Tested with Android versions 1.5, 2.1-2.3
#
# Note: you must first create a curl_config.h file by running configure in the
# Android environment. The only way I've found to do this is tricky. Perform a
# normal Android build with libcurl in the source tree, providing the target
# "showcommands" to make. The build will eventually fail (because curl_config.h
# doesn't exist yet), but the compiler commands used to build curl will be
# shown. Now, from the external/curl/ directory, run curl's normal configure
# command with flags that match what Android itself uses. This will mean
# putting the compiler directory into the PATH, putting the -I, -isystem and
# -D options into CPPFLAGS, putting the -W, -m, -f, -O and -nostdlib options
# into CFLAGS, and putting the -Wl, -L and -l options into LIBS, along with the
# path to the files libgcc.a, crtbegin_dynamic.o, and ccrtend_android.o.
# Remember that the paths must be absolute since you will not be running
# configure from the same directory as the Android make.  The normal
# cross-compiler options must also be set. Note that the -c, -o, -MD and
# similar flags must not be set.
#
# To see all the LIBS options, you'll need to do the "showcommands" trick on an
# executable that's already buildable and watch what flags Android uses to link
# it (dhcpcd is a good choice to watch). You'll also want to add -L options to
# LIBS that point to the out/.../obj/lib/ and out/.../obj/system/lib/
# directories so that additional libraries can be found and used by curl.
#
# The end result will be a configure command that looks something like this
# (the environment variable A is set to the Android root path which makes the
# command shorter):
#
#  A=`realpath ../..` && \
#  PATH="$A/prebuilt/linux-x86/toolchain/arm-eabi-X/bin:$PATH" \
#  ./configure --host=arm-linux CC=arm-eabi-gcc \
#  CPPFLAGS="-I $A/system/core/include ..." \
#  CFLAGS="-nostdlib -fno-exceptions -Wno-multichar ..." \
#  LIBS="$A/prebuilt/linux-x86/toolchain/arm-eabi-X/lib/gcc/arm-eabi/X\
#  /interwork/libgcc.a ..."
#
# Finally, copy the file COPYING to NOTICE so that the curl license gets put
# into the right place (but see the note about this below).
#
# Dan Fandrich
# November 2011

LOCAL_PATH:= $(call my-dir)

#########################
# Build the libcurl library

include $(CLEAR_VARS)

LOCAL_CFLAGS += -DHAVE_CONFIG_H \
                -DUSE_OPENSSL \
                -DUSE_SSLEAY \
                -DHAVE_LIBZ \
                -DHAVE_ZLIB_H \
                -DOPENSSL_NO_STDIO \
                -DOPENSSL_NO_UI_CONSOLE \
                -DOPENSSL_NO_ENGINE

include $(LOCAL_PATH)/lib/Makefile.inc
CURL_HEADERS := \
  curl.h \
  system.h \
  curlver.h \
  easy.h \
  mprintf.h \
  multi.h \
  stdcheaders.h \
  typecheck-gcc.h

LOCAL_SRC_FILES := $(addprefix lib/,$(CSOURCES))
LOCAL_SRC_FILES  := $(filter %.c %.cpp %.cc %.cxx,$(LOCAL_SRC_FILES))
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include $(LOCAL_PATH)/lib
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../openssl-1.1.1c/include $(LOCAL_PATH)/../openssl-1.1.1c/
LOCAL_C_INCLUDES += ${LOCAL_PATH}/../openssl-1.1.1c/libs/android${ANDROID_API}-${CONFIG}/${TARGET_ARCH_ABI}/include
LOCAL_C_INCLUDES += /usr/local/Cellar/node/11.5.0/include/node
$(warning "----------------the value of LOCAL_C_INCLUDES is $(LOCAL_C_INCLUDES)-------------------------")

LOCAL_STATIC_LIBRARIES += libssl \
              crypto \


LOCAL_MODULE:= curl

# Copy the licence to a place where Android will find it.
# Actually, this doesn't quite work because the build system searches
# for NOTICE files before it gets to this point, so it will only be seen
# on subsequent builds.
# ALL_PREBUILT += $(LOCAL_PATH)/NOTICE
# $(LOCAL_PATH)/NOTICE: $(LOCAL_PATH)/COPYING | $(ACP)
# 	$(copy-file-to-target)
#$(warning "----------------the value of LOCAL_SRC_FILES is $(LOCAL_SRC_FILES)-------------------------")
include $(BUILD_STATIC_LIBRARY)

$(call import-add-path,$(LOCAL_PATH)/..)
$(call import-module, openssl-1.1.1c)

