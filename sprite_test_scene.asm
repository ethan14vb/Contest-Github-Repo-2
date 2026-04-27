; // ==================================
; // sprite_test_scene.asm
; // ----------------------------------
; // Initializes a scene to have a single sprite to test sprite rendering.
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE scene.inc
INCLUDE transform_component.inc
INCLUDE camera_mover_game_object.inc
INCLUDE bouncing_image_game_object.inc
INCLUDE knight_game_object.inc
INCLUDE lane_game_object.inc
INCLUDE castle_game_object.inc
INCLUDE resource_manager.inc
INCLUDE sprite_component.inc
INCLUDE text_component.inc

.data
testFile BYTE "Knight.pam", 0
knightFile BYTE "knight_spritesheet_krita.pam", 0
castleFile BYTE "castle.pam", 0
fontFile BYTE "16x32 cartoon font.pam", 0
pLane DWORD ?
pCastle DWORD ?

text BYTE "This is a MAGNIFICENT! test to see if the text string rendering system works. 0123456789", 0

PUBLIC pTex
pTex DWORD ?

PUBLIC pKnightTex
pKnightTex DWORD ?

PUBLIC pCastleTex
pCastleTex DWORD ?

PUBLIC pFontTex
pFontTex DWORD ?

.code
; // ----------------------------------
; // populate_sprite_test_scene
; // Call this method on an empty Scene to fill it
; // with the sprite test scene contents.
; // ----------------------------------
populate_sprite_test_scene PROC PUBLIC USES eax ebx edx esi edi, pScene: DWORD
	INVOKE load_texture, OFFSET testFile
	mov pTex, eax

	INVOKE load_texture, OFFSET fontFile
	mov pFontTex, eax

	; // Sprite
	INVOKE new_bouncing_image_game_object, pTex
	mov ecx, eax

	INVOKE new_text_component, pFontTex, 16, 32, 2, 200
	INVOKE add_component, ecx, eax

	mov esi, ecx
	mov ecx, eax
	INVOKE set_text_component_text, OFFSET text

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

	; // Get Castle texture
	INVOKE load_texture, OFFSET castleFile
	mov pCastleTex, eax

	; // Ally Castle
	INVOKE new_castle_game_object, ALLY, pCastleTex
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi
	mov ecx, pLane
	mov (LaneGameObject PTR [ecx]).pAllyCastle, esi

	; // Enemy Castle
	INVOKE new_castle_game_object, ENEMY, pCastleTex
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi
	mov ecx, pLane
	mov (LaneGameObject PTR [ecx]).pEnemyCastle, esi

	; // Get Knight texture
	INVOKE load_texture, OFFSET knightFile
	mov pKnightTex, eax

	; // Ally Knight
	INVOKE new_knight_game_object, ALLY, pKnightTex
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi
	mov ecx, pLane
	INVOKE assign_knight, esi

	; // Enemy Knight
	INVOKE new_knight_game_object, ENEMY, pKnightTex
	mov esi, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, esi

	mov ecx, pLane
	INVOKE assign_knight, esi

	ret
populate_sprite_test_scene ENDP

END