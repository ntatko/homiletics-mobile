#!/bin/zsh
# Capture store-art screenshots from an Android phone running the
# tool/store_art/main_store_shots.dart debug build (install it first with
#   flutter run -d <serial> -t tool/store_art/main_store_shots.dart --no-resident).
# The build keeps its data in a throwaway sandbox, but it replaces the
# installed app: reinstall the normal app afterwards with
#   flutter run -d <serial> --no-resident
#
#   capture_android.sh <serial> <out_dir> "<screen> <theme> <lang>" ...
set -e
SERIAL=$1 OUT=$2; shift 2
ADB=${ADB:-$HOME/Library/Android/sdk/platform-tools/adb}
PKG=com.thirteenone.homiletics
mkdir -p "$OUT"
a() { "$ADB" -s "$SERIAL" "$@"; }
# clean status bar: 9:41, full battery and wifi, no notifications
a shell settings put global sysui_demo_allowed 1
a shell am broadcast -a com.android.systemui.demo -e command enter >/dev/null
a shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941 >/dev/null
a shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false >/dev/null
a shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4 -e mobile hide >/dev/null
a shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false >/dev/null
for spec in "$@"; do
  set -- ${=spec}
  SCREEN=$1 THEME=$2 LANG_=${3:-en}
  name=${THEME}_${SCREEN}; [ "$LANG_" != en ] && name=${name}_${LANG_}
  a shell am force-stop $PKG
  a shell "run-as $PKG sh -c 'mkdir -p app_flutter && echo \"{\\\"HSCREEN\\\":\\\"$SCREEN\\\",\\\"HTHEME\\\":\\\"$THEME\\\",\\\"HLANG\\\":\\\"$LANG_\\\"}\" > app_flutter/screenshot.json'"
  a shell monkey -p $PKG -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  sleep ${WAIT:-15}
  a exec-out screencap -p > "$OUT/$name.png"
  echo "saved $OUT/$name.png"
done
a shell am force-stop $PKG
a shell run-as $PKG rm -f app_flutter/screenshot.json
a shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null
a shell settings put global sysui_demo_allowed 0
