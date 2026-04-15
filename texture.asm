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
init_texture PROC PUBLIC USES ecx esi, h:DWORD, w:DWORD, pPixels:DWORD
	mov esi, h
	mov (Texture PTR [ecx]).h, esi
	mov esi, w
	mov (Texture PTR [ecx]).w, esi
	mov esi, pPixels
	mov (Texture PTR [ecx]).pPixels, esi

	mov eax, ecx
init_texture ENDP

new_texture PROC PUBLIC USES ecx
	ret ; // Return with the address of the memory block in HeapAlloc
new_texture ENDP

free_texture PROC PUBLIC 
	ret
free_texture ENDP

END