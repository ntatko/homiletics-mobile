#!/bin/zsh
# Capture one store-art screenshot from a booted iOS simulator running the
# tool/store_art/main_store_shots.dart debug build.
#   capture_sim.sh <udid> <HSCREEN> <HTHEME> <HLANG> <out.png>
set -e
UDID=$1 SCREEN=$2 THEME=$3 LANG_=$4 OUT=$5
BUNDLE=com.thirteenone.homiletics
cd "$(dirname "$0")/../.."
xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged \
  --batteryLevel 100 --wifiBars 3 --cellularBars 4 --dataNetwork wifi >/dev/null 2>&1 || true
DATA=$(xcrun simctl get_app_container "$UDID" $BUNDLE data)
mkdir -p "$DATA/Documents"
printf '{"HSCREEN":"%s","HTHEME":"%s","HLANG":"%s"}' "$SCREEN" "$THEME" "$LANG_" > "$DATA/Documents/screenshot.json"
xcrun simctl terminate "$UDID" $BUNDLE >/dev/null 2>&1 || true
flutter attach -d "$UDID" -t tool/store_art/main_store_shots.dart > /tmp/store_attach_$$.log 2>&1 &
APID=$!
sleep 2
xcrun simctl launch "$UDID" $BUNDLE >/dev/null
sleep ${WAIT:-16}
xcrun simctl io "$UDID" screenshot "$OUT" >/dev/null 2>&1
kill $APID 2>/dev/null || true
wait $APID 2>/dev/null || true
echo "saved $OUT"
