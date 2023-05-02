	opt   c,ct
	INCLUDE "./generated-code/scrollscreen/FD/main.glb"
	org   $01E5
	setdp $FF

        
@loop
        INCLUDEBIN "./objects/scroll/small-map-indexed.1.0.bin.vscroll"
        jmp   @loop
