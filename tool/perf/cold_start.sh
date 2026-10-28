#!/usr/bin/env bash
# §13 "Cold start to Home < 1.5 s" on a connected device (feature 012 T047,
# research R10). Each run force-stops the app, starts it with `am start -W`,
# and reads Android's "Fully drawn" time: DSH-01 calls reportFullyDrawn() on
# its first content frame. Install a profile or release build first and get
# past onboarding and login, so a cold start lands on Home.
#
# Usage: tool/perf/cold_start.sh [runs] [package]
# Exit 1 if the median fully-drawn time is over 1800 ms. 1500 ms or less is
# Pass, up to 1800 ms is Open (clarification Q4), more is Fail.
set -euo pipefail

runs="${1:-10}"
pkg="${2:-com.midexcode.dailytrack}"
# The Kotlin namespace differs from the application ID.
activity="com.midexcode.daily.track.dailytrack.MainActivity"
adb="${ADB:-adb}"

median() { sort -n | awk '{a[NR]=$1} END {if (NR==0) {print 0} else if (NR%2) {print a[(NR+1)/2]} else {print int((a[NR/2]+a[NR/2+1])/2)}}'; }
p90() { sort -n | awk '{a[NR]=$1} END {i=int(NR*0.9+0.999); if (i<1) i=1; print a[i]}'; }

total=()
drawn=()
for i in $(seq 1 "$runs"); do
  "$adb" shell am force-stop "$pkg"
  sleep 1
  "$adb" logcat -c
  out="$("$adb" shell am start -W -S -n "$pkg/$activity")"
  t="$(printf '%s\n' "$out" | awk -F': ' '/TotalTime/ {print $2}' | tr -d '\r')"
  # reportFullyDrawn is logged a moment after the first frame.
  d=""
  for _ in $(seq 1 50); do
    d="$("$adb" logcat -d -s ActivityTaskManager:I ActivityManager:I \
      | sed -n "s#.*Fully drawn $pkg/[^:]*: +\([0-9]*\)s\?\([0-9]*\)ms.*#\1 \2#p" \
      | tail -n1)"
    [ -n "$d" ] && break
    sleep 0.2
  done
  if [ -z "$d" ]; then
    echo "::error::run $i: no 'Fully drawn' line (is the app past login, on Home?)"
    exit 1
  fi
  # "+1s234ms" → "1 234"; "+987ms" → "987 ".
  read -r a b <<<"$d"
  if [ -n "${b:-}" ]; then ms=$((a * 1000 + 10#$b)); else ms=$a; fi
  total+=("$t")
  drawn+=("$ms")
  echo "run $i: first frame ${t} ms, fully drawn ${ms} ms"
done

t_med="$(printf '%s\n' "${total[@]}" | median)"
d_med="$(printf '%s\n' "${drawn[@]}" | median)"
d_p90="$(printf '%s\n' "${drawn[@]}" | p90)"
result=Fail
if [ "$d_med" -le 1500 ]; then result=Pass; elif [ "$d_med" -le 1800 ]; then result=Open; fi
echo "first frame median ${t_med} ms; fully drawn (Home) median ${d_med} ms, p90 ${d_p90} ms → ${result}"
[ "$result" != Fail ]
