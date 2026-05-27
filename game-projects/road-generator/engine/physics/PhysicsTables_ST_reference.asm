        opt   c
* ======================================================================
* PhysicsTables.asm
* 
* Tables physiques Lotus Esprit Turbo Challenge — extraites de
* CARS.REL (Atari ST original) par tools/extract_physics_tables.py.
* 
* Format conservé fidèlement (big-endian, valeurs identiques).
* Consommé par PlayerTick (cf. lotus-ste/.../21_TICK_PHYSIQUE_JOUEUR.md).
* ======================================================================

* ──────────────────────────────────────────────────────────────────────
* PhysTable_EngineAccel
* Source : CARS.REL RAM $7CA9C (file +$C69C)
*   Engine torque ACCEL — indexé par (rpm >> 7), peak ≈ 96 vers idx 24-3
*   1, négatif au-delà de 60 (= over-rev / redline)
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
* Source : CARS.REL RAM $7CB34 (file +$C734)
*   Engine torque NORMAL (cruise) — toujours négatif, -5 → -700 selon RP
*   M
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
* Source : CARS.REL RAM $7CBCC (file +$C7CC)
*   gear_mul (divisor) par gear 0..4 : 15701, 25685, 38528, 51200, 63488
* ──────────────────────────────────────────────────────────────────────
PhysTable_GearMul
        fdb   $3D55,$6455,$9680,$C800,$F800    ; [ 0.. 4]

* ──────────────────────────────────────────────────────────────────────
* PhysTable_LateralDamp
* Source : CARS.REL RAM $7CBF8 (file +$C7F8)
*   Lateral damping par (lateral_render + $200) >> 4 ∈ [8,56]. Valeur = 
*   shift amount appliqué à `speed -= speed >> damp >> 1`. 6 aux extrême
*   s (= herbe), 0 au centre (= asphalte).
* ──────────────────────────────────────────────────────────────────────
PhysTable_LateralDamp
        fcb   $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06    ; [ 0..15]
        fcb   $06,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00    ; [16..31]
        fcb   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$06    ; [32..47]
        fcb   $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06    ; [48..63]
