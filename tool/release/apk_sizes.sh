#!/usr/bin/env bash
# §13 "APK size < 25 MB per ABI" (feature 012 T028, research R10). Builds the
# prod release split per ABI and checks each APK. This target always blocks
# a release (clarification Q4).
#
# Usage: tool/release/apk_sizes.sh [--no-build]
set -euo pipefail

limit=26214400 # 25 MB
defines=(--dart-define-from-file=config/dart_defines.json)
if [ -f config/prod.env.json ]; then
  defines+=(--dart-define-from-file=config/prod.env.json)
fi
if [ "${1:-}" != "--no-build" ]; then
  flutter build apk --release --flavor prod --split-per-abi "${defines[@]}"
fi

shopt -s nullglob
apks=(build/app/outputs/flutter-apk/app-*-prod-release.apk)
if [ ${#apks[@]} -eq 0 ]; then
  echo "::error::no split APKs found in build/app/outputs/flutter-apk/"
  exit 1
fi
failed=0
for apk in "${apks[@]}"; do
  bytes=$(wc -c <"$apk" | tr -d ' ')
  abi=$(basename "$apk" | sed 's/^app-\(.*\)-prod-release\.apk$/\1/')
  mb=$(awk "BEGIN {printf \"%.2f\", $bytes / 1048576}")
  if [ "$bytes" -ge "$limit" ]; then
    echo "::error::$abi: $mb MB is not under 25 MB"
    failed=1
  else
    echo "$abi: $mb MB (Pass)"
  fi
done
exit $failed
