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
INCLUDE camera_mover_game_object.inc
INCLUDE bouncing_image_game_object.inc
INCLUDE knight_game_object.inc
INCLUDE lane_game_object.inc
INCLUDE resource_manager.inc
INCLUDE sprite_component.inc

.data
testFile BYTE "other soldier ideas.pam", 0
pLane DWORD ?

PUBLIC pTex
pTex DWORD ?

.code
; // ----------------------------------
; // populate_sprite_test_scene
; // Call this method on an empty Scene to fill it
; // with the sprite test scene contents.
; // ----------------------------------
populate_sprite_test_scene PROC PUBLIC USES eax ebx edx esi edi, pScene: DWORD
	INVOKE load_texture, OFFSET testFile
	mov pTex, eax

	; // Sprite
	INVOKE new_bouncing_image_game_object, pTex
	mov ecx, eax

	mov esi, ecx
	mov ecx, pScene
	INVOKE instantiate_game_object, esi

	; // Camera mover game object
	INVOKE new_camera_mover_game_object
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi

	; // Lane
	INVOKE new_lane_game_object
	mov pLane, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, pLane

	; // Ally Knight
	INVOKE new_knight_game_object, pTex
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi
	mov (LaneGameObject PTR [pLane]).pFirstAlly, esi

	; // Enemy Knight
	INVOKE new_knight_game_object, pTex
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi

	mov (LaneGameObject PTR [pLane]).pFirstEnemy, esi

	ret
populate_sprite_test_scene ENDP

END