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
baseIncomePrice EQU 20
incomePriceMult EQU 1.6

ShopGameObject STRUCT
	baseGameObject GameObject<>
	pLane DWORD ?
	allyCash DWORD ?
	enemyCash DWORD ?
	allyIncome DWORD ?
	enemyIncome DWORD ?
	allyIncomePrice DWORD ?
	enemyIncomePrice DWORD ?
ShopGameObject ENDS

init_shop_game_object PROTO
new_shop_game_object PROTO
buy_knight PROTO, knightIndex:DWORD, team:DWORD
buy_income PROTO, team:DWORD

ENDIF
