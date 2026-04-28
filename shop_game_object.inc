; // ==================================
; // shop_game_object.inc
; // ----------------------------------
; // The shop is a subclass of GameObject
; // that handles all logic for both player shops
; // ==================================

IFNDEF SHOP_GAME_OBJECT_INC
SHOP_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc

baseCash EQU 30
baseIncome EQU 5

ShopGameObject STRUCT
	baseGameObject GameObject<>
	allyCash DWORD ?
	enemyCash DWORD ?
	allyIncome DWORD ?
	enemyIncome DWORD ?
ShopGameObject ENDS

init_shop_game_object PROTO
new_shop_game_object PROTO

ENDIF
