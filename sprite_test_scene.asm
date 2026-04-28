; // ==================================
; // sprite_test_scene.asm
; // ----------------------------------
; // Initializes a scene to have a single sprite to test sprite rendering.
; // ==================================

INCLUDE default_header.inc
INCLUDE sprite_test_scene.inc

; // System
INCLUDE game_object.inc
INCLUDE scene.inc
INCLUDE resource_manager.inc
INCLUDE input_manager.inc

; // GameObjects
INCLUDE player_cursor.inc
INCLUDE camera_mover_game_object.inc
INCLUDE bouncing_image_game_object.inc
INCLUDE knight_game_object.inc
INCLUDE lane_game_object.inc
INCLUDE castle_game_object.inc
INCLUDE shop_game_object.inc
INCLUDE shop_card.inc

; // Components
INCLUDE sprite_component.inc
INCLUDE text_component.inc
INCLUDE transform_component.inc

.data
; // ********************************************
; // Texture data
; // ********************************************

testFile BYTE "Knight.pam", 0
sworFile BYTE "knight_spritesheet_krita.pam", 0
archFile BYTE "archer_krita_spritesheet.pam", 0
heavFile BYTE "heavy_spritesheet_krita.pam", 0
castleFile BYTE "castle.pam", 0
fontFile BYTE "16x32 cartoon font.pam", 0

text BYTE "This is a MAGNIFICENT! test to see if the text string rendering system works. 0123456789", 0
incomeText BYTE "Income", 0
sworText BYTE "Sword", 0
archText BYTE "Archer", 0
heavText BYTE "Heavy", 0

PUBLIC pTex
pTex DWORD ?

PUBLIC pSworTex
pSworTex DWORD ?
PUBLIC pArchTex
pArchTex DWORD ?
PUBLIC pHeavTex
pHeavTex DWORD ?

PUBLIC pCastleTex
pCastleTex DWORD ?

PUBLIC pFontTex
pFontTex DWORD ?

; // ********************************************
; // Controller Binding Setup
; // ********************************************

; // Controllers
p1Controller VirtualController <>
p2Controller VirtualController <>

P1_DEVICE EQU DEVICE_KEYBOARD
P1_LAYOUT EQU 1; // 1 = WASD, 2 = ARROWS

P2_DEVICE EQU DEVICE_KEYBOARD
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

; // ********************************************
; // UI Setup
; // ********************************************
pLane DWORD ?
pShop DWORD ?
gpScene DWORD ?

p1CardList DWORD 4 DUP(?)
p2CardList DWORD 4 DUP(?)

uiYPos EQU 900
uiXOffset EQU 100
uiXSpacing EQU 20
uiCardWidth EQU 140

uiCardSpacing MACRO index, player
	IF player EQ 1
        EXITM <(uiXOffset + (uiXSpacing * index) + (uiCardWidth * index))>
    ELSEIF player EQ 2
        EXITM <(1920 - uiXOffset - uiCardWidth - (uiXSpacing * index) - (uiCardWidth * index))>
	ENDIF
ENDM


.code
; // ----------------------------------
; // Initializes the virtual controllers with the correct bindings
; // ----------------------------------
init_virtual_controllers PROC PUBLIC USES eax ecx

	; // Player 1 setup
	mov p1Controller.deviceID, P1_DEVICE
	lea ecx, p1Controller.bindings
	INVOKE init_unordered_vector, 5

	IF P1_DEVICE EQ DEVICE_KEYBOARD
		IF P1_LAYOUT EQ 1
			; // Push WASD
			INVOKE push_back, OFFSET bind_w_up
			INVOKE push_back, OFFSET bind_s_down
			INVOKE push_back, OFFSET bind_a_left
			INVOKE push_back, OFFSET bind_d_right
			INVOKE push_back, OFFSET bind_space_sel
		ELSE
			; // Push ARROWS
			INVOKE push_back, OFFSET bind_up_up
			INVOKE push_back, OFFSET bind_dn_down
			INVOKE push_back, OFFSET bind_lf_left
			INVOKE push_back, OFFSET bind_rt_right
			INVOKE push_back, OFFSET bind_ent_sel
		ENDIF
	ELSE
		; // Push GAMEPAD
		INVOKE push_back, OFFSET bind_gp_up
		INVOKE push_back, OFFSET bind_gp_down
		INVOKE push_back, OFFSET bind_gp_left
		INVOKE push_back, OFFSET bind_gp_right
		INVOKE push_back, OFFSET bind_gp_sel
	ENDIF

	; // Player 2 setup
	mov p2Controller.deviceID, P2_DEVICE
	lea ecx, p2Controller.bindings
	INVOKE init_unordered_vector, 5

	IF P2_DEVICE EQ DEVICE_KEYBOARD
		IF P2_LAYOUT EQ 1
			; // Push WASD
			INVOKE push_back, OFFSET bind_w_up
			INVOKE push_back, OFFSET bind_s_down
			INVOKE push_back, OFFSET bind_a_left
			INVOKE push_back, OFFSET bind_d_right
			INVOKE push_back, OFFSET bind_space_sel
		ELSE
			; // Push ARROWS
			INVOKE push_back, OFFSET bind_up_up
			INVOKE push_back, OFFSET bind_dn_down
			INVOKE push_back, OFFSET bind_lf_left
			INVOKE push_back, OFFSET bind_rt_right
			INVOKE push_back, OFFSET bind_ent_sel
		ENDIF
	ELSE
		; // Push GAMEPAD
		INVOKE push_back, OFFSET bind_gp_up
		INVOKE push_back, OFFSET bind_gp_down
		INVOKE push_back, OFFSET bind_gp_left
		INVOKE push_back, OFFSET bind_gp_right
		INVOKE push_back, OFFSET bind_gp_sel
	ENDIF

	ret
