; // ==================================
; // shop_card.asm
; // ----------------------------------
; // The ShopCard is a subclass of GameObject that
; // acts as a visual representation of objects that can be bought
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE shop_card.inc
INCLUDE heap_functions.inc
INCLUDE transform_component.inc
INCLUDE rect_component.inc
INCLUDE renderable_component.inc
INCLUDE text_component.inc

.code
init_shop_card PROC PUBLIC USES ecx esi edi, itemId:DWORD, cost:DWORD, xPos : DWORD, yPos : DWORD, pText:DWORD, pFontTex:DWORD
		local pThis
	mov pThis, ecx
	; // Parent constructor
	INVOKE init_game_object, 0
	mov (GameObject PTR [ecx]).gameObjectType, SHOP_CARD_GAME_OBJECT_ID

	; // Add components
	INVOKE new_transform_component, xPos, yPos, 0FFFFFFFFh
	INVOKE add_component, ecx, eax

	INVOKE new_rect_component, 170, 120, 70, 70, 70, 0FFFFFFFFh
	mov (RenderableComponent PTR [eax]).layer, 3
	INVOKE add_component, ecx, eax

	mov ecx, pThis
	INVOKE new_text_component, pFontTex, 16, 32, 2, 200
	INVOKE add_component, ecx, eax
	mov ecx, eax
	INVOKE set_text_component_text, pText

	mov eax, ecx
	ret
init_shop_card ENDP

new_shop_card PROC PUBLIC USES ecx ebx edx esi edi, itemId:DWORD, cost:DWORD, xPos:DWORD, yPos:DWORD, pText:DWORD, pFontTex:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF ShopCard
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_shop_card, itemId, cost, xPos, yPos, pText, pFontTex

	ret ; // Return with the address of the memory block in HeapAlloc
new_shop_card ENDP

END