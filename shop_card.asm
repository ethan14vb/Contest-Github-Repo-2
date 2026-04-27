; // ==================================
; // shop_card.asm
; // ----------------------------------
; // The ShopCard is a subclass of GameObject that
; // acts as a visual representation of objects that can be bought
; // ==================================

INCLUDE default_header.inc

.code
init_shop_card PROC PUBLIC USES ecx esi edi
	ret
init_shop_card ENDP

new_shop_card PROC PUBLIC USES ecx ebx edx esi edi, itemId:DWORD, cost:DWORD
	ret
new_shop_card ENDP

END