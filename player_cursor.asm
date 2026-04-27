; // ==================================
; // player_cusor.asm
; // ----------------------------------
; // The shop is a subclass of GameObject
; // that handles purchases
; // ==================================

INCLUDE default_header.inc
INCLUDE player_cursor.inc
INCLUDE heap_functions.inc
INCLUDE transform_component.inc
INCLUDE rect_component.inc
INCLUDE input_manager.inc
INCLUDE shop_card.inc
INCLUDE sprite_test_scene.inc

.data
PLAYER_CURSOR_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET player_cursor_update, OFFSET game_object_exit, OFFSET free_game_object>

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

init_player_cursor PROC PUBLIC USES ecx esi edi, pVirtualController:DWORD, pShop : DWORD, pCardList : DWORD
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, PLAYER_CURSOR_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET PLAYER_CURSOR_VTABLE

	; // Add components
	INVOKE new_transform_component, 0, 0, 0FFFFFFFFh
	INVOKE add_component, ecx, eax
		
	INVOKE new_rect_component, 110, 60, 0FFh, 0FFh, 0FFh, 0FFFFFFFFh
	INVOKE add_component, ecx, eax

	; // Class members
	mov esi, pVirtualController
	mov (PlayerCursor PTR [ecx]).pVirtualController, esi
	mov esi, pShop
	mov (PlayerCursor PTR [ecx]).pShop, esi
	mov esi, pCardList
	mov (PlayerCursor PTR [ecx]).pCardList, esi

	mov eax, ecx
	ret
init_player_cursor ENDP

new_player_cursor PROC PUBLIC USES ecx ebx edx esi edi, pVirtualController:DWORD, pShop:DWORD, pCardList:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF PlayerCursor
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_player_cursor, pVirtualController, pShop, pCardList

	ret ; // Return with the address of the memory block in HeapAlloc
new_player_cursor ENDP

; // ********************************************
; // Instance Methods
; // ********************************************

player_cursor_update PROC USES ebx ecx edx esi edi, deltaTime:REAL4
	local pThis:DWORD
	mov pThis, ecx

	; // Check Right
	INVOKE isActionJustPressed, (PlayerCursor PTR [ecx]).pVirtualController, ACTION_UI_RIGHT
	.IF eax == 1
		mov ecx, pThis
		mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
		inc eax
		
		; // TODO add bounds checking
		mov (PlayerCursor PTR [ecx]).selectedCardIndex, eax
	.ENDIF

	; // Check Left
	mov ecx, pThis
	INVOKE isActionJustPressed, (PlayerCursor PTR [ecx]).pVirtualController, ACTION_UI_LEFT
	.IF eax == 1
		mov ecx, pThis
		mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
		.IF eax > 0
			dec eax
			mov (PlayerCursor PTR [ecx]).selectedCardIndex, eax
		.ENDIF
	.ENDIF

	; // Deployment logic
	mov ecx, pThis
	INVOKE isActionJustPressed, (PlayerCursor PTR [ecx]).pVirtualController, ACTION_SELECT
	.IF eax == 1
		mov ecx, pThis
		
		; // Get the specific ShopCard data
		mov esi, (PlayerCursor PTR [ecx]).pCardList
		mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
		imul eax, SIZEOF ShopCard
		lea ebx, [esi + eax] 

		; // TODO add purchase logic
	.ENDIF

	; // Movement
	mov ecx, pThis
	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
	mov esi, eax

	mov ecx, pThis
	mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
	
	; // Positioning
	; // TODO add positioning logic

	ret
player_cursor_update ENDP

END