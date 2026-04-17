; // ==================================
; // SpriteComponent
; // ----------------------------------
; // Defines how a GameObject should appear using a texture.
; // Should be used with a transform for proper functionality.
; // ==================================

INCLUDE default_header.inc
INCLUDE sprite_component.inc
INCLUDE heap_functions.inc
.code
init_sprite_component PROC PUBLIC USES ebx esi
	ret
init_sprite_component ENDP
new_sprite_component PROC PUBLIC USES ebx ecx esi
	ret ; // Return with the address of the memory block in HeapAlloc
new_sprite_component ENDP

END 
