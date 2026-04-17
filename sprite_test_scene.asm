; // ==================================
; // sprite_test_scene.asm
; // ----------------------------------
; // Initializes a scene to have a single sprite to test sprite rendering.
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE scene.inc
.code
; // ----------------------------------
; // populate_sprite_test_scene
; // Call this method on an empty Scene to fill it
; // with the sprite test scene contents.
; // ----------------------------------
populate_sprite_test_scene PROC PUBLIC USES eax ebx edx esi edi, pScene: DWORD
	mov eax, pScene
	ret
populate_sprite_test_scene ENDP
END