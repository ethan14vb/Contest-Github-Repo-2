; // ==================================
; // texture.inc
; // ----------------------------------
; // A texture is used to store images into
; // memory.
; // ==================================

IFNDEF TEXTURE_INC
TEXTURE_INC EQU 1

Texture STRUCT
	h DWORD ?			; // The height of the texture
	w DWORD ?			; // The width of the texture
	pPixels DWORD ?		; // The pointer to the pixel data in RGBA (.PAM file format)
Texture ENDS

ENDIF
