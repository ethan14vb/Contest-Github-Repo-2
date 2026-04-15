; // ==================================
; // texture.asm
; // ----------------------------------
; // A texture is used to store images into
; // memory.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE texture.inc
.code
init_texture PROC PUBLIC USES ecx esi
	ret
init_texture ENDP
new_texture PROC PUBLIC USES ecx
	ret ; // Return with the address of the memory block in HeapAlloc
new_texture ENDP
free_texture PROC PUBLIC 
	ret
free_texture ENDP
END