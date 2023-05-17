; ******************************************************
; generic gamemode update/render loop
; usage : use macro to set both update and render routine first, then call _main.loop.run
; example :
;
;        _main.setUpdateRoutine gamemode.update
;        _main.setRenderRoutine gamemode.render
;        _main.loop.run      
;
; gamemode.update
;        jsr   VerticalScrollMoveUp ; etc.
;        _main.update.return

; gamemode.render
;        jsr   VerticalScroll       ; etc.                    
;        _main.render.return
;
; date: 2023-05-05
; ******************************************************

main.loop
        jmp $1234 ; wll be replaced
main.routines.update EQU *-2
main.update.return
        _gfxlock.on
        jmp $1234 : will be replaced
main.routines.render EQU *-2
main.render.return                                 
        _gfxlock.off
        _gfxlock.loop     
        bra main.loop   