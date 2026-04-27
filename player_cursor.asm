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

.code
init_player_cursor PROC PUBLIC USES ecx esi edi, pVirtualController:DWORD, pShop : DWORD, pCardList : DWORD
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, PLAYER_CURSOR_GAME_OBJECT_ID

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

END