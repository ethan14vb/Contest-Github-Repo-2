; // ==================================
; // shop_card.inc
; // ----------------------------------
; // The ShopCard is a subclass of GameObject that
; // acts as a visual representation of objects that can be bought
; // ==================================

IFNDEF SHOP_CARD_GAME_OBJECT_INC
SHOP_CARD_GAME_OBJECT_INC EQU 1

ShopCard STRUCT
	itemId DWORD ?
	cost DWORD ?
ShopCard ENDS

ENDIF