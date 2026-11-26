#!/bin/sh
# Builds three tiny release executables (no SDK, OpenAIKit, MacPaw/OpenAI), strips them and prints their sizes.
set -e
cd "$(dirname "$0")"
for probe in baseline kit macpaw; do
  start=$(date +%s)
  (cd "$probe" && swift build -c release >/dev/null)
  end=$(date +%s)
  strip -x -o "/tmp/openaikit-probe-$probe" "$probe/.build/release/Probe"
  printf '%-9s %6.1f MB  (release build %ss)\n' "$probe" "$(echo "$(stat -f %z /tmp/openaikit-probe-$probe) / 1048576" | bc -l)" "$((end - start))"
done
