; // ==================================
; // sprite_test_scene.asm
; // ----------------------------------
; // Initializes a scene to have a single sprite to test sprite rendering.
; // ==================================

INCLUDE default_header.inc
INCLUDE sprite_test_scene.inc
INCLUDE game_object.inc
INCLUDE scene.inc
INCLUDE transform_component.inc
INCLUDE camera_mover_game_object.inc
INCLUDE bouncing_image_game_object.inc
INCLUDE knight_game_object.inc
INCLUDE lane_game_object.inc
INCLUDE castle_game_object.inc
INCLUDE shop_game_object.inc
INCLUDE resource_manager.inc
INCLUDE sprite_component.inc
INCLUDE text_component.inc
INCLUDE input_manager.inc

.data
testFile BYTE "Knight.pam", 0
knightFile BYTE "knight_spritesheet_krita.pam", 0
castleFile BYTE "castle.pam", 0
fontFile BYTE "16x32 cartoon font.pam", 0
pLane DWORD ?
pShop DWORD ?

text BYTE "This is a MAGNIFICENT! test to see if the text string rendering system works. 0123456789", 0

PUBLIC pTex
pTex DWORD ?

PUBLIC pKnightTex
pKnightTex DWORD ?

PUBLIC pCastleTex
pCastleTex DWORD ?

PUBLIC pFontTex
pFontTex DWORD ?

; // Controllers
p1Controller VirtualController <>
p2Controller VirtualController <>

P1_DEVICE EQU DEVICE_KEYBOARD
P1_LAYOUT EQU 1; // 1 = WASD, 2 = ARROWS

P2_DEVICE EQU DEVICE_GAMEPAD_0
P2_LAYOUT EQU 2; // 1 = WASD, 2 = ARROWS

; // Keyboard layout 1
bind_w_up      InputBinding <ACTION_LANE_UP, 'W'>
bind_s_down    InputBinding <ACTION_LANE_DOWN, 'S'>
bind_a_left    InputBinding <ACTION_UI_LEFT, 'A'>
bind_d_right   InputBinding <ACTION_UI_RIGHT, 'D'>
bind_space_sel InputBinding <ACTION_SELECT, VK_SPACE>

; // Keyboard layout 2
bind_up_up     InputBinding <ACTION_LANE_UP, VK_UP>
bind_dn_down   InputBinding <ACTION_LANE_DOWN, VK_DOWN>
bind_lf_left   InputBinding <ACTION_UI_LEFT, VK_LEFT>
bind_rt_right  InputBinding <ACTION_UI_RIGHT, VK_RIGHT>
bind_ent_sel   InputBinding <ACTION_SELECT, VK_RETURN>

; // Gamepad layout
bind_gp_up     InputBinding <ACTION_LANE_UP, 0001h>
bind_gp_down   InputBinding <ACTION_LANE_DOWN, 0002h>
bind_gp_left   InputBinding <ACTION_UI_LEFT, 0004h>
bind_gp_right  InputBinding <ACTION_UI_RIGHT, 0008h>
bind_gp_sel    InputBinding <ACTION_SELECT, 1000h>

.code
; // ----------------------------------
; // Initializes the virtual controllers with the correct bindings
; // ----------------------------------
init_virtual_controllers PROC PUBLIC USES eax ecx

	; // Player 1 setup
	mov p1Controller.deviceID, P1_DEVICE
	lea ecx, p1Controller.bindings
	INVOKE init_unordered_vector, 5

	.IF P1_DEVICE EQ DEVICE_KEYBOARD
		.IF P1_LAYOUT EQ 1
			; // Push WASD
			INVOKE push_back, OFFSET bind_w_up
			INVOKE push_back, OFFSET bind_s_down
			INVOKE push_back, OFFSET bind_a_left
			INVOKE push_back, OFFSET bind_d_right
			INVOKE push_back, OFFSET bind_space_sel
		.ELSE
			; // Push ARROWS
			INVOKE push_back, OFFSET bind_up_up
			INVOKE push_back, OFFSET bind_dn_down
			INVOKE push_back, OFFSET bind_lf_left
			INVOKE push_back, OFFSET bind_rt_right
			INVOKE push_back, OFFSET bind_ent_sel
		.ENDIF
	.ELSE
		; // Push GAMEPAD
		INVOKE push_back, OFFSET bind_gp_up
		INVOKE push_back, OFFSET bind_gp_down
		INVOKE push_back, OFFSET bind_gp_left
		INVOKE push_back, OFFSET bind_gp_right
		INVOKE push_back, OFFSET bind_gp_sel
	.ENDIF

	; // Player 2 setup
	mov p2Controller.deviceID, P2_DEVICE
	lea ecx, p2Controller.bindings
	INVOKE init_unordered_vector, 5

	.IF P2_DEVICE EQ DEVICE_KEYBOARD
		.IF P2_LAYOUT EQ 1
			; // Push WASD
			INVOKE push_back, OFFSET bind_w_up
			INVOKE push_back, OFFSET bind_s_down
			INVOKE push_back, OFFSET bind_a_left
			INVOKE push_back, OFFSET bind_d_right
			INVOKE push_back, OFFSET bind_space_sel
		.ELSE
			; // Push ARROWS
			INVOKE push_back, OFFSET bind_up_up
			INVOKE push_back, OFFSET bind_dn_down
			INVOKE push_back, OFFSET bind_lf_left
			INVOKE push_back, OFFSET bind_rt_right
			INVOKE push_back, OFFSET bind_ent_sel
		.ENDIF
	.ELSE
		; // Push GAMEPAD
		INVOKE push_back, OFFSET bind_gp_up
		INVOKE push_back, OFFSET bind_gp_down
		INVOKE push_back, OFFSET bind_gp_left
		INVOKE push_back, OFFSET bind_gp_right
		INVOKE push_back, OFFSET bind_gp_sel
	.ENDIF

	ret
init_virtual_controllers ENDP

; // ----------------------------------
; // populate_sprite_test_scene
; // Call this method on an empty Scene to fill it
; // with the sprite test scene contents.
; // ----------------------------------
populate_sprite_test_scene PROC PUBLIC USES eax ebx edx esi edi, pScene: DWORD
	INVOKE init_virtual_controllers

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

	; // Shop
	INVOKE new_shop_game_object
	mov pShop, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, pShop

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