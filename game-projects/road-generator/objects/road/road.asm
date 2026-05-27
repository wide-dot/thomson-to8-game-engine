; ---------------------------------------------------------------------------
; Object - Road
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Sprite road 160x100, dessiné centré X (x_pixel=80), centre vertical à
; Y=50 (= 1/4 de l'écran). Le sprite est en mode draw seul (ND0), donc
; ses pixels transparents (index 0 dans la palette PNG) ne sont pas
; touchés et laissent voir le fond — qui prend les couleurs des rasters
; (ciel en haut, herbe en bas).
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Init_routine       equ 0
Main_routine       equ 1

Road
        lda   routine,u
        asla
        ldx   #Road_Routines
        jmp   [a,x]

Road_Routines
        fdb   Init
        fdb   Main

Init
        ; --- Animation (single frame, sprite statique) ---
        ldd   #Ani_Road
        std   anim,u

        ; --- Priorité d'affichage : back (8) car c'est le décor de fond ---
        ldb   #8
        stb   priority,u

        ; --- Position écran : centre du sprite (convention CENTER) ---
        ldd   #$7f4d
        std   xy_pixel,u

        ; --- Render flags : coord écran (pas playfield), pas de flip ---
        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        inc   routine,u                   ; passe en Main

Main
        jsr   AnimateSprite               ; (rien à animer, mais maintient image_set)
        jmp   DisplaySprite               ; inscrit dans la DPS et termine
