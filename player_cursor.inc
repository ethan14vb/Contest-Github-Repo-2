; // ==================================
; // player_cusor.inc
; // ----------------------------------
; // The shop is a subclass of GameObject
; // that handles purchases
; // ==================================

IFNDEF PLAYER_CURSOR_INC
PLAYER_CURSOR_INC EQU 1

INCLUDE game_object.inc

PlayerCursor STRUCT
	baseGameObject GameObject<>

	; // GameObject Pointers
	pVirtualController DWORD ?
	pShop DWORD ?

	; // CardList
	pCardList DWORD ?
	sizeCardList DWORD ?

	; // My data
	selectedCardIndex DWORD ?
	team DWORD ?

PlayerCursor ENDS

new_player_cursor PROTO pVirtualController:DWORD, pShop:DWORD, pCardList:DWORD, sizeCardList:DWORD, team:DWORD

ENDIF
