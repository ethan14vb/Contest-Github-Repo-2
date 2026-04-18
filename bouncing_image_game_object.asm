; // ==================================
; // bouncing_image_game_object.asm
; // ----------------------------------
; // An image that bounces left and right, mainly used to test that events work.
; // ==================================
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE bouncing_image_game_object.inc
.code
init_bouncing_image_game_object PROC PUBLIC USES ebx ecx edx esi edi, pTexture : DWORD
	mov eax, pTexture
	ret
init_bouncing_image_game_object ENDP

new_bouncing_image_game_object PROC PUBLIC USES ebx ecx edx esi edi, pTexture : DWORD
	mov eax, pTexture
	ret
new_bouncing_image_game_object ENDP

END