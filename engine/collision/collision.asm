; ------------------------------------------------------------------------------
; Wrapper de compatibilite. Le code collision est splitte en deux :
;   - collision-list.asm : (de)referencement d'AABB (Add/Remove), appele par les
;     objets -> doit rester resident.
;   - collision-do.asm   : passe de detection (Collision_Do), appelee seulement
;     par le main -> peut etre incluse hors du resident (page de l'appelant).
; Les consommateurs qui veulent tout en resident incluent ce fichier (inchange).
; R-Type stage 1 inclut collision-list.asm en resident et collision-do.asm dans
; obj_mainext (hors resident).
; ------------------------------------------------------------------------------
        INCLUDE "./engine/collision/collision-list.asm"
        INCLUDE "./engine/collision/collision-do.asm"
