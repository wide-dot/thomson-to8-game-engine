* ======================================================================
* road_buffers_data.asm — wrapper objet pour road_buffers.bin
*
* Pure data : on inclut le .bin directement via INCLUDEBIN.
* Pas de parsing asm = aucun risque de conflit de symbole avec main.glb
* auto-injecté par Bento8 (= les Road_R* EQUs y sont déjà depuis le résident).
*
* Le .bin contient les 800 buffers Line_NNNN (= header K,M,J + ptrs Road_R*)
* assemblés à ORG $0000 par compile_road_sprites_ram.py. Au runtime cette
* page est mountée en cart zone $0000-$3FFF, les Line_NNNN EQUs résolus
* par road_buffers_externs.inc (résident) pointent vers les bons offsets.
* ======================================================================

        ORG   $0000
        INCLUDEBIN "./objects/road-buffers/generated/road_buffers.bin"
