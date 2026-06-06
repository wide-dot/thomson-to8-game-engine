#!/usr/bin/env bash
# Wrapper macOS/Linux — délègue à install.py (logique cross-platform).
set -e
cd "$(dirname "$0")"
PY=$(command -v python3 || command -v python)
exec "$PY" install.py "$@"
