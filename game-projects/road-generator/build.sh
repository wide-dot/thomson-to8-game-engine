#!/usr/bin/env bash
# ============================================================================
# build.sh — Build et lance le builder pour road-generator (macOS)
# ----------------------------------------------------------------------------
# Usage :
#   ./build.sh           → build le jar si nécessaire puis génère le .fd/.t2
#   ./build.sh --clean   → force le rebuild du jar Java
#   ./build.sh --run     → après build, lance dans dcmoto si dispo
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
# NOTE : -Xverify:none contourne un bug pré-existant de BuildDisk.java
#        (VerifyError dans la lambda generateTilesets$11 — classe locale
#        capturant des variables dans un lambda, mauvais bytecode généré
#        par javac). Le fix propre est de refactorer la classe Aux interne
#        en classe statique nested dans BuildDisk.java.
#        Cette option émet un warning de dépréciation depuis JDK 13 mais
#        fonctionne encore en JDK 17/21.
cd "$SCRIPT_DIR"
echo "==> Génération road-generator depuis $CONFIG ..."
java -Xverify:none -jar "$JAR_PATH" "$CONFIG"

echo ""
echo "==> Build terminé. Outputs :"
if [ -d dist ]; then
    ls -la dist/
else
    echo "  (dossier dist/ non trouvé)"
fi

# ----- 4. Optionnel : lance l'émulateur -----
# Convention : un symlink (ou une .app copiée) nommé "dcmoto.app" à la racine
# du game-project. DCMOTO mémorise la dernière disquette chargée dans son
# fichier de configuration, donc on lance l'app sans argument — pas besoin
# de passer le .fd, DCMOTO le retrouve tout seul.
if [ $RUN -eq 1 ]; then
    APP_LINK="$SCRIPT_DIR/dcmoto.app"
    if [ -L "$APP_LINK" ] || [ -d "$APP_LINK" ]; then
        echo "==> Lancement de DCMOTO via $APP_LINK"
        open "$APP_LINK"
    else
        echo "==> Aucun dcmoto.app trouvé. dist/road-generator.fd prêt."
        echo "    Pour activer --run, place un symlink ou une .app à : $APP_LINK"
    fi
fi
