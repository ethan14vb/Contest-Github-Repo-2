; // ==================================
; // shop_card.inc
; // ----------------------------------
; // The ShopCard is a subclass of GameObject that
; // acts as a visual representation of objects that can be bought
; // ==================================

IFNDEF SHOP_CARD_GAME_OBJECT_INC
SHOP_CARD_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc

ShopCard STRUCT
	baseGameObject GameObject <>

	itemId DWORD ?
	cost DWORD ?
ShopCard ENDS

new_shop_card PROTO itemId:DWORD, cost:DWORD, xPos:DWORD, yPos:DWORD

ENDIF