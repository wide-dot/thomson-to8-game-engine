#!/usr/bin/env bash
# ============================================================================
# build-macos.sh — Build et lance le builder pour r-type (macOS)
# ----------------------------------------------------------------------------
# Usage :
#   ./build-macos.sh           → build le jar si nécessaire puis génère le .fd/.t2
#   ./build-macos.sh --clean   → force le rebuild du jar Java
#
# Prérequis : Java 11+, Maven 3.6+
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GENERATOR_DIR="$ENGINE_ROOT/java-generator"
JAR_NAME="game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
JAR_PATH="$GENERATOR_DIR/target/$JAR_NAME"
CONFIG="./config-macos.properties"

CLEAN=0
for arg in "$@"; do
    case "$arg" in
        --clean) CLEAN=1 ;;
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
# NOTE : -Xverify:none contourne un bug pré-existant de BuildDisk.java
#        (VerifyError dans la lambda generateTilesets$11 — classe locale
#        capturant des variables dans un lambda, mauvais bytecode généré
#        par javac). Le fix propre est de refactorer la classe Aux interne
#        en classe statique nested dans BuildDisk.java.
#        Cette option émet un warning de dépréciation depuis JDK 13 mais
#        fonctionne encore en JDK 17/21.
cd "$SCRIPT_DIR"
echo "==> Génération du jeu depuis $CONFIG ..."
java -Xverify:none -jar "$JAR_PATH" "$CONFIG"

echo ""
echo "==> Build terminé. Outputs :"
if [ -d dist ]; then
    ls -la dist/
else
    echo "  (dossier dist/ non trouvé)"
fi
