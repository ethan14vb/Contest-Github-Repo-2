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

.data
templateText BYTE "$0", 0
cashBuffer BYTE 16 DUP(0)

PRICE_LABEL_ID EQU 6767

.code
int_to_cash_string PROC USES eax ebx ecx edx esi edi, value:DWORD, pBuffer:DWORD, prefixChar:BYTE
	mov eax, value
	mov edi, pBuffer
	mov ebx, 10
	mov ecx, 0

int_to_cash_string_divide_loop:
	mov edx, 0
	div ebx
	push edx
	inc ecx
	cmp eax, 0
	jne int_to_cash_string_divide_loop

	; // Write a prefix symbol
	push eax
	mov al, prefixChar
	mov BYTE PTR [edi], al
	inc edi
	pop eax

int_to_cash_string_pop_loop:
	pop edx
	add dl, '0'
	mov BYTE PTR [edi], dl
	inc edi
	dec ecx
	cmp ecx, 0
	jne int_to_cash_string_pop_loop

	; // Add null terminator
	mov BYTE PTR [edi], 0
	
	ret
int_to_cash_string ENDP

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
	INVOKE new_text_component, pFontTex, 16, 32, 2, 50
	mov (RenderableComponent PTR [eax]).layer, 4
	INVOKE add_component, ecx, eax
	mov ecx, eax
	INVOKE set_text_component_text, pText

	; // Add price
	mov ecx, pThis
	INVOKE new_text_component, pFontTex, 16, 32, 2, 50
	mov (Component PTR [eax]).userId, PRICE_LABEL_ID
	mov (TextComponent PTR [eax]).offsetX, -30
	mov (TextComponent PTR [eax]).offsetY, -50
	mov (RenderableComponent PTR [eax]).layer, 4
	INVOKE add_component, ecx, eax
	mov ecx, eax
	mov esi, cost
	INVOKE int_to_cash_string, esi, OFFSET cashBuffer, '$'
	INVOKE set_text_component_text, OFFSET cashBuffer

	mov ecx, pThis
	mov esi, itemId
	mov (ShopCard PTR [ecx]).itemId, esi

	mov eax, pThis
	ret
init_shop_card ENDP

new_shop_card PROC PUBLIC USES ecx ebx edx esi edi, itemId:DWORD, cost:DWORD, xPos:DWORD, yPos:DWORD, pText:DWORD, pFontTex:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF ShopCard
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_shop_card, itemId, cost, xPos, yPos, pText, pFontTex

	ret ; // Return with the address of the memory block in HeapAlloc
new_shop_card ENDP

update_shop_card_price PROC PUBLIC USES eax ebx ecx edx esi edi, newPrice : DWORD
	INVOKE get_first_component_with_id, PRICE_LABEL_ID
	mov ecx, eax
	mov esi, newPrice
	INVOKE int_to_cash_string, esi, OFFSET cashBuffer, '$'
	INVOKE set_text_component_text, OFFSET cashBuffer

	ret
update_shop_card_price ENDP

END