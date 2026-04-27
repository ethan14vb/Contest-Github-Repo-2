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

	; // Pointers
	pVirtualController DWORD ?
	pShop DWORD ?
	pCardList DWORD ?

	; // My data
	selectedCardIndex DWORD ?

PlayerCursor ENDS

ENDIF
