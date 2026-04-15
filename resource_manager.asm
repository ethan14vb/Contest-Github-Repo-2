; // ==================================
; // resource_manager.asm
; // ----------------------------------
; // Responsible for loading and unloading large
; // assets such as textures.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc

.code
; // ----------------------------------
; // load_texture
; // Takes in the name of a file and then loads that file into memory.
; //
; // Returns:
; //	A pointer to the texture created
; // ----------------------------------
load_texture PROC, pFilename:DWORD
	mov eax, pFilename
	ret
load_texture ENDP

; // ----------------------------------
; // unload_texture
; // Takes a pointer to the texture to unload and destorys it.
; // ----------------------------------
unload_texture PROC, pTexture:DWORD
	mov eax, pTexture
	ret
unload_texture ENDP

END