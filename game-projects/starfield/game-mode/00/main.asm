DEBUG EQU 1

        INCLUDE "./global/global-preambule-includes.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"

        org   $6100
        opt   cd,cc

* ============================================================================
* Init
* ----------------------------------------------------------------------------
* The disk loader leaves raw data in the video RAM pages. Black the palette
* FIRST (hide everything) and point the display at a page we control, before
* LoadAct clears pages 2/3 and installs Pal_starfield.
* Frame sync / double buffer is gfxlock: the 50Hz IRQ swaps the visible page
* (gfxlock.bufferSwap.check) and also ticks the music, so the players run at a
* steady 50Hz no matter how long a frame's rendering takes. WaitVBL is the
* alternative engine (r-type uses it) but it cannot coexist with gfxlock — both
* declare the same globals — and polling $E7E7 for the beam stalls once the
* music IRQ is live. goldorak/game-mode/gamescreen is the reference for this.
*
* Ordering matters: LoadAct (inside _gameMode.init) stack-blasts in ClearDataMem
* and needs IRQs off, so _IRQ.init must come after it.
* ============================================================================
        ldd   #Pal_black
        std   Pal_current
        clr   PalRefresh
        jsr   PalUpdateNow
        lda   #$C0                     ; onscreen video page = 3, border 0
        sta   $E7DD

        _gameMode.init #GmID_starfield ; InitGlobals + InitStack + LoadAct
* LoadAct has just blitted the nebula into both pages and nothing has drawn over
* it yet, which is the only moment the bands are pristine. Snapshot them now;
* MainLoop repaints them every frame so moving text cannot smear.
        ldx   #band_text
        jsr   BandSave
        ldx   #band_msg
        jsr   BandSave
        jsr   BallsSnapshot            ; same reason, for the orbit annulus
        _gfxlock.init

* MUST sit between LoadAct and _palette.show. ScenarioInit derives its fade ramp
* from the AUTHORED Pal_starfield and only then blacks out the groups it intends
* to fade in, so _palette.show commits a palette that is black but for entry 1
* (byfx is inert, so nothing carries it) and 4/5/6 (sf_active is 0, so no star
* is drawn). That is the scenario's opening black screen.
        jsr   ScenarioInit

        _palette.set #Pal_starfield
        _palette.show

* "Aleste" on both cards. The two streams are different arrangements of the
* same tune (see objects/music/starfield/), so on a machine carrying BOTH
* extension cards they play together rather than one standing in for the other.
        _music.init.SN76489 #Vgc_alesteSN,#MUSIC_LOOP,#0
        _music.init.YM2413  #Vgc_alesteYM,#MUSIC_LOOP,#0
        _IRQ.init #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame

        jsr   StarfieldInit

* --- text objects (position lives in the OST -> movable later) --------------
* "WIDE-DOT STARFIELD" = 18 glyphs * 4 px = 72 px wide -> x = (160-72)/2 = 44
        jsr   LoadObject_u
        beq   @noTitle
        lda   #ObjID_title
        sta   id,u
        ldd   #44
        std   x_pos,u
        ldd   #88
        std   y_pos,u
@noTitle
* "by FX" = 5 glyphs * 4 px = 20 px wide -> x = 68 (nearest multiple of 4 to 70)
        jsr   LoadObject_u
        beq   @noByFx
        lda   #ObjID_byfx
        sta   id,u
        ldd   #68
        std   x_pos,u
        ldd   #100
        std   y_pos,u
@noByFx

* ============================================================================
* Main loop
* ----------------------------------------------------------------------------
* _gfxlock.on mounts the back buffer in data space ($A000/$C000), so EVERYTHING
* that touches VRAM must sit inside the on/off bracket — that includes
* RunObjects here, because the title and byfx objects draw themselves (unlike
* goldorak, where RunObjects only updates state and BuildSprites does the
* drawing). RunObjects stays after StarfieldRender so the text lands over the
* stars.
* ============================================================================
MainLoop
        _gfxlock.on
        jsr   ScenarioTick             ; FIRST: it gates everything below
        jsr   BallsRestore             ; MUST precede StarfieldRender — see balls.asm
        ldx   #band_text
        jsr   BandRestore              ; MUST precede StarfieldRender — see band.asm
* The caption band is only worth repainting while a caption is up, or just after
* one clears (sc_msg_dirty covers both pages). It is blank from t=26s to the end,
* and restoring its 504 bytes every frame regardless cost ~11% of the render.
        lda   sc_msg
        ora   sc_msg+1
        bne   @msgband
        lda   sc_msg_dirty
        beq   @nomsgband
        dec   sc_msg_dirty
@msgband
        ldx   #band_msg
        jsr   BandRestore              ; MUST precede StarfieldRender — see band.asm
@nomsgband
        jsr   BallsUpdate              ; advance the orbit phase
        jsr   StarfieldUpdate          ; advance positions once per frame
        jsr   StarfieldRender          ; erase old / plot current into back buffer
        jsr   RunObjects               ; title + byfx draw themselves over the stars
        jsr   BallsDraw                ; LAST: the balls sit in front of everything
        _gfxlock.off
        _gfxlock.loop
        lbra  MainLoop                 ; long: the loop body is now >128 bytes

* ---------------------------------------------------------------------------
* 50Hz IRQ — page swap, palette commit, music tick.
* vgc_update MUST be last and reached by jmp (it returns for us), which is why
* the gated path below needs an rts of its own.
*
* The scenario opens on silence, so the two music ticks are gated. The
* _music.init.* calls stay in the init block: they only set up player state, and
* moving them into the script would mean initialising a music player from inside
* the render loop. A player that is never ticked emits nothing, so the chips
* stay at their reset state until sc_music_on opens.
* ---------------------------------------------------------------------------
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow             ; commits the byfx fade + the scenario's
        lda   sc_music_on
        beq   @nomusic
        jsr   YVGM_MusicFrame          ; YM2413 tick
        jmp   vgc_update               ; SN76489 tick
@nomusic
        rts

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/00/ram-data.asm"

* ============================================================================
* Routines
* ============================================================================
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./global/starfield.asm"
        INCLUDE "./global/band.asm"
        INCLUDE "./global/balls.asm"
        INCLUDE "./global/scenario.asm"
        INCLUDE "./global/global-trailer-includes.asm"
