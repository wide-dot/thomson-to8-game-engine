#!/usr/bin/env bash
# ============================================================================
# build-stream.sh — Build le game-mode stream "road-stream" (validation placement)
# ----------------------------------------------------------------------------
# Identique à build.sh mais pointe sur config-macos-stream.properties
# (gameModeBoot=roadstream). Produit dist/road-generator-stream.fd.
#
# Usage :
#   ./build-stream.sh           → génère le .fd stream
#   ./build-stream.sh --clean   → force le rebuild du jar Java
#   ./build-stream.sh --run     → après build, lance dans dcmoto si dispo
#
# Prérequis : Java 11+, Maven 3.6+
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GENERATOR_DIR="$ENGINE_ROOT/java-generator"
JAR_NAME="game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
JAR_PATH="$GENERATOR_DIR/target/$JAR_NAME"
CONFIG="./config-macos-stream.properties"

CLEAN=0
RUN=0
for arg in "$@"; do
    case "$arg" in
        --clean) CLEAN=1 ;;
        --run)   RUN=1 ;;
        *)       echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

# ----- 1. Vérif des prérequis -----
command -v java >/dev/null || { echo "Error: java introuvable dans PATH" >&2; exit 1; }
command -v mvn  >/dev/null || { echo "Error: mvn introuvable dans PATH" >&2; exit 1; }

# ----- 2. Build du jar si nécessaire -----
if [ $CLEAN -eq 1 ] || [ ! -f "$JAR_PATH" ]; then
    echo "==> Build du générateur Java..."
    (cd "$GENERATOR_DIR" && mvn clean compile assembly:single)
    if [ ! -f "$JAR_PATH" ]; then
        echo "Error: jar non produit à $JAR_PATH" >&2
        exit 1
    fi
fi

# ----- 3. Exécution du builder -----
cd "$SCRIPT_DIR"
echo "==> Génération road-generator-stream depuis $CONFIG ..."
java -Xverify:none -jar "$JAR_PATH" "$CONFIG"

echo ""
echo "==> Build terminé. Outputs :"
if [ -d dist ]; then
    ls -la dist/
else
    echo "  (dossier dist/ non trouvé)"
fi

# ----- 4. Optionnel : lance l'émulateur -----
if [ $RUN -eq 1 ]; then
    APP_LINK="$SCRIPT_DIR/dcmoto.app"
    if [ -L "$APP_LINK" ] || [ -d "$APP_LINK" ]; then
        echo "==> Lancement de DCMOTO via $APP_LINK"
        open "$APP_LINK"
    else
        echo "==> Aucun dcmoto.app trouvé. dist/road-generator-stream.fd prêt."
        echo "    Pour activer --run, place un symlink ou une .app à : $APP_LINK"
    fi
fi
