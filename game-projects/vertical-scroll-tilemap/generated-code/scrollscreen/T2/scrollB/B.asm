	opt   c,ct
	INCLUDE "./generated-code/scrollscreen/T2/main.glb"
	org   $0000
	setdp $FF

        
@loop
        INCLUDEBIN "./objects/scroll/small-map-indexed.0.0.bin.vscroll"
        jmp   @loop
