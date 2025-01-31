// Copyright (c) 2011 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef BASE_NATIVE_LIBRARY_H_
#define BASE_NATIVE_LIBRARY_H_

// This file defines a cross-platform "NativeLibrary" type which represents
// a loadable module.

#include "base/base_export.h"
#include "base/compiler_specific.h"
#include "build_config.h"

#if defined(OS_WIN)
#include <windows.h>
#elif defined(OS_MACOSX)
#import <CoreFoundation/CoreFoundation.h>
#endif  // OS_*

#include "base/strings/string16.h"

namespace base {

class FilePath;

#if defined(OS_WIN)
typedef HMODULE NativeLibrary;
#elif defined(OS_MACOSX)
enum NativeLibraryType {
  BUNDLE,
  DYNAMIC_LIB
};
enum NativeLibraryObjCStatus {
  OBJC_UNKNOWN,
  OBJC_PRESENT,
  OBJC_NOT_PRESENT,
};
struct NativeLibraryStruct {
  NativeLibraryType type;
  CFBundleRefNum bundle_resource_ref;
  NativeLibraryObjCStatus objc_status;
  union {
    CFBundleRef bundle;
    void* dylib;
  };
};
typedef NativeLibraryStruct* NativeLibrary;
#elif defined(OS_POSIX)
typedef void* NativeLibrary;
#endif  // OS_*

// Loads a native library from disk.  Release it with UnloadNativeLibrary when
// you're done.  Returns NULL on failure.
// If |err| is not NULL, it may be filled in with an error message on
// error.
BASE_EXPORT NativeLibrary LoadNativeLibrary(const FilePath& library_path,
                                            std::string* error);

#if defined(OS_WIN)
// Loads a native library from disk.  Release it with UnloadNativeLibrary when
// you're done.
// This function retrieves the LoadLibrary function exported from kernel32.dll
// and calls it instead of directly calling the LoadLibrary function via the
// import table.
BASE_EXPORT NativeLibrary LoadNativeLibraryDynamically(
    const FilePath& library_path);
#endif  // OS_WIN

// Unloads a native library.
BASE_EXPORT void UnloadNativeLibrary(NativeLibrary library);

// Gets a function pointer from a native library.
BASE_EXPORT void* GetFunctionPointerFromNativeLibrary(NativeLibrary library,
                                                      const char* name);

// Returns the full platform specific name for a native library.
// For example:
// "mylib" returns "mylib.dll" on Windows, "libmylib.so" on Linux,
// "mylib.dylib" on Mac.
BASE_EXPORT string16 GetNativeLibraryName(const string16& name);

}  // namespace base

#endif  // BASE_NATIVE_LIBRARY_H_
