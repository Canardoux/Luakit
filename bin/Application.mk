# This file is generated by auto-build.py, DON'T modify manually!

#-----------------------
ifndef ANDROID_API
ANDROID_API := 28
endif

ifndef CONFIG
CONFIG := debug
endif
#-----------------------

APP_PROJECT_PATH := $(call my-dir)
APP_ABI := armeabi-v7a arm64-v8a x86 x86_64
#TARGET_ARCH_ABI := arm64-v8a x86 x86_64 armeabi-v7a
APP_OPTIM := $(CONFIG)

APP_BUILD_SCRIPT := Android.mk

APP_STL := c++_static

APP_CFLAGS +=   -DOS_ANDROID \
                -DANDROID \
                -DNVALGRIND \
                -fvisibility=hidden \

APP_CPPFLAGS += -std=gnu++11

APP_CPPFLAGS += -fexceptions \
                -frtti \
                -fPIC \

APP_PLATFORM := android-$(ANDROID_API)
