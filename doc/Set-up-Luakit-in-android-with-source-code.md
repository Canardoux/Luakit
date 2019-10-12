Prerequisite
-----------------------------
You can develop your application, using Android Studio on :
- Linux
- Macos
- Windows, using WSL (Windows subsystem for Linux)

You must install :
* Android Studio
* Cmake
* The Android SDKs
* The Android NDK

Note : Windows users must install a Linux subsystem (WSL) like Ubuntu or Kali. They will also have to install the Android NDK onto this subsystem (A Linux NDK). It means that Windows users will need to have two NDKs. One on Linux, and one on Windows. C'est la vie.

Now, set the needed environment variables. In your ~/.bashrc add the following two variables :
```sh
export ANDROID_HOME=...
export ANDROID_NDK_HOME=...
```

Build the OpenSSL library
-------------------------
You need to build the openSSL library for your target API version, such as:

```sh
export CONFIG=Debug
export ANDROID_API=24
cd luakit/src/openssl-1.1.1c/
./build-android.sh
```

The $CONFIG environment variable must be "Debug" or "Release".
The $ANDROID_API environment variable is your target API version.

You will get your library in luakit/libs/


Build the Luakit library (optional)
-----------------------------------
If you want to build the complete Luakit library (libluaFramework.so) and not just Open SSL, you can do the following instead of the previous step :

```sh
export CONFIG=Debug
export ANDROID_API=24
cd luakit/
./build-android.sh
```

The $CONFIG environment variable must be "Debug" or "Release".
The $ANDROID_API environment variable is your target API version.

You will get your library in luakit/libs/


Create a new project with Android Studio
-----------------------------
If you have your own project , skip this step

Add dependence
-----------------------------
Open your project, add jniLibs.srcDir to your app build.gradle, such as below


```
apply plugin: 'com.android.application'

android {
    compileSdkVersion 28
    defaultConfig {
                minSdkVersion 24
                targetSdkVersion 28
		...
    }
    buildTypes {
       ...
    }

    externalNativeBuild {
        cmake {
            version "3.10.2"
            path file('../../../src/jni/CMakeLists.txt')
        }
    }

    //add jniLibs.srcDir
    sourceSets{
        main{
            main.jni.srcDirs = [ '../../../src/jni' ]

        }
    }
    dependencies {
        implementation 'com.android.support:appcompat-v7:28.0.0'
        implementation 'com.android.support.constraint:constraint-layout:1.1.3'
           ...
        implementation project(':luakit')
        //implementation 'com.github.williamwen1986:LuakitJitpack:1.0.9'

    }
}
```

Create a "setting.gradle" file into your Project Directory, with the following :

```
include ':app', ':luakit', ':lib_chromium'
project(':luakit').projectDir = new File(settingsDir, '../../AndroidFrameWork/luakit')
project(':lib_chromium').projectDir = new File(settingsDir, '../../AndroidFrameWork/lib_chromium')
```

Copy your lua source code to android assets/lua folder
------------------------------------------------------
You must add your own lua files to assets/lua folder (the name "lua" is important).

Initialization Luakit
---------------------
Add below code to your entrance of your app

```java
LuaHelper.startLuaKit(this);
```
Create your own business model
------------------------------
Luakit provide general interface to connect java and lua ,Refer to [LuaHelper.java](../src/main/java/com/common/luakit/LuaHelper.java.java)

```java
Object[] ret =  (Object[]) LuaHelper.callLuaFunction("WeatherManager","getWeather");

ILuaCallback callback = new ILuaCallback() {
    @Override
    public void onResult(Object o) {
        Object[] ret = (Object[])o;
        adapter.source = ret;
        adapter.notifyDataSetChanged();
    }
};

LuaHelper.callLuaFunction("WeatherManager","loadWeather", callback);
```
The goal of the above code is to connect the [lua file](../AndroidDemo/WeatherTest/app/src/main/assets/lua/WeatherManager.lua).

The lua code is the finally working code

```lua
local _weatherManager = {}

local Table = require('orm.class.table')
local _weatherTable = Table("weather")

_weatherManager.getWeather = function ()
	return _weatherTable.get:all():getPureData()
end

_weatherManager.parseWeathers = function (responseStr,callback)
	local t = cjson.decode(responseStr)
	local weatherTable = _weatherTable
	local ret = {}
	if t and t.weather and t.weather[1] and t.weather[1].future then
		weatherTable.get:delete()
		local city = t.weather[1].city_name
		for i,v in ipairs(t.weather[1].future) do
			local t = {}
			t.wind = v.wind
			t.date = v.date
			t.low = tonumber(v.low)
			t.high = tonumber(v.high)
			t.id = i
			t.city = city
			local weather = weatherTable(t)
			weather:save()
			table.insert(ret,weather:getPureData())
		end
	end
	if callback then
		callback(ret)
	end
end

_weatherManager.loadWeather = function (callback)
	lua_http.request({ url  = "http://tj.nineton.cn/Heart/index/all?city=CHSH000000",
		onResponse = function (response)
			if response.http_code ~= 200 then
				if callback then
					callback(nil)
				end
			else
				lua_thread.postToThread(BusinessThreadLOGIC,"WeatherManager","parseWeathers",response.response,function(data)
					if callback then
						callback(data)
					end
				end)
			end
		end})
end

return _weatherManager
```
