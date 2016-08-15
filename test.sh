#!/bin/bash
sudo lime build android
adb connect 192.168.1.101
adb shell am force-stop com.sample.pong
adb shell am start -a android.intent.action.DELETE -d package:com.sample.pong
adb shell input tap 580 760
adb install Export/android/release/bin/bin/Pong-debug.apk
adb shell am start -n com.sample.pong/com.sample.pong.MainActivity
