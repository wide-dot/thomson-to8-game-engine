; ============================================================================
; RAM variables — game-mode "road"
;
; Layout mémoire :
;   - DP ($9F00) : player1 OST (lifecycle uniquement, 97 oct)
;   - Main résidente : Player1_State + AI_States[] (struct LotusCarState
;     × N) + globals circuit
;   - Dynamic_Object_RAM : Road OST + slots libres
;
; Convention :
;   - OST player1 → adressé direct (player1+champ, DP)
;   - État Lotus → adressé via U register pointant sur LotusCarState
;     (= équivalent A4 dans Lotus 68000 qui pointait sur la struct
;     du véhicule en cours de traitement)
; ============================================================================

        INCLUDE "./engine/struct/LotusCarState.struct.asm"
        INCLUDE "./objects/ai-car/ai-car.equ"     ; pour AI_NB_CARS

; --- Object Constants ---
; player1 OST = en DP, lifecycle pur, donc ext_variables_size = 0 ici.
; Si AiCar est activé plus tard, monter à `ai_car_ext_size` (= 4).
ext_variables_size                equ 0
nb_dynamic_objects                equ 2     ; Road + 1 réserve
nb_graphical_objects              equ 1     ; seul Road a un sprite (player invisible)

; --- OST Player1 en DP ---
; Alias sur direct page : tous les accès player1+champ utilisent l'adressage
; direct DP (2 oct/4 cycles) au lieu d'extended (3/5).
player1                           equ   dp

; --- Dynamic Object RAM (= Road, etc.) ---
Dynamic_Object_RAM
                                  fill  0,nb_dynamic_objects*object_size
Dynamic_Object_RAM_End

; ============================================================================
; ÉTATS LOTUS (résidents) — accédés via U register
;
; Player1_State et AI_States[] partagent le MÊME layout LotusCarState (32 oct),
; permettant à Lotus_PhysicsTick d'être réutilisée pour n'importe quelle car
; en chargeant juste U avec le bon pointeur.
; ============================================================================

* Player1 state — référencé directement par label depuis tous les endroits
* (Player_Main, render futur, HUD, collision-scan, etc.)
PlayerOne_State                   fill  0,sizeof{LotusCarState}

* AI cars states — tableau contigu pour itération via pointer arithmetic.
* Spacing dans le tick AI : car[i] lit car[i-1] = state_ptr - sizeof{LotusCarState}.
* Player1 collision-scan : itère depuis AI_States en bumpant le pointeur.
AI_States                         fill  0,sizeof{LotusCarState}*AI_NB_CARS
AI_States_End

; ============================================================================
; GLOBALS CIRCUIT — pointeurs vers le circuit chargé
;
; Le pointeur de segment courant n'est PAS stocké ici : chaque voiture a son
; propre cache `segment_idx` dans son LotusCarState (maintenu par
; Lotus_PhysicsTick). Les consommateurs (projection, AI, collision) calculent
; le pointeur à la demande : `Circuit_base + segment_idx * 16`.
;
; Justification : 6809 n'a pas de hardware divu (vs 68000), donc le pattern
; Lotus "recalcule (track_pos>>16) % N à chaque consommation" coûterait trop
; cher sur 19 voitures (= 285% du budget frame 50 Hz). Le cache rend la
; conversion O(1) amortie.
; ============================================================================

* Circuit_base = pointeur DIRECT sur premier segment du circuit courant
* (= sortie de la jump table : Circuit_xxx +2). Setté par main.asm au chargement.
Circuit_base                      fdb   0

* Circuit_nb_segments = N segments du circuit courant. Lu par Lotus_PhysicsTick
* pour le wrap du segment_idx.
Circuit_nb_segments               fdb   0

; ============================================================================
; BUFFERS PROJECTION
;
; Sparse_Buffer  : sortie SparseProjection.
;   Format : slots de 8 octets (X | Y | Ymin | D0a), N variable mais
;   borné par la traversée de circuit (max ~128 slots = 1024 oct dans
;   les configurations extrêmes ; sécurité 1280 = 160 slots).
;
; Dense_Buffer   : sortie LinearInterp, lu par DrawFrameRoad.
;   Format : 6 octets/ligne (flags|width|extra) × 96 lignes road = 576 oct.
;   Le buffer est indexé via Y_screen (= les slots correspondant à des
;   lignes au-dessus de l'horizon sont skip par LinearInterp).
;
; Les 2 buffers vivent en RAM résidente $6100-$9FFF du game-mode.
; ============================================================================

Sparse_Buffer                     fill  0,1280
* Dense_Buffer : indexé par Y_screen ABSOLU 0..191 (= comme 68k $2b400).
* LinearInterp écrit à dense + Y_last × 6 sans décalage.
* Pour une route plate (D3=0), Y_screen ∈ [39..95] = positions CIEL valides.
* DrawFrameRoad lit dense[($60 + i) × 6] pour i = 0..95 (= viewport road).
* Taille = $C0 × 6 = 1152 oct (= 192 triplets, capacité écran entière).
Dense_Buffer                      fill  0,1152
