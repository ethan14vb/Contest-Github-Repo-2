; // ==================================
; // sprite_test_scene.asm
; // ----------------------------------
; // Initializes a scene to have a single sprite to test sprite rendering.
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE scene.inc
INCLUDE game_object.inc
INCLUDE transform_component.inc
INCLUDE resource_manager.inc
INCLUDE sprite_component.inc

.data
testFile BYTE "test_drawing.pam", 0

.code
; // ----------------------------------
; // populate_sprite_test_scene
; // Call this method on an empty Scene to fill it
; // with the sprite test scene contents.
; // ----------------------------------
populate_sprite_test_scene PROC PUBLIC USES eax ebx edx esi edi, pScene: DWORD
	local pTex : DWORD
	INVOKE load_texture, OFFSET testFile
	mov pTex, eax

	; // Sprite
	INVOKE new_game_object, 2
	mov ecx, eax

	INVOKE new_transform_component, 0, 0, 0
	INVOKE add_component, ecx, eax

	INVOKE new_sprite_component, 0, 0, pTex
	INVOKE add_component, ecx, eax

	mov esi, ecx
	mov ecx, pScene
	INVOKE instantiate_game_object, esi
	ret
populate_sprite_test_scene ENDP

END