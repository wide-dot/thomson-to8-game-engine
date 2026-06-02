#!/bin/bash
# Generate engine subsystem catalog from engine/ structure and usage analysis

OUTPUT_FILE="doc/engine-subsystems.md"

# Start markdown
cat > "$OUTPUT_FILE" << 'EOF'
# Thomson TO8 Engine Subsystems

Auto-generated catalog of all engine subsystems.
Last updated: $(date)

EOF

# Process each subsystem directory
for subsys in engine/*/; do
    subsys_name=$(basename "$subsys")

    # Find which games include this subsystem
    used_in=""
    for game in game-projects/*/; do
        game_name=$(basename "$game")
        # Skip non-game directories
        [[ "$game_name" =~ ^(logs|2023|2026)$ ]] && continue

        # Grep for includes of this subsystem
        if grep -r "include.*$subsys_name" "$game" 2>/dev/null | grep -q "\.asm"; then
            used_in="$used_in, $game_name"
        fi
    done
    used_in="${used_in#, }"  # Remove leading comma

    # Extract purpose from any README or comments in the subsystem
    # For now, placeholder — we'll fill in by hand or from code comments

    echo "## $subsys_name (engine/$subsys_name/)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Purpose:** [to be filled from code analysis]" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Used in:** $used_in" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "**Core Files:**" >> "$OUTPUT_FILE"
    find "$subsys" -name "*.asm" | sed 's/^/- /' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

done

echo "Catalog generated: $OUTPUT_FILE"
