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
; // ----------------------------------
; // init_texture
; // Initializes memory with the contents of a Texture
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_texture PROC PUBLIC USES ecx esi, h:DWORD, w:DWORD, pPixels:DWORD
	mov esi, h
	mov (Texture PTR [ecx]).h, esi
	mov esi, w
	mov (Texture PTR [ecx]).w, esi
	mov esi, pPixels
	mov (Texture PTR [ecx]).pPixels, esi

	mov eax, ecx
init_texture ENDP

; // ----------------------------------
; // new_texture
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_texture PROC PUBLIC USES ecx, h:DWORD, w:DWORD, pPixels:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Texture
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_texture, h, w, pPixels

	ret ; // Return with the address of the memory block in HeapAlloc
new_texture ENDP

; // ----------------------------------
; // free_texture
; // Convenient method for freeing a Texture
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_texture PROC PUBLIC 
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_texture ENDP

END