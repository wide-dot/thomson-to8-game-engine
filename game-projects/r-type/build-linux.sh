#!/usr/bin/env bash
# Build the r-type disk/cartridge images on Linux using the pre-built BuildDisk jar.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
JAR="$ENGINE_ROOT/java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
CONFIG="./config-linux.properties"

command -v java >/dev/null || { echo "Error: java not found" >&2; exit 1; }
if [ ! -f "$JAR" ]; then
    echo "==> Building generator jar..."
    (cd "$ENGINE_ROOT/java-generator" && mvn -q clean compile assembly:single)
fi
cd "$SCRIPT_DIR"
echo "==> Generating r-type from $CONFIG ..."
java -Xverify:none -jar "$JAR" "$CONFIG"
echo "==> Outputs:"; ls -la dist/ 2>/dev/null || echo "  (no dist/)"
