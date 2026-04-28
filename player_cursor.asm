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
INCLUDE knight_game_object.inc
INCLUDE shop_game_object.inc

.data
PLAYER_CURSOR_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET player_cursor_update, OFFSET game_object_exit, OFFSET free_game_object>

.code
; // ********************************************
; // Constructor Methods
; // ********************************************

init_player_cursor PROC PUBLIC USES ecx esi edi, pVirtualController:DWORD, pShop : DWORD, pCardList : DWORD, sizeCardList : DWORD, team:DWORD
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, PLAYER_CURSOR_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET PLAYER_CURSOR_VTABLE

	; // Add components
	INVOKE new_transform_component, 0, 0, 0FFFFFFFFh
	INVOKE add_component, ecx, eax
		
	; // 10 pixels wider and 10 pixels taller than the shop cards
	INVOKE new_rect_component, 180, 130, 0FFh, 0FFh, 0FFh, 0FFFFFFFFh
	INVOKE add_component, ecx, eax

	; // Class members
	mov (PlayerCursor PTR [ecx]).selectedCardIndex, 0
	mov esi, pVirtualController
	mov (PlayerCursor PTR [ecx]).pVirtualController, esi
	mov esi, pShop
	mov (PlayerCursor PTR [ecx]).pShop, esi
	mov esi, pCardList
	mov (PlayerCursor PTR [ecx]).pCardList, esi
	mov esi, sizeCardList
	mov (PlayerCursor PTR [ecx]).sizeCardList, esi
	mov esi, team
	mov (PlayerCursor PTR [ecx]).team, esi

	mov eax, ecx
	ret
init_player_cursor ENDP

new_player_cursor PROC PUBLIC USES ecx ebx edx esi edi, pVirtualController:DWORD, pShop:DWORD, pCardList:DWORD, sizeCardList:DWORD, team:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF PlayerCursor
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_player_cursor, pVirtualController, pShop, pCardList, sizeCardList, team

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
		mov edx, (PlayerCursor PTR [ecx]).team

		.IF edx == ALLY
			mov esi, (PlayerCursor PTR [ecx]).sizeCardList
			dec esi
			.IF eax < esi
				inc eax
				mov (PlayerCursor PTR [ecx]).selectedCardIndex, eax
			.ENDIF
		.ELSE
			.IF eax > 0
				dec eax
				mov (PlayerCursor PTR [ecx]).selectedCardIndex, eax
			.ENDIF
		.ENDIF
	.ENDIF

	; // Check Left
	mov ecx, pThis
	INVOKE isActionJustPressed, (PlayerCursor PTR [ecx]).pVirtualController, ACTION_UI_LEFT
	.IF eax == 1
		mov ecx, pThis
		mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
		mov edx, (PlayerCursor PTR [ecx]).team

		.IF edx == ALLY
			.IF eax > 0
				dec eax
				mov (PlayerCursor PTR [ecx]).selectedCardIndex, eax
			.ENDIF
		.ELSE
			mov esi, (PlayerCursor PTR [ecx]).sizeCardList
			dec esi
			.IF eax < esi
				inc eax
				mov (PlayerCursor PTR [ecx]).selectedCardIndex, eax
			.ENDIF
		.ENDIF
	.ENDIF

	; // Deployment logic
	mov ecx, pThis
	INVOKE isActionJustPressed, (PlayerCursor PTR [ecx]).pVirtualController, ACTION_SELECT
	.IF eax == 1
		mov ecx, pThis
		
		; // Get the pointer to the selected shop card
		mov esi, (PlayerCursor PTR [ecx]).pCardList
		mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
		mov ebx, [esi + eax * 4]

		; // Purchase logic
		mov edx, (ShopCard PTR [ebx]).cost
		mov ecx, (PlayerCursor PTR [ecx]).pShop

		mov esi, (ShopCard PTR [ebx]).itemId
		mov edi, pThis
		mov edi, (PlayerCursor PTR [edi]).team

		.IF esi == SWOR_SHOP_ID
			INVOKE buy_knight, SWOR, edi
		.ELSEIF esi == ARCH_SHOP_ID
			INVOKE buy_knight, ARCH, edi
		.ELSEIF esi == HEAV_SHOP_ID
			INVOKE buy_knight, HEAV, edi
		.ELSEIF esi == INCO_SHOP_ID
			INVOKE buy_income, edi

			.IF eax != 0
				mov ecx, ebx
				INVOKE update_shop_card_price, eax
			.ENDIF
		.ENDIF
	.ENDIF

	; // Movement
	mov ecx, pThis
	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
	mov esi, eax

	mov ecx, pThis
	mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
	
	; // Positioning logic
	mov ecx, pThis
	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
	mov edi, eax

	; // Get the selected ShopCard's Transform
	mov ecx, pThis
	mov esi, (PlayerCursor PTR [ecx]).pCardList
	mov eax, (PlayerCursor PTR [ecx]).selectedCardIndex
	mov ecx, [esi + eax * 4]
	INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID

	; // Snap to card position
	mov ebx, (TransformComponent PTR [eax]).x

	; // Offset to fit borders
	sub ebx, 5 
	mov (TransformComponent PTR [edi]).x, ebx

	mov ebx, (TransformComponent PTR [eax]).y
	sub ebx, 5
	mov (TransformComponent PTR [edi]).y, ebx

	ret
player_cursor_update ENDP

END