; // ==================================
; // knight_game_object.inc
; // ----------------------------------
; // The knight is a subclass of GameObject that
; // defines basic behavior for all knights
; // ==================================

IFNDEF KNIGHT_GAME_OBJECT_INC
KNIGHT_GAME_OBJECT_INC EQU 1

INCLUDE game_object.inc

; // Constants for identifying teams
ALLY EQU 0
ENEMY EQU 1

KnightGameObject STRUCT
	baseGameObject GameObject<>
	team DWORD ?
	HP DWORD ?
	ATK DWORD ?
	DEF DWORD ?
	ATKSP DWORD ?	; // Cooldown time between attacks
	MOVSP DWORD ?	; // Speed at which unit moves in lane
	RANGE DWORD ?	; // Distance to next enemy to be able to attack
KnightGameObject ENDS

init_knight_game_object PROTO, team:DWORD, pTexture:DWORD
new_knight_game_object PROTO, team:DWORD, pTexture:DWORD

ENDIF
