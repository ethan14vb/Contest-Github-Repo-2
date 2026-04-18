; // ==================================
; // bouncing_image_game_object.asm
; // ----------------------------------
; // An image that bounces left and right, mainly used to test that events work.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE bouncing_image_game_object.inc

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_bouncing_image_game_object
; // Initializes memory with the contents of a BouncingImageGameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_bouncing_image_game_object PROC PUBLIC USES ebx ecx edx esi edi, pTexture : DWORD
	mov eax, pTexture
	ret
init_bouncing_image_game_object ENDP

; // ----------------------------------
; // new_bouncing_image_game_object
; // Allocates memory for a BouncingImageGameObject and then calls
; // the initializer method on it.
; // ----------------------------------
new_bouncing_image_game_object PROC PUBLIC USES ebx ecx edx esi edi, pTexture : DWORD
	mov eax, pTexture
	ret
new_bouncing_image_game_object ENDP

END