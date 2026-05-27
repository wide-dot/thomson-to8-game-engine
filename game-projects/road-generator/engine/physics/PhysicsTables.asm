        opt   c
 ifndef PhysicsTables_included
PhysicsTables_included equ 1
* ======================================================================
* PhysicsTables.asm — TABLES PHYSIQUES VERSION TO8
* 
* Converties depuis Lotus ST (CARS.REL) par
* tools/convert_physics_tables_to8.py.
* 
* Règle : valeurs horizontales /2 (TO8 = 160px vs ST 320px).
* 
* Référence faithful ST : engine/physics/PhysicsTables_ST_reference.asm
* Doc physique         : lotus-ste/.../21_TICK_PHYSIQUE_JOUEUR.md
* ======================================================================

* ======================================================================
* Constantes physiques (EQU) — TO8 = ST/2 pour valeurs horizontales
* ======================================================================
PHYS_MAX_SPEED        equ   $01AA     ; ST=$01AA     Speed forward max clamp. IDENTIQUE ST (axe forward, pas horizontal).
PHYS_BRAKE_DECEL      equ   $30       ; ST=$0030     Delta speed/tick sur DOWN. IDENTIQUE ST (axe forward).
PHYS_CRASH_DECEL      equ   $18       ; ST=$0018     Delta speed/tick en crash. IDENTIQUE ST (axe forward).
PHYS_TARGET_SPEED     equ   $0A00     ; ST=$0A00     Cible régulation speed (FUN_760ae). IDENTIQUE ST.
PHYS_LATERAL_HI       equ   $C0       ; ST=$0180 /2  Borne sup lateral_pos integer. /2 pour TO8 (écran horizontal /2).
PHYS_LATERAL_LO       equ   $FF40     ; ST=$FE80 /2  Borne inf lateral_pos integer. /2.
PHYS_STEERING_MAX     equ   $10       ; ST=$0020 /2  Clamp steering ∈ [-$20, +$20]. /2 car steering × 5 × speed contribue à lateral_pos → halver STEERING_MAX divise la contribution X par 2.
PHYS_STEERING_DELTA   equ   $01       ; ST=$0002 /2  Delta steering/tick sur LEFT/RIGHT. /2 pour préserver le TIMING d'atteinte de STEERING_MAX (responsiveness identique en temps).
PHYS_RPM_MIN          equ   $03E8     ; ST=$03E8     Floor RPM. IDENTIQUE (régime moteur).
PHYS_RPM_MAX          equ   $1F3F     ; ST=$1F3F     Ceiling RPM. IDENTIQUE.
PHYS_UPSHIFT_RPM      equ   $0FA0     ; ST=$0FA0     Seuil RPM upshift auto. IDENTIQUE.
PHYS_DOWNSHIFT_RPM    equ   $09C3     ; ST=$09C3     Seuil RPM downshift auto. IDENTIQUE.
PHYS_GEAR_COUNT       equ   $05       ; ST=$0005     Nombre de rapports (0..4). IDENTIQUE.
PHYS_RECOVERY_TICKS   equ   $19       ; ST=$0019     Durée recovery (= 25 frames = 0.5s à 50Hz). IDENTIQUE (= temps).

* ──────────────────────────────────────────────────────────────────────
* PhysTable_EngineAccel
* Source : CARS.REL RAM $7CA9C (file +$C69C)  →  identique
*   Engine torque ACCEL — indexé par (rpm >> 7). IDENTIQUE ST : delta sp
*   eed forward, pas horizontal.
* ──────────────────────────────────────────────────────────────────────
PhysTable_EngineAccel
        fdb   $0019,$0019,$001E,$001E,$0023,$0023,$0028,$0028    ; [ 0.. 7]
        fdb   $002C,$0030,$0034,$0038,$003C,$0040,$0044,$0048    ; [ 8..15]
        fdb   $004B,$004E,$0051,$0054,$0056,$0058,$005A,$005C    ; [16..23]
        fdb   $005E,$005F,$0060,$0060,$0060,$0060,$005F,$005E    ; [24..31]
        fdb   $005C,$005A,$0058,$0056,$0054,$0051,$004E,$004B    ; [32..39]
        fdb   $0048,$0044,$0040,$003C,$0038,$0034,$0030,$002C    ; [40..47]
        fdb   $0028,$0024,$0020,$001C,$0018,$0014,$0010,$000C    ; [48..55]
        fdb   $0008,$0004,$0000,$FFFB,$FFF6,$FFF1,$FFEC,$FFE7    ; [56..63]
        fdb   $FFE2,$FFD8,$FFC4,$FFB0,$FF9C,$FF6A,$FF38,$FF06    ; [64..71]
        fdb   $FED4,$FE70,$FE0C,$FDA8    ; [72..75]

* ──────────────────────────────────────────────────────────────────────
* PhysTable_EngineNormal
* Source : CARS.REL RAM $7CB34 (file +$C734)  →  identique
*   Engine torque NORMAL (cruise). IDENTIQUE ST.
* ──────────────────────────────────────────────────────────────────────
PhysTable_EngineNormal
        fdb   $FFFB,$FFFB,$FFFB,$FFFB,$FFFB,$FFFB,$FFFB,$FFFB    ; [ 0.. 7]
        fdb   $FFF6,$FFF6,$FFF6,$FFF6,$FFF6,$FFF6,$FFF6,$FFF6    ; [ 8..15]
        fdb   $FFF1,$FFF1,$FFF1,$FFF1,$FFF1,$FFF1,$FFF1,$FFF1    ; [16..23]
        fdb   $FFEC,$FFEC,$FFEC,$FFEC,$FFEC,$FFEC,$FFEC,$FFEC    ; [24..31]
        fdb   $FFE7,$FFE7,$FFE7,$FFE7,$FFE2,$FFE2,$FFE2,$FFE2    ; [32..39]
        fdb   $FFD8,$FFD8,$FFD8,$FFD8,$FFD3,$FFD3,$FFD3,$FFD3    ; [40..47]
        fdb   $FFCE,$FFCE,$FFC9,$FFC9,$FFC4,$FFC4,$FFBF,$FFBF    ; [48..55]
        fdb   $FFBA,$FFB5,$FFB0,$FFAB,$FFA6,$FFA1,$FF9C,$FF97    ; [56..63]
        fdb   $FF92,$FF88,$FF74,$FF60,$FF4C,$FF38,$FF06,$FED4    ; [64..71]
        fdb   $FE70,$FE0C,$FDA8,$FD44    ; [72..75]

* ──────────────────────────────────────────────────────────────────────
* PhysTable_GearMul
* Source : CARS.REL RAM $7CBCC (file +$C7CC)  →  identique
*   gear_mul (divisor RPM) par gear 0..4. IDENTIQUE ST.
* ──────────────────────────────────────────────────────────────────────
PhysTable_GearMul
        fdb   $3D55,$6455,$9680,$C800,$F800    ; [ 0.. 4]

* ──────────────────────────────────────────────────────────────────────
* PhysTable_LateralDamp
* Source : CARS.REL RAM $7CBF8 (file +$C7F8)  →  identique
*   Lateral damping (= shift count). IDENTIQUE — ratio sans dimension pi
*   xel.
* ──────────────────────────────────────────────────────────────────────
PhysTable_LateralDamp
        fcb   $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06    ; [ 0..15]
        fcb   $06,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00    ; [16..31]
        fcb   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$06    ; [32..47]
        fcb   $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06    ; [48..63]

 endc
