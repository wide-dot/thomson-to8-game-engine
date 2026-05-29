        opt   c
 ifndef RoadLinesTable_included
RoadLinesTable_included equ 1

* ======================================================================
* RoadLinesTable.asm — TABLE DE DISPATCH SCANLINE → LINE_NNNN
*
* Wrapper résident du fichier tools/output/road_lines_ram/road_lines_table.asm
* (qui contient un `ORG $0000` problématique → on ne peut pas l'inclure
* directement dans le game-mode résident).
*
* Cette table est consultée par DRAW_FRAME_ROAD :
*   pour chaque scanline i (0..254), 4 variants pré-calculés par
*   (sub-pixel × palette) :
*     fdb RAMA_s0, RAMA_s1, RAMB_s0, RAMB_s1
*   = 8 oct par scanline × 255 scanlines = ~2 Ko résident.
*
* Usage 6809 :
*   ldy   Road_lines + 8 × line_idx + 2 × variant
*   ; Y = ptr vers Line_NNNN dans la pattern bank (mountée à $0000-$3FFF)
*
* CONTRAINTE : la table contient des valeurs Line_NNNN qui sont des
* offsets dans la page road_buffers mountée à $0000-$3FFF (cart zone).
* Donc le cart zone DOIT être mounté avec la page road_buffers avant
* de déréférencer ces Line_NNNN.
*
* Les EQU Line_NNNN sont fournies par road_buffers_externs.inc (à
* inclure AVANT cet asm pour résoudre les symboles).
* ======================================================================

        INCLUDE "./tools/output/road_lines_ram/road_buffers_externs.inc"

Road_lines
        INCLUDE "./engine/projection/RoadLinesTable_data.asm"

 endc