init_virtual_controllers ENDP

; // ----------------------------------
; // populate_sprite_test_scene
; // Call this method on an empty Scene to fill it
; // with the sprite test scene contents.
; // ----------------------------------
populate_sprite_test_scene PROC PUBLIC USES eax ebx edx esi edi, pScene: DWORD
	mov eax, pScene
	mov gpScene, eax
	INVOKE init_virtual_controllers

	FINIT

	INVOKE load_texture, OFFSET testFile
	mov pTex, eax

	INVOKE load_texture, OFFSET fontFile
	mov pFontTex, eax

	; // Shop
	INVOKE new_shop_game_object
	mov pShop, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, pShop

	; // P1 Card list
	INVOKE new_shop_card, INCO_SHOP_ID, 0, uiCardSpacing(0, 1), uiYPos, OFFSET incomeText, pFontTex
	mov p1CardList[0 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_shop_card, SWOR_SHOP_ID, 0, uiCardSpacing(1, 1), uiYPos, OFFSET sworText, pFontTex
	mov p1CardList[1 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_shop_card, ARCH_SHOP_ID, 0, uiCardSpacing(2, 1), uiYPos, OFFSET archText, pFontTex
	mov p1CardList[2 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_shop_card, HEAV_SHOP_ID, 0, uiCardSpacing(3, 1), uiYPos, OFFSET heavText, pFontTex
	mov p1CardList[3 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_player_cursor, OFFSET p1Controller, pShop, OFFSET p1CardList, 4, ALLY
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	; // P2 Card list
	INVOKE new_shop_card, INCO_SHOP_ID, 0, uiCardSpacing(0, 2), uiYPos, OFFSET incomeText, pFontTex
	mov p2CardList[0 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_shop_card, SWOR_SHOP_ID, 0, uiCardSpacing(1, 2), uiYPos, OFFSET sworText, pFontTex
	mov p2CardList[1 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_shop_card, ARCH_SHOP_ID, 0, uiCardSpacing(2, 2), uiYPos, OFFSET archText, pFontTex
	mov p2CardList[2 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_shop_card, HEAV_SHOP_ID, 0, uiCardSpacing(3, 2), uiYPos, OFFSET heavText, pFontTex
	mov p2CardList[3 * 4], eax
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	INVOKE new_player_cursor, OFFSET p2Controller, pShop, OFFSET p2CardList, 4, ENEMY
	mov ecx, pScene
	INVOKE instantiate_game_object, eax

	; // Lane
	INVOKE new_lane_game_object
	mov pLane, eax

	mov ecx, pScene
	INVOKE instantiate_game_object, pLane
	mov ecx, pLane
	mov edx, pFontTex
	mov (LaneGameObject PTR [ecx]).pFont, edx
	mov ecx, pShop
	mov (ShopGameObject PTR [ecx]).pLane, eax

	; // Get Castle texture
	INVOKE load_texture, OFFSET castleFile
	mov pCastleTex, eax

	; // Ally Castle
	INVOKE new_castle_game_object, ALLY, pCastleTex
	mov esi, eax

	mov eax, pLane
	mov (CastleGameObject PTR [esi]).pLane, eax
	mov ecx, pScene
	INVOKE instantiate_game_object, esi
	mov ecx, pLane
	mov (LaneGameObject PTR [ecx]).pAllyCastle, esi

	; // Enemy Castle
	INVOKE new_castle_game_object, ENEMY, pCastleTex
	mov esi, eax

	mov eax, pLane
	mov (CastleGameObject PTR [esi]).pLane, eax
	mov ecx, pScene
	INVOKE instantiate_game_object, esi
	mov ecx, pLane
	mov (LaneGameObject PTR [ecx]).pEnemyCastle, esi

	; // Get Knight textures
	INVOKE load_texture, OFFSET sworFile
	mov pSworTex, eax
	INVOKE load_texture, OFFSET archFile
	mov pArchTex, eax
	INVOKE load_texture, OFFSET heavFile
	mov pHeavTex, eax

	; // Ally Knight
	INVOKE spawn_knight, ARCH, ALLY

	; // Enemy Knight
	INVOKE spawn_knight, HEAV, ENEMY

	ret
populate_sprite_test_scene ENDP

; // ----------------------------------
; // populate_sprite_test_scene
; // Call this method on an empty Scene to fill it
; // with the sprite test scene contents.
; // ----------------------------------
spawn_knight PROC stdcall PUBLIC USES eax ebx ecx edx esi edi, knightIndex:DWORD, team:DWORD
	; // Puts correct texture in eax
	.IF knightIndex == SWOR
		mov eax, pSworTex
	.ELSEIF knightIndex == ARCH
		mov eax, pArchTex
	.ELSE
		mov eax, pHeavTex
	.ENDIF

	INVOKE new_knight_game_object, team, eax, knightIndex
	mov esi, eax
	mov ecx, gpScene
	INVOKE instantiate_game_object, esi
	mov ecx, pLane
	INVOKE assign_knight, esi

	; // Assigns respective stats
	mov edi, esi
	lea edi, (KnightGameObject PTR [edi]).HP
	mov esi, 0
	.IF knightIndex == SWOR
		lea esi, sworStats
	.ELSEIF knightIndex == ARCH
		lea esi, archStats
	.ELSE
		lea esi, heavStats
	.ENDIF
	mov ecx, 20
	rep movsb

	ret
spawn_knight ENDP

END