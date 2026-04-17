; // ==================================
; // texture.inc
; // ----------------------------------
; // A texture is used to store images into
; // memory.
; // ==================================

IFNDEF TEXTURE_INC
TEXTURE_INC EQU 1

Texture STRUCT
	w DWORD ?			; // The height of the texture
	h DWORD ?			; // The width of the texture
	pPixels DWORD ?		; // The pointer to the pixel data in RGBA (.PAM file format)
Texture ENDS

init_texture PROTO w:DWORD, h:DWORD, pPixels:DWORD
new_texture PROTO w:DWORD, h:DWORD, pPixels:DWORD
free_texture PROTO 

ENDIF
